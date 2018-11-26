$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# Go uses $env:TMP as its TempDir if set
$env:GOTMPDIR = $env:TMP = $env:TEMP
mkdir "$env:TMP" -ea 0
go.exe version

$env:GOPATH=$PWD
$binaryDir = "$PWD\groot-binary"

# work around https://github.com/golang/go/issues/27515
$linkType = (get-item $binaryDir).LinkType
if ($linkType -ne "") {
  $binaryDir = (get-item $binaryDir).Target
}

pushd src\code.cloudfoundry.org\groot-windows
  go build -o "$binaryDir\groot.exe" main.go
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  gcc.exe -c ".\volume\quota\quota.c" -o "$env:TEMP\quota.o"
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  gcc.exe -shared -o "$binaryDir\quota.dll" "$env:TEMP\quota.o" -lole32 -loleaut32
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
popd
