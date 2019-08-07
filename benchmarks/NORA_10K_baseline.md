## NORA_10K baseline

This is the baseline calculated for the purpose of performance testing CF apps when used with the
envoy-nginx proxy to enable TLS between the router and the app container. This baseline, measured
under a known configuration can be used as a reference for subsequent measurements. To compare
with this baseline benchmark, the app endpoint must already receive sufficient hits to account for
the chance of any latency introduced by Just In Time compilation (e.g. `hey -n 300 https://<app-url>/`).

You can get the baseline in json [here](NORA_10K_baseline.json), and the bosh manifest used to generate
the baseline [here](NORA_10K_baseline.yaml).

See [tracker story](https://www.pivotaltracker.com/story/show/166612185) for details.

|||
| ------------- | ------------- |
| No. of requests  | 10K  |
| No. of concurrent requests  | 5  |
| Name/src of the App  | Nora<sup>[1]</sup> |
| App Instances | 50 |
| App path | / |
| App push command | cf push nora -s windows -b hwc_buildpack && cf scale nora -i 50 |
| IaaS | GCP |
| No. of windows cell instances  | 4 |
| No. of gorouter VM instances  | 2 |
| Routing integrity via envoy-nginx on/off  | off |
| Relevant bosh releases/versions used |cf-networking          2.23.0,<br>capi                   1.84.0,<br/>diego                  2.35.0,<br/>garden-runc            1.19.4,<br/>hwc-buildpack          3.1.10,<br/>routing                0.189.0,<br/>winc                   1.14.0,<br/>windows-utilities      0.13.0,<br/>windowsfs              1.9.0
| http body resp size/request | 59 bytes |
| Windows cell spec | machine_type: n1-highmem-4 (root_disk_size_gb: 10, type: pd-ssd, name: small-highmem)<br/> epemeral_disk: root_disk_size_gb: 100, type: pd-ssd, name: 100GB_ephemeral_disk<br/> stemcell: bosh-google-kvm-windows2019-go_agent, 2019.7, windows2019<br/> OS Name: Microsoft Windows Server 2019 Datacenter 10.0.17763 N/A Build 17763<br/> Total Physical Memory:     26,624 MB |
| Benchmark tool command | hey -n 10000 -c 5 https://\<app-url\>/ <sup>[2]</sup>|
| **Average response time** | **0.0295 secs** |
| **Requests per second** | **167.7932** |
| **Latency Percentile distribution** | **10% in 0.0269 secs<br/>25% in 0.0278 secs<br/>50% in 0.0288 secs<br/>75% in 0.0301 secs<br/>90% in 0.0317 secs<br/>95% in 0.0330 secs<br/>99% in 0.0363 secs** |

1. [Nora](https://github.com/cloudfoundry/cf-acceptance-tests/tree/2d0252ab4abee732800b0903b76bfd0ce9b85e42/assets/nora/NoraPublished)
2. [hey](https://github.com/rakyll/hey)
