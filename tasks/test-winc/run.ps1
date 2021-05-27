$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$ephemeral_disk_temp_path="C:\var\vcap\data\tmp"
mkdir "$ephemeral_disk_temp_path" -ea 0
$env:TEMP = $env:TMP = $ephemeral_disk_temp_path
$env:GROOT_IMAGE_STORE = "$ephemeral_disk_temp_path\groot"

go.exe version

$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"

& "$env:GROOT_BINARY" --driver-store "$env:GROOT_IMAGE_STORE" pull "$env:WINC_TEST_ROOTFS"

cd winc

go build -o winc-network.exe -tags "hnsAcls" ./cmd/winc-network
if ($LastExitCode -ne 0) {
    throw "Building winc-network failed with exit code: $LastExitCode"
}

$config = '{"name": "winc-nat"}'
set-content -path "$env:TEMP\interface.json" -value $config
./winc-network.exe --action delete --configFile "$env:TEMP/interface.json"
if ($LastExitCode -ne 0) {
    throw "Running winc-network.exe --action delete failed with exit code: $LastExitCode"
}

# Turn on debug for winc integration
$env:DEBUG="true"

#TODO: fix these test suites
#~/go/bin/ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 -skipPackage winc-network,perf
~/go/bin/ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 -skipPackage winc-network,perf,netinterface
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}

#TODO: fix these test suites
#~/go/bin/ginkgo.exe -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 ./integration/perf  ./integration/winc-network
~/go/bin/ginkgo.exe -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 ./integration/perf
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}
