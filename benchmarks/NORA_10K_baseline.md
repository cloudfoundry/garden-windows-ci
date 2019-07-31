## NORA_10K baseline

This is the baseline calculated for the purpose of performance testing CF apps when used with the envoy-nginx proxy to enable TLS between the router and the app container. This baseline, measured under a known configuration can be used as a reference for subsequent measurements. The app endpoint was hit at least once before running the benchmark to acccount for the chance of any latency introduced by Just In Time compilation. See [tracker story](https://www.pivotaltracker.com/story/show/166612185) for details.

```
/ ** Configuration **/
No. of requests: 10K
No. of concurrent requests: 5
Name/src of the App : Nora ([source](https://github.com/cloudfoundry/cf-acceptance-tests/tree/2d0252ab4abee732800b0903b76bfd0ce9b85e42/assets/nora/NoraPublished))
App Instances: 50
App path: /
App push command: cf push nora -s windows -b hwc_buildpack && cf scale nora -i 50
IaaS: GCP
No. of windows cell instances : 4
No. of gorouter VM instances : 2
Routing integrity via envoy-nginx on/off : off
Relevant bosh releases/versions used:
	cf-networking          2.23.0,
	capi                   1.84.0,
	diego                  2.35.0,
	garden-runc						 1.19.4,
	hwc-buildpack          3.1.10,
	routing                0.189.0,
	winc                   1.14.0,
	windows-utilities      0.13.0,
	windowsfs              1.9.0
http body resp size/request: 59 bytes
Windows cell spec:
	- machine_type: n1-highmem-4 (root_disk_size_gb: 10, root_disk_type: pd-ssd, name: small-highmem
	- epemeral_disk: { root_disk_size_gb: 100, root_disk_type: pd-ssd, name: 100GB_ephemeral_disk }
	- stemcell: bosh-google-kvm-windows2019-go_agent, 2019.7, windows2019
	- OS Name: Microsoft Windows Server 2019 Datacenter 10.0.17763 N/A Build 17763
	- Total Physical Memory:     26,624 MB

/ ** Output Metrics  using [hey](https://github.com/rakyll/hey) **/
Average response time:   0.0295 secs
Requests per second:     167.7932
Percentile latency distribution:
Latency distribution:
	10% in 0.0269 secs
	25% in 0.0278 secs
	50% in 0.0288 secs
	75% in 0.0301 secs
	90% in 0.0317 secs
	95% in 0.0330 secs
	99% in 0.0363 secs
```
