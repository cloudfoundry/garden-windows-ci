$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Run-Docker {
  param([String[]] $cmd)

  docker @cmd
  if ($LASTEXITCODE -ne 0) {
    Exit $LASTEXITCODE
  }
}

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"
$env:USERPROFILE = "$env:EPHEMERAL_DISK_TEMP_PATH"

restart-service docker

$version=(cat image-version/version)
Run-Docker "--version"
$releaseNotesDir = "$PWD\notes"
$notesFile = "rootfs-metadata-$version"

$kbs = Run-Docker "run", "${env:IMAGE_NAME}:$version", "powershell", "(get-hotfix).HotFixID"
Write-Output "kbs in image: " + $kbs

$releaseMetadata = @{}
$releaseMetadata["kbs"] = $kbs
$releaseMetadata["version"] = "$version"


$releaseMetadata | convertto-json |  Out-file -FilePath $releaseNotesDir/$notesFile


