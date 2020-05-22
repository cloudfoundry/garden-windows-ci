$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$version=(cat image-version/version)

docker run `
  -v "$PWD\artifacts:c:\artifacts" `
  -w c:\artifacts `
  --rm `
  -it `
  "$env:IMAGE_NAME:$version" `
  "powershell" "-Command" "Get-Hotfix | Format-Table -Auto > kb-metadata"
if ($LASTEXITCODE -ne 0) {
  Exit $LASTEXITCODE
}

Write-Output "$env:IMAGE_NAME:$version"
Write-Output $output


