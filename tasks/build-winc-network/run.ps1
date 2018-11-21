$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# Go uses $env:TMP as its TempDir if set
$env:TMP = $env:TEMP
mkdir "$env:TMP" -ea 0
go.exe version

$env:GOPATH=$PWD
$binaryDir = "$PWD\winc-network-binary"

# work around https://github.com/golang/go/issues/27515
$linkType = (get-item $binaryDir).LinkType
if ($linkType -ne "") {
  $binaryDir = (get-item $binaryDir).Target
}

pushd src\code.cloudfoundry.org\winc
  if ($env:WINDOWS_VERSION -eq "1709") {
    go build -o "$binaryDir\winc-network.exe" .\cmd\winc-network
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    gcc.exe -c ".\network\firewall\dll\firewall.c" -o "$env:TEMP\firewall.o"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    gcc.exe -shared -o "$binaryDir\firewall.dll" "$env:TEMP\firewall.o" -lole32 -loleaut32
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
  } else {
    go build -o "$binaryDir\winc-network.exe" -tags "1803" .\cmd\winc-network
  }
popd
