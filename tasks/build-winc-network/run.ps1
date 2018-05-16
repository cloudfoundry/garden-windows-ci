$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go.exe version

$env:GOPATH=$PWD
$binaryDir = "$PWD\winc-network-binary"

pushd src\code.cloudfoundry.org\winc
  if ($env:WINDOWS_VERSION -eq "1709") {
    go build -o "$binaryDir\winc-network.exe" .\cmd\winc-network\main.go

    gcc.exe -c ".\network\firewall\dll\firewall.c" -o "$env:TEMP\firewall.o"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    gcc.exe -shared -o "$binaryDir\firewall.dll" "$env:TEMP\firewall.o" -lole32 -loleaut32
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
  } else {
    go build -tags 1803 -o "$binaryDir\winc-network.exe" .\cmd\winc-network\main.go
  }
popd
