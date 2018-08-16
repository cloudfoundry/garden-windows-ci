$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:BAZEL_SH="c:\var\vcap\packages\msys2\usr\bin\bash.exe"
$env:BAZEL_VC="C:\var\vcap\data\VSBuildTools\2017\vc"
$env:ENVOY_BAZEL_ROOT="c:\_eb"

# add tar.exe to path. Once we update to concourse 4.0, this can be removed
$env:PATH+=";C:\var\vcap\bosh\bin\"

$tempDir = "$env:TEMP\envoy-build-dir"

Remove-Item -Recurse -Force $tempDir -ErrorAction Ignore
cmd.exe /c rd /s /q $env:ENVOY_BAZEL_ROOT

New-Item -Type Directory -Force $tempDir
Copy-Item -Recurse -Force .\envoy $tempDir


pushd "$tempDir\envoy"
  powershell "./ci/do_ci.ps1"
  $ec = $LASTEXITCODE
  if ($ec -ne 0) {
    Write-Host "ci failed"
    bazel --output_base=$env:ENVOY_BAZEL_ROOT shutdown
    exit $ec
  }

  bazel --output_base=$env:ENVOY_BAZEL_ROOT shutdown
  $ec = $LASTEXITCODE
  if ($ec -ne 0) {
    Write-Host "failed to shutdown bazel server"
    exit $ec
  }
popd

Remove-Item -Recurse -Force $tempDir
cmd.exe /c rd /s /q $env:ENVOY_BAZEL_ROOT
$ec = $LASTEXITCODE
if ($ec -ne 0) {
  Write-Host "failed to clean up $env:ENVOY_BAZEL_ROOT"
}
exit $ec
