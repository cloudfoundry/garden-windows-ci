$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"
$env:HOME = "$env:EPHEMERAL_DISK_TEMP_PATH"

push-location windowsfs-release
  git config core.filemode false
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  git submodule foreach --recursive git config core.filemode false
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }

  $releaseDir="$env:TEMP\new-dir"
  If (Test-Path -Path $releaseDir) {
    rm -recurse -force $releaseDir
  }
  new-item -type directory -force $releaseDir

  ./scripts/create-release.ps1 -tarball "$releaseDir\release.tgz"
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
pop-location
