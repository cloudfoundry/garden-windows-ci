$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Kill-Garden {
  Get-Process | foreach { if ($_.name -eq "gdn") { kill -Force $_.Id } }
}


function get-firewall {
	param([string] $profile)
	$firewall = (Get-NetFirewallProfile -Name $profile)
	$result = "{0},{1},{2}" -f $profile,$firewall.DefaultInboundAction,$firewall.DefaultOutboundAction
	return $result
}

function check-firewall {
	param([string] $profile)
	$firewall = (get-firewall $profile)
	Write-Host $firewall
	if ($firewall -ne "$profile,Block,Block") {
		Write-Host $firewall
		Write-Error "Unable to set $profile Profile"
	}
}

function setup-firewall-1709 {
  $anyFirewallsDisabled = !!(Get-NetFirewallProfile -All | Where-Object { $_.Enabled -eq "False" })
  $adminRuleMissing = !(Get-NetFirewallRule -Name CFAllowAdmins -ErrorAction Ignore)
  if ($anyFirewallsDisabled -or $adminRuleMissing) {
    $admins = New-Object System.Security.Principal.NTAccount("Administrators")
    $adminsSid = $admins.Translate([System.Security.Principal.SecurityIdentifier])

    $LocalUser = "D:(A;;CC;;;$adminsSid)"
    $otherAdmins = Get-WmiObject win32_groupuser |
    Where-Object { $_.GroupComponent -match 'administrators' } |
    ForEach-Object { [wmi]$_.PartComponent }

    foreach($admin in $otherAdmins)
    {
      $ntAccount = New-Object System.Security.Principal.NTAccount($admin.Name)
      $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
      $LocalUser = $LocalUser + "(A;;CC;;;$sid)"
    }
    New-NetFirewallRule -Name CFAllowAdmins -DisplayName "Allow admins" `
      -Description "Allow admin users" -RemotePort Any `
      -LocalPort Any -LocalAddress Any -RemoteAddress Any `
      -Enabled True -Profile Any -Action Allow -Direction Outbound `
      -LocalUser $LocalUser

    Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Block -Enabled True
    check-firewall "public"
    check-firewall "private"
    check-firewall "domain"
    $anyFirewallsDisabled = !!(Get-NetFirewallProfile -All | Where-Object { $_.Enabled -eq "False" })
    $adminRuleMissing = !(Get-NetFirewallRule -Name CFAllowAdmins -ErrorAction Ignore)
    if ($anyFirewallsDisabled -or $adminRuleMissing) {
      Write-Host "anyFirewallsDisabled: $anyFirewallsDisabled"
      Write-Host "adminRuleMissing: $adminRuleMissing"
      Write-Error "Failed to Set Firewall rule"
    }
  }
}

if ($env:WINDOWS_VERSION -eq "1709") {
  setup-firewall-1709
} else {
  #1803 or 2019
  Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Allow -Enabled True
}

$env:PATH = "C:/var/vcap/bosh/bin;" + $env:PATH

go version

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"

$env:GOPATH = "$PWD/garden-runc-release/src/gopath"
$env:PATH= "$env:GOPATH/bin;" + $env:PATH

$gardenInitBinary = "$PWD\garden-init-binary\garden-init.exe"

$grootBinary = "$PWD\groot-binary\groot.exe"
$grootImageStore = "$env:EPHEMERAL_DISK_TEMP_PATH\groot"

& $grootBinary --driver-store "$grootImageStore" pull "$env:WINC_TEST_ROOTFS"

$grootConfigPath = "$PWD/config.yml"
Set-Content -Value "log_level: debug" -Path "$grootConfigPath"

$wincPath = "$PWD/winc-binary/winc.exe"
$wincNetworkPath = "$PWD/winc-network-binary/winc-network.exe"

$config = '{"mtu": 0, "network_name": "winc-nat", "subnet_range": "172.30.0.0/22", "gateway_address": "172.30.0.1"}'
set-content -path "$env:TEMP/interface.json" -value $config

& $wincNetworkPath --action create --configFile "$env:TEMP/interface.json"

$nstarPath = "$PWD/nstar-binary/nstar.exe"

push-location garden-runc-release
  go install ./src/gopath/src/github.com/onsi/ginkgo/ginkgo
  if ($LastExitCode -ne 0) {
      throw "Ginkgo installation process returned error code: $LastExitCode"
  }

  # Upstream garden-runc-release switched to go-modules
  # We still use GOPATH, so move guardian accordingly
  mkdir ./src/gopath/src/code.cloudfoundry.org -ea 0
  if (Test-Path ./src/guardian) {
    mv ./src/guardian ./src/gopath/src/code.cloudfoundry.org/
  }
  go build -o gdn.exe ./src/gopath/src/code.cloudfoundry.org/guardian/cmd/gdn
  if ($LastExitCode -ne 0) {
      throw "Building gdn.exe process returned error code: $LastExitCode"
  }

  # Kill any existing garden servers
  Kill-Garden

  $depotDir = "$env:TEMP\depot"
  Remove-Item -Recurse -Force -ErrorAction Ignore $depotDir
  mkdir $depotDir -Force

  $env:GARDEN_ADDRESS = "127.0.0.1"
  $env:GARDEN_PORT = "8888"

  $tarBin = (get-command tar.exe).source

  Start-Process `
    -NoNewWindow `
    -RedirectStandardOutput gdn.out.log `
    -RedirectStandardError gdn.err.log `
    .\gdn.exe -ArgumentList `
    "server `
    --skip-setup `
    --runtime-plugin=$wincPath `
    --image-plugin=$grootBinary `
    --image-plugin-extra-arg=--driver-store=$grootImageStore `
    --image-plugin-extra-arg=--config=$grootConfigPath `
    --network-plugin=$wincNetworkPath `
    --network-plugin-extra-arg=--configFile=$env:TEMP/interface.json `
    --network-plugin-extra-arg=--log=winc-network.log `
    --network-plugin-extra-arg=--debug `
    --bind-ip=$env:GARDEN_ADDRESS `
    --bind-port=$env:GARDEN_PORT `
    --default-rootfs=$env:WINC_TEST_ROOTFS `
    --nstar-bin=$nstarPath `
    --tar-bin=$tarBin `
    --init-bin=$gardenInitBinary `
    --depot $depotDir `
    --log-level=debug"

  # wait for server to start up
  # and then curl to confirm that it is
  Start-Sleep -s 5
  $pingResult = (curl -UseBasicParsing "http://${env:GARDEN_ADDRESS}:${env:GARDEN_PORT}/ping").StatusCode
  if ($pingResult -ne 200) {
      throw "Pinging garden server failed with code: $pingResult"
  }

  $env:GARDEN_TEST_ROOTFS="$env:WINC_TEST_ROOTFS"
  $env:WINC_BINARY="$wincPath"
  $env:GROOT_BINARY="$grootBinary"
  $env:GROOT_IMAGE_STORE="$grootImageStore"
  Push-Location src/garden-integration-tests
    ginkgo -p -randomizeSuites -noisyPendings=false
  Pop-Location
Pop-Location
$ExitCode="$LastExitCode"

Kill-Garden
& $wincNetworkPath --action delete --configFile "$env:TEMP/interface.json"

if ($ExitCode -ne 0) {
  echo "`n`n`n############# gdn.exe STDOUT"
  Get-Content garden-runc-release/gdn.out.log
  echo "`n`n`n############# gdn.exe STDERR"
  Get-Content garden-runc-release/gdn.err.log
  echo "`n`n`n############# winc-network.exe"
  Get-Content garden-runc-release/winc-network.log
  Exit $ExitCode
}
