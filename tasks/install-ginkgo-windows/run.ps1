$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

Write-Host "Installing Ginkgo"
go.exe get -u github.com/onsi/ginkgo/ginkgo
go.exe get -u github.com/onsi/gomega/...
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

Exit 0