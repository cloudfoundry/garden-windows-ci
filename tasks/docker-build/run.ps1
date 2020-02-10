$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Run-Docker {
  param([String[]] $cmd)

  docker @cmd
  if ($LASTEXITCODE -ne 0) {
    Exit $LASTEXITCODE
  }
}

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:USERPROFILE = "$env:EPHEMERAL_DISK_TEMP_PATH"

# restart-service docker


mkdir buildDir
cp $env:DOCKERFILE buildDir\Dockerfile

cd buildDir

Run-Docker "--version"
Run-Docker "build", "-t", "$env:IMAGE_NAME", "--pull", "."
