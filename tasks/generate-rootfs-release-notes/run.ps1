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
$notesFile = "release-notes-$version"

$releasedJson = cat $PWD\all-kbs-list\all-kbs | convertfrom-json
$releasedKBs = $releasedJson.kbs
$previousVersion = $releasedJson.version

if ("$previousVersion" -eq "$version") {
  Write-Host "Attempting to release a version that's already been shipped. 'v$version' Exiting.."
  Exit 1
}

$releaseMetadata = @{}
$kbs = Run-Docker "run", "${env:IMAGE_NAME}:$version", "powershell", "(get-hotfix).HotFixID"
Write-Output "kbs in image: " + $kbs
$uniqueKBs = $kbs | Where-Object { $releasedKBs -notcontains $_ }
$releaseMetadata["kbs"] = $uniqueKBs
$releaseMetadata["rootfs-version"] = "$version"
$releaseMetadata["previous-version"] = "$previousVersion"
$releaseMetadata | convertto-json | Out-file -FilePath $releaseNotesDir/$notesFile

$updatedKBs = @{}
$updatedKBs["kbs"] = $releasedJson.kbs + $uniqueKBs
$updatedKBs["version"] = "$version"
$updatedKBs | convertto-json | Out-file -FilePath $releaseNotesDir/all-kbs
