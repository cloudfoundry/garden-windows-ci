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
```
```
Microsoft Windows [Version 10.0.17763.615]
(c) 2018 Microsoft Corporation. All rights reserved.
```

```
C:\Users\vcap>hostname
```
```
7928fcab-24f0-4ec0-504f-27a5
# This is the container-Id
```

## 5. SSH into that windows cell that runs this app
```
bosh -d <deployment-name> ssh windows2019-cell/fea3bc85-434a-4c9f-82d8-6c33be11a2e1
```
```
Microsoft Windows [Version 10.0.17763.678]
(c) 2018 Microsoft Corporation. All rights reserved.

bosh_9164a78ca398402@VM-A8F7E59A-EC7 C:\Users\bosh_9164a78ca398402>
```

To get into powershell:
```
C:\Users\bosh_9164a78ca398402>powershell
```
```
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\Users\bosh_9164a78ca398402>
```

## 6. Get a powershell as an admin "inside" the app container
Use the container-Id from Step 4.

This uses [winc](https://github.com/cloudfoundry/winc) which is already present on a windows cell.

```
PS C:\Users\bosh_2188ba31a99c44b> C:\var\vcap\packages\winc\winc.exe exec <container-Id> powershell
```
```
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.
```
```
PS C:\> whoami
```
```
whoami
user manager\containeradministrator
```

## 7. Run .NET apps directly on the windows cell without using containers
Exit out of the container and follow the instructions from [the dotnet-cookbook](https://dotnet-cookbook.cfapps.io/aspnet/local-debug-using-hwc-exe/).

## 8. To copy a directory into the container filesystem of an app
From your workstation that has the cf cli targeting the cf api:

```sh
cf ssh-code
# use this as the password for scp when prompted

scp -P 2222 -oUser=cf:$(cf app nora --guid)/0 -r my-app-dir/ ssh.<system-domain>:C:/
```
For more info, see [diego-ssh](https://github.com/cloudfoundry/diego-ssh)
