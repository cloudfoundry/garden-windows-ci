## Garden Windows CI

Set of concourse tasks, dockerfiles, and pipelines for the CF Garden Windows team

### Updating pipelines

There are some handy `fly-*` functions defined in dotfiles/flyw to help you fly with all the right lastpass variables.
For example, to update the winc pipeline:

```
$ . $HOME/garden-windows-ci/dotfiles/flyw
$ fly-winc
```

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
