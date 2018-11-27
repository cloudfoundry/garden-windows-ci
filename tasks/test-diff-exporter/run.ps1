﻿$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go.exe version

$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"
$env:WINC_BINARY = "$PWD\winc-binary\winc.exe"

& "$env:GROOT_BINARY" --driver-store "$env:GROOT_IMAGE_STORE" pull "$env:WINC_TEST_ROOTFS"

cd $env:GOPATH/src/code.cloudfoundry.org/diff-exporter

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}