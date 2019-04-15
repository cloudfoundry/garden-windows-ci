## Garden Windows CI

Set of concourse tasks, dockerfiles, and pipelines for the CF Garden Windows team

### Our Environments

|Name|IaaS|Purpose|
|:---:|:---:|---|
|Mulgore|vSphere|Concourse - Longrunning pipeline [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/longrunning.yml)]|
|Spitfire|GCP|Concourse workers [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/bin/deploy_concourse)]|
|Tartar|GCP|Concourse Windowsfs pipelines [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/windowsfs.yml)]|
|Sriracha|GCP|Concourse - Windows2019fs offline release [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/windowsfs-offline.yml)]|
|Aioli|GCP|Concourse - Windows2019fs online release [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/windowsfs-online.yml)]|
|Pesto|GCP|Concourse - Winc pipeline [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/winc.yml)]|
|Alfredo|GCP|Concourse - garden-windows pipeline [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/garden-windows.yml)]|
|Tzatziki|GCP|Dev environment - 2019|
|Hummus|GCP|Dev environment - 1803|
|Guac|AWS|Dev environment - 1803|
|Chimi|GCP|Acceptance environment - WIP|

### Databases

|Database|Type|Project|Purpose|
|:---:|:---:|:---:|---|
|concourse-db|PostgreSQL 9.6|Spitfire|Store concourse build info|
