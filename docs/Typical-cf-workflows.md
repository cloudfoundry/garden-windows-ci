This assumes you have your bosh and cf cli targeted to the right api endpoint.

## 1. A typical .NET app
[Nora](https://github.com/cloudfoundry/cf-acceptance-tests/tree/master/assets/nora)

## 2. Pushing the app
```sh
git clone https://github.com/cloudfoundry/cf-acceptance-tests/tree/master/assets/nora

cd cf-acceptance-tests/assets/nora/NoraPublished

cf push nora -s windows -b hwc_buildpack

curl nora.<system-domain>
"hello i am nora running on http://nora.<system-domain>"

cf scale -i 2 nora
```

## 3. Finding the windows cell the app ended up on (and many other details)
```sh
cf curl v2/apps/$(cf app nora --guid)/stats
{
   "0": {
      "state": "RUNNING",
      ...
         "host": "10.0.1.16".
         "port": 40000,
       ...
      }
   },
   "1": {
      "state": "RUNNING",
       ...
         "host": "10.0.1.17",
         "port": 40006,
       ...
         }
      }
}
```
This means the 0th instance runs on the VM with the ip `10.0.1.16` and port `40000` etc.

To find the exact windows diego cell using the IP address, you'd do something like:
```sh
# for the 0th instance, the <host-ip> is: "10\.0\.1\.16"
bosh vms -d <deployment-name> | grep <host-ip>
windows2019-cell/fea3bc85-434a-4c9f-82d8-6c33be11a2e1           running z1      10.0.1.16       vm-a8f7e59a-ec7c-4789-4a51-5dd69e1b5a12      small-highmem   true
```

## 4. Find the container id of a running app instance
```
cf ssh nora/<instance-id>

Microsoft Windows [Version 10.0.17763.615]
(c) 2018 Microsoft Corporation. All rights reserved.
```

```
C:\Users\vcap>hostname

7928fcab-24f0-4ec0-504f-27a5
# This is the container-Id
```

## 5. SSH into that windows cell that runs this app
```
bosh -d <deployment-name> ssh windows2019-cell/fea3bc85-434a-4c9f-82d8-6c33be11a2e1

Microsoft Windows [Version 10.0.17763.678]
(c) 2018 Microsoft Corporation. All rights reserved.

bosh_9164a78ca398402@VM-A8F7E59A-EC7 C:\Users\bosh_9164a78ca398402>
```

To get into powershell:
```
C:\Users\bosh_9164a78ca398402>powershell

Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\Users\bosh_9164a78ca398402>
```

## 6. Get a powershell as an admin "inside" the app container
Use the container-Id from Step 4.

This uses [winc](https://github.com/cloudfoundry/winc) which is already present on a windows cell.

```
PS C:\Users\bosh_2188ba31a99c44b> C:\var\vcap\packages\winc\winc.exe exec <container-Id> powershell

Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\> whoami

whoami
user manager\containeradministrator
```

## 7. Run .NET apps directly on the windows cell without using containers
Exit out of the container and follow the instructions from [the dotnet-cookbook]
(https://dotnet-cookbook.cfapps.io/aspnet/local-debug-using-hwc-exe/).

## 8. To copy a directory into the container filesystem of an app
From your workstation that has the cf cli targeting the cf api:

```sh
cf ssh-code
# use this as the password for scp when prompted

scp -P 2222 -oUser=cf:$(cf app nora --guid)/0 -r my-app-dir/ ssh.<system-domain>:C:/
```
For more info, see [diego-ssh](https://github.com/cloudfoundry/diego-ssh)

## 9. Installing docker on your windows diego cell

We can use the docker blob from the [windows-tools-release]
(https://github.com/cloudfoundry/windows-tools-release)

```powershell
mkdir C:\docker
cd C:\docker
curl.exe -L https://windows-tools-release.s3.amazonaws.com/73880146-3c89-4268-5ef5-01a2ad21e376 -o docker.zip
Expand-Archive -Path docker.zip -DestinationPath .
cd docker
$env:PATH+=";$PWD;"
dockerd --register-service
Start-Service Docker
```

## 10. Running nora in a docker container to test out cf containerization

* Bosh ssh on to the Windows cell: `bosh -d <deployment-id> ssh <cell-name>`
* Run: `powershell`
* Make sure you have installed docker using instructions from Step 9
* do `$docker = "C:\docker\docker\docker.exe"`
* Put your app on the cell such that `C:/nora/NoraPublished` is legit
* Run `$docker run -it -v C:/nora/NoraPublished:C:/norapublished mcr.microsoft.com/windows/servercore:1809 powershell`
* In the container powershell that you will get:
    * enable windows features required for .NET:
`Add-WindowsFeature Web-Webserver, Web-WebSockets, Web-WHC, Web-ASP, Web-ASP-Net45`
    * Get `hwc.exe` using `curl.exe -L https://github.com/cloudfoundry/hwc/releases/download/17.0.0/hwc.exe -o C:/hwc.exe` (or the latest)
    * Run nora using `& { $env:PORT=8080; C:/hwc.exe -appRootPath C:/norapublished }`
* In another window, bosh ssh to the same windows cell and run `powershell`
* Run `C:\docker\docker\docker.exe ps` and find the container id
* Run `C:\docker\docker\docker.exe exec -it <containerId> powershell`
* In the container powershell that you will get, run `curl.exe http://localhost:8080/`
