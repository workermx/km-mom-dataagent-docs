param(
  [string]$ContainerName = "mom-data-agent-mysql",
  [string]$Password = $env:MYSQL_ROOT_PASSWORD
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Password)) {
  Write-Error "MYSQL_ROOT_PASSWORD is required. Set the environment variable or pass -Password."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$schemaFile = Join-Path $scriptDir "001_mvp_schema.sql"
$seedFile = Join-Path $scriptDir "002_mvp_seed_data.sql"
$verifyFile = Join-Path $scriptDir "003_mvp_verify.sql"
$containerDir = "/tmp/mom-verify"

foreach ($file in @($schemaFile, $seedFile, $verifyFile)) {
  if (-not (Test-Path $file)) {
    Write-Error "Required SQL file not found: $file"
  }
}

docker exec $ContainerName mkdir -p $containerDir
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to prepare verification directory in container $ContainerName."
}

docker cp $schemaFile "${ContainerName}:${containerDir}/001_mvp_schema.sql"
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to copy schema SQL into container."
}

docker cp $seedFile "${ContainerName}:${containerDir}/002_mvp_seed_data.sql"
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to copy seed SQL into container."
}

docker cp $verifyFile "${ContainerName}:${containerDir}/003_mvp_verify.sql"
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to copy verify SQL into container."
}

$mysqlBaseCommand = "mysql -h127.0.0.1 -uroot --default-character-set=utf8mb4"
$command = "set -e; " +
  "$mysqlBaseCommand -e 'DROP DATABASE IF EXISTS mom_data_agent; CREATE DATABASE mom_data_agent;'; " +
  "$mysqlBaseCommand mom_data_agent < ${containerDir}/001_mvp_schema.sql; " +
  "$mysqlBaseCommand mom_data_agent < ${containerDir}/002_mvp_seed_data.sql; " +
  "$mysqlBaseCommand mom_data_agent < ${containerDir}/003_mvp_verify.sql"

docker exec -e MYSQL_PWD=$Password $ContainerName sh -c $command
if ($LASTEXITCODE -ne 0) {
  Write-Error "Docker MySQL verification failed with exit code $LASTEXITCODE."
}

Write-Host "Docker MySQL verification finished."
