$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:BAZEL_SH="c:\var\vcap\packages\msys2\usr\bin\bash.exe"
$env:BAZEL_VC="c:\var\vcap\packages\vs_buildtools\VC"
$env:ENVOY_BAZEL_ROOT="c:\_eb"

cmd.exe /c rd /s /q $env:ENVOY_BAZEL_ROOT

cd envoy
powershell "./ci/do_ci.ps1"
$ec = $LASTEXITCODE
if ($ec -ne 0) {
  Write-Host "ci failed"
  exit $ec
}

cmd.exe /c rd /s /q $env:ENVOY_BAZEL_ROOT
$ec = $LASTEXITCODE
if ($ec -ne 0) {
  Write-Host "failed to clean up $env:ENVOY_BAZEL_ROOT"
}
exit $ec
