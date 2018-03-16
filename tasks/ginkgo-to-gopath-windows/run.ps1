$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

$TEMPDIR=(New-TemporaryDirectory)
New-Item -ItemType Directory -Path "$TEMPDIR\go" -Force
$env:GOPATH=(Resolve-Path "$TEMPDIR\go").Path
$PACKAGE="$env:GOPATH\src\$env:IMPORT_PATH"
New-Item -ItemType Directory -Path $PACKAGE -Force

robocopy.exe /E "repo" "$PACKAGE"
if ($LASTEXITCODE -ge 8) {
    Write-Error "robocopy.exe /E repo/* $PACKAGE"
}

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

go get github.com/onsi/ginkgo/ginkgo
go get github.com/onsi/gomega

cd "$PACKAGE"
go get ./...
& "$env:GOPATH/bin/ginkgo.exe" -nodes $env:NODES -r -race -keepGoing -randomizeSuites
Exit $LastExitCode
