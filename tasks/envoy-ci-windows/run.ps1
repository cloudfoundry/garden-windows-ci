$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

Add-Content -Path "C:\Windows\system32\drivers\etc\hosts" -Encoding ASCII "::1 localhost`n127.0.0.1 localhost`n"

$env:BAZEL_SH="c:\var\vcap\packages\msys2\usr\bin\bash.exe"
$env:BAZEL_VC="C:\var\vcap\data\VSBuildTools\2017\vc"
$env:ENVOY_BAZEL_ROOT="c:\_eb"

$tempDir = "$env:TEMP\envoy-build-dir"
$envoyOutputDir = "$PWD\envoy-exe"

Remove-Item -Recurse -Force $tempDir -ErrorAction Ignore
cmd.exe /c rd /s /q $env:ENVOY_BAZEL_ROOT

New-Item -Type Directory -Force $tempDir
Copy-Item -Recurse -Force .\envoy $tempDir


pushd "$tempDir\envoy"
  powershell "./ci/do_ci.ps1" "bazel.$env:BUILD_TYPE"
  $ec = $LASTEXITCODE
  if ($ec -ne 0) {
    Write-Host "ci failed"
    bazel --output_base=$env:ENVOY_BAZEL_ROOT shutdown
    exit $ec
  }

  if ("$env:BUILD_TYPE" == "release") {
    $gitsha = $(git rev-parse HEAD).Substring(0, 8)
    $ec = $LASTEXITCODE
    if ($ec -ne 0) {
      Write-Host "failed to get sha of HEAD commit"
      exit $ec
    }
    $timestamp = $(Get-Date -UFormat "%s").Split(".")[0]
    Copy-Item "./bazel-out/x64_windows-opt/bin/source/exe/envoy-static.exe" "$envoyOutputDir/envoy-$timestamp-$gitsha.exe"
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
