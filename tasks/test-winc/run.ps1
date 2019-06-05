$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function get-firewall {
	param([string] $profile)
	$firewall = (Get-NetFirewallProfile -Name $profile)
	$result = "{0},{1},{2}" -f $profile,$firewall.DefaultInboundAction,$firewall.DefaultOutboundAction
	return $result
}

function check-firewall {
	param([string] $profile)
	$firewall = (get-firewall $profile)
	Write-Host $firewall
	if ($firewall -ne "$profile,Block,Block") {
		Write-Host $firewall
		Write-Error "Unable to set $profile Profile"
	}
}

Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Allow -Enabled True

go.exe version

$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"

$env:GROOT_IMAGE_STORE = "$env:EPHEMERAL_DISK_TEMP_PATH\groot"

$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"

& "$env:GROOT_BINARY" --driver-store "$env:GROOT_IMAGE_STORE" pull "$env:WINC_TEST_ROOTFS"

go build -o winc-network.exe code.cloudfoundry.org/winc/cmd/winc-network
if ($LastExitCode -ne 0) {
    throw "Building winc-network failed with exit code: $LastExitCode"
}
gcc.exe -c src/code.cloudfoundry.org/winc/network/firewall/dll/firewall.c -o firewall.o
if ($LastExitCode -ne 0) {
    throw "Compiling firewall.o failed with exit code: $LastExitCode"
}
gcc.exe -shared -o firewall.dll firewall.o -lole32 -loleaut32
if ($LastExitCode -ne 0) {
    throw "Compiling firewall.dll failed with exit code: $LastExitCode"
}

$config = '{"name": "winc-nat"}'
set-content -path "$env:TEMP\interface.json" -value $config
./winc-network.exe --action delete --configFile "$env:TEMP/interface.json"
if ($LastExitCode -ne 0) {
    throw "Running winc-network.exe --action delete failed with exit code: $LastExitCode"
}

cd $env:GOPATH/src/code.cloudfoundry.org/winc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

# Turn on debug for winc integration
$env:DEBUG="true"

ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 -skipPackage winc-network,perf
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}

ginkgo.exe -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 ./integration/perf  ./integration/winc-network
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}
