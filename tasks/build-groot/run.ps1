$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH = "$env:GOPATH\bin;" + $env:PATH

go.exe version

pushd groot
  go build -o ..\groot-binary\groot.exe main.go

  gcc.exe -c ".\volume\quota\quota.c" -o "$env:TEMP\quota.o"
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  gcc.exe -shared -o "..\groot-binary\quota.dll" "$env:TEMP\quota.o" -lole32 -loleaut32
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
popd
