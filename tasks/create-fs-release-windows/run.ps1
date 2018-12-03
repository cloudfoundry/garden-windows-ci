$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

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
