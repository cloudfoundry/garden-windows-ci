This assumes you have your bosh and cf cli targetted to the right api endpoint.

#### 1. A typical .NET app
[Nora](https://github.com/cloudfoundry/cf-acceptance-tests/tree/master/assets/nora)

#### 2. Pushing the app
```sh
cd nora/NoraPublished

cf push nora6 -s windows -b hwc_buildpack

curl nora.<system-domain>
"hello i am nora running on http://nora.<system-domain>"

cf scale -i 2 nora
```

#### 3. Finding the windows cell the app ended up on (and many other details)
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
This means the 0th instance runs on the VM with the ip `10.0.1.16` and port `40000`, and similarly for 1st instance.

To find the exact windows diego cell using the IP address, you'd do something like:
```sh
bosh vms -d <deployment-name> | grep <host-ip>
# for the 0th instance, the <host-ip> is: "10\.0\.1\.16"
```


