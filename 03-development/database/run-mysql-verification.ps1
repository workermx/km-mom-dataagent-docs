param(
  [string]$HostName = "127.0.0.1",
  [int]$Port = 3306,
  [string]$User = "root",
  [string]$Password,
  [string]$Database = "mom_data_agent",
  [string]$MysqlPath = "mysql",
  [switch]$SkipSeed
)

$ErrorActionPreference = "Stop"

$mysqlCommand = Get-Command $MysqlPath -ErrorAction SilentlyContinue
if (-not $mysqlCommand) {
  Write-Error "MySQL client not found. Install mysql client or pass -MysqlPath with the full path to mysql.exe."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$schemaFile = Join-Path $scriptDir "001_mvp_schema.sql"
$seedFile = Join-Path $scriptDir "002_mvp_seed_data.sql"
$verifyFile = Join-Path $scriptDir "003_mvp_verify.sql"
$combinedFile = Join-Path $env:TEMP ("mom-data-agent-db-verify-" + [Guid]::NewGuid().ToString("N") + ".sql")
$previousMysqlPwd = [Environment]::GetEnvironmentVariable("MYSQL_PWD", "Process")

foreach ($file in @($schemaFile, $verifyFile)) {
  if (-not (Test-Path $file)) {
    Write-Error "Required SQL file not found: $file"
  }
}

try {
  if ([string]::IsNullOrEmpty($Password)) {
    $securePassword = Read-Host "MySQL password for user '$User'" -AsSecureString
    $passwordPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
      $Password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPtr)
    }
    finally {
      if ($passwordPtr -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPtr)
      }
    }
  }

  [Environment]::SetEnvironmentVariable("MYSQL_PWD", $Password, "Process")

  if (-not $SkipSeed -and -not (Test-Path $seedFile)) {
    Write-Error "Seed SQL file not found: $seedFile"
  }

  $parts = @($schemaFile)
  if (-not $SkipSeed) {
    $parts += $seedFile
  }
  $parts += $verifyFile

  foreach ($part in $parts) {
    Add-Content -Path $combinedFile -Encoding UTF8 -Value ("`n-- BEGIN " + (Split-Path -Leaf $part) + "`n")
    Get-Content -Raw -Encoding UTF8 $part | Add-Content -Path $combinedFile -Encoding UTF8
    Add-Content -Path $combinedFile -Encoding UTF8 -Value ("`n-- END " + (Split-Path -Leaf $part) + "`n")
  }

  Write-Host "Running database verification with one MySQL connection..."
  Write-Host "SQL bundle: $combinedFile"
  cmd /c "`"$MysqlPath`" -h$HostName -P$Port -u$User --default-character-set=utf8mb4 < `"$combinedFile`""
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Database verification failed with exit code $LASTEXITCODE."
  }

  Write-Host "Verification finished. Review output: table count should be 19 and required tables should be OK."
}
finally {
  [Environment]::SetEnvironmentVariable("MYSQL_PWD", $previousMysqlPwd, "Process")
  if (Test-Path $combinedFile) {
    Remove-Item -LiteralPath $combinedFile -Force
  }
}
