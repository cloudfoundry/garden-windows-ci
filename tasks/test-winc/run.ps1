$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

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
  #1803
  Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Allow -Enabled True
}

go.exe version

$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"
$env:GROOT_IMAGE_STORE = "C:\ProgramData\groot"

& "$env:GROOT_BINARY" --driver-store "$env:GROOT_IMAGE_STORE" pull "$env:WINC_TEST_ROOTFS"

go build -o winc-network.exe code.cloudfoundry.org/winc/cmd/winc-network
if ($LastExitCode -ne 0) {
    throw "Building winc-network failed with exit code: $LastExitCode"
}
gcc.exe -c src/code.cloudfoundry.org/winc/network/firewall/dll/firewall.c -o firewall.o
if ($LastExitCode -ne 0) {
    throw "Compiling firewall.o failed with exit code: $LastExitCode"
}
gcc.exe -shared -o firewall.dll firewall.o -lole32 -loleaut32
if ($LastExitCode -ne 0) {
    throw "Compiling firewall.dll failed with exit code: $LastExitCode"
}

$config = '{"name": "winc-nat"}'
set-content -path "$env:TEMP\interface.json" -value $config
./winc-network.exe --action delete --configFile "$env:TEMP/interface.json"
if ($LastExitCode -ne 0) {
    throw "Running winc-network.exe --action delete failed with exit code: $LastExitCode"
}

cd $env:GOPATH/src/code.cloudfoundry.org/winc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 -skipPackage winc-network,perf
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}

ginkgo.exe -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 ./integration/perf
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}

# Microsoft claims networking is better on 1803, let's see...
if ($env:WINC_TEST_ROOTFS.split(":")[-1] -eq "1803") {
  ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 ./integration/winc-network
  $exitCode = $LastExitCode
  Exit $exitCode
}

ginkgo.exe -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10 ./integration/winc-network
$exitCode = $LastExitCode
Exit $exitCode
