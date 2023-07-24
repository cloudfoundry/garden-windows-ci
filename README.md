## Garden Windows CI

Set of concourse tasks, dockerfiles, and pipelines for the CF Garden Windows team

### Our Environments

|Name|IaaS|Purpose|
|:---:|:---:|---|
|Spitfire|GCP|Concourse workers [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/bin/deploy_concourse)]|
|Pesto|GCP|Concourse - Winc pipeline [[URL](https://github.com/cloudfoundry/garden-windows-ci/blob/master/pipelines/winc.yml)]|
|Hummus|GCP|Dev environment - 2019|

### Databases

|Database|Type|Project|Purpose|
|:---:|:---:|:---:|---|
|concourse-db|PostgreSQL 9.6|Spitfire|Store concourse build info|
