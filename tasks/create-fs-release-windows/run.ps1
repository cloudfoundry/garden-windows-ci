$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

push-location windows2016fs-release
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
