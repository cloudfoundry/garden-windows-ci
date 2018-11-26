$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

# Go uses $env:TMP as its TempDir if set
$env:GOTMPDIR = $env:TMP = $env:TEMP
mkdir "$env:TMP" -ea 0

push-location windowsfs-release
  git config core.filemode false
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  git submodule foreach --recursive git config core.filemode false
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }

  new-item -type directory -force .\new-dir
  ./scripts/create-release.ps1 -tarball ./new-dir/release.tgz
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
pop-location
