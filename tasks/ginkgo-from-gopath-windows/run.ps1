$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"
$env:USERPROFILE = "$env:EPHEMERAL_DISK_TEMP_PATH"

$env:GOPATH=(Resolve-Path $env:GOPATH).Path

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

go install github.com/onsi/ginkgo/v2/ginkgo@latest

cd repo
& "$env:GOPATH/bin/ginkgo.exe" -nodes $env:NODES -r -race -keep-going -randomize-suites $env:TEST_PATH
Exit $LastExitCode
