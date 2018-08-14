$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:BAZEL_SH="c:\var\vcap\packages\msys2\usr\bin\bash.exe"
$env:BAZEL_VC="c:\var\vcap\packages\vs_buildtools\VC"

cd envoy
powershell "./ci/do_ci.ps1"
exit $LASTEXITCODE
