[DRAFT]

# IWA Exploration

### Outcome:
The ~~Garden Windows~~ *Windows Container* team was able to have a running container in a domain-joined, bosh-managed VM use a group-managed service account (gMSA) to authenticate with a domain controller.
### Reproduction:
1. Following the steps outlined in the [BOSH-Windows IWA exploration](https://www.pivotaltracker.com/story/show/167407385/comments/205160894), we **created a domain controller.**
2. Deploy a bosh managed VM to be domain-joined in the subsequent step
	
	Deployment Manifest:
	```
	instance_groups:
	- azs:
	  - z1
	  instances: 1
	  jobs:
	  - name: enable_rdp
	    release: windows-utilities
	  - name: enable_ssh
	    release: windows-utilities
	  - name: docker
	    release: windows-tools
	  - name: set_password
	    properties:
	      set_password:
	        password: Password123!
	    release: windows-utilities
	  lifecycle: service
	  name: hello
	  networks:
	  - name: default
	  stemcell: windows
	  vm_type: large
	name: gmsa-big
	releases:
	- name: windows-utilities
	  version: latest
	- name: windows-tools
	  version: "48"
	stemcells:
	- alias: windows
	  os: windows2019
	  version: 2019.9
	update:
	  canaries: 1
	  canary_watch_time: 30000-300000
	  max_errors: 2
	  max_in_flight: 1
	  serial: false
	  update_watch_time: 30000-300000
	```
3. Get a gmsa installed on the BOSH vm

	| -|On the Bosh VM|On the Domain Controller|
	| ---|---|---|
	| log on|RDP onto BOSH VM as domain administrator (get RDP file from azure portal, username: pivotal, password: Password123!)| same as Bosh VM, but get the RDP file for the DC|
	| create AD user, group||<code> > New-ADUser -Name "GardenUser" -Enabled \$True <br>     > \$password = "Password123!"<br>> Set-ADAccountPassword -Identity 'CN=GardenUser,CN=Users,DC=DEMO,DC=FOOBARTLD' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force) <br> > New-ADGroup -Name "GardenGMSAHosts" -SamAccountName "GardenGMSAHosts" -GroupScope Global</code>|
	| domain join the bosh managed vm|<code> > Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses "10.0.0.9,168.63.129.16" FIX THIS - say how to get <br> > ping cfgh-dc-demo <br> > $domain = "DEMO.FOOBARTLD" <br> > $user = "GardenUser" <br> > $password = "Password123!" <br> > $password = ConvertTo-SecureString -String $password -AsPlainText -Force <br> > \$credObject = New-Object System.Management.Automation.PSCredential ("\$user@\$domain", $password) <br> > Add-Computer -DomainName $domain -Credential $credObject <br> > set-service bosh-agent -startuptype automatic <br> > restart-computer <br> <br> #Confirm Domain Joining <br> > (Get-WmiObject -Class Win32_ComputerSystem).Partofdomain <br> ## should return True <br> > Get-WmiObject -Class Win32_ComputerSystem <br> ## should return the name of the domain</code>||
	| create gmsa and add VM host to security access group||<code> > Add-ADGroupMember -Identity "GardenGMSAHosts" -Members dugnri6i0ou2lku$, GardenUser <br> > New-ADServiceAccount -name GardenGMSA -DNSHostName gardengmsa.demo.foobartld -ServicePrincipalNames http/gardengmsa.demo.foobartld -PrincipalsAllowedToRetrieveManagedPassword GardenGMSAHosts -PrincipalsAllowedToDelegateToAccount GardenGMSAHosts <br> <br> #Verify the group is added to the AD service account named GardenGMSA <br> > Get-ADServiceAccount GardenGMSA -Properties PrincipalsAllowedToRetrieveManagedPassword, PrincipalsAllowedToDelegateToAccount </code>|
	| install the created gmsa on the bosh VM |<code> > Add-WindowsFeature RSAT-AD-PowerShell <br> > Import-Module ActiveDirectory <br> > Install-AdServiceAccount GardenGMSA <br> > Test-AdServiceAccount GardenGMSA </code>||

4. Launch a container on the BOSH VM and use the gMSA

	```
	# on the Bosh VM

	Install-Module CredentialSpec
	$CredSpec = (New-CredentialSpec -Name GardenGMSA -AccountName GardenGMSA)
	cp $CredSpec.Path .
	docker run --security-opt "credentialspec=file://GardenGMSA.json" --hostname GardenGMSA.demo.foobartld -it cloudfoundry/windows2016fs:2019.0.28 powershell

	# now in container

	# Your container app will need to run as Local System or Network Service if it needs to use the gMSA identity. So, set your app pool identity to Network Service (In production the could be added to the rootfs Docker file)
	& $env:windir\system32\inetsrv\appcmd.exe set AppPool DefaultAppPool -'processModel.identityType:NetworkService'
	# should see APPPOOL object "DefaultAppPool" changed

	nltest /sc_verify:demo.foobartld
	# should see a response like:
	# Flags: b0 HAS_IP HAS_TIMESERV
	# Trusted DC Name \\CFGH-DC-Demo.DEMO.FOOBARTLD
	# Trusted DC Connection Status Status = 0  0x0 NERR_Success
	# Trust Verification Status = 0  0x0 NERR_Success
	# The command completed successfully

	klist get krbtgt
	# should successfully retrieve kerberos tickets

	dir \\demo.foobartld\SYSVOL
	# directory should exist and be listed

	ipconfig /all
	# DNS Servers section should include the IP of the Domain Controller
	```
