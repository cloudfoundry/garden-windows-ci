$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH=$PWD

pushd src/github.com/containerd/containerd
  make test
  if ($LastExitCode -ne 0) {
      throw "'make test' failed with exit code: $LastExitCode"
  }

  make root-test
  if ($LastExitCode -ne 0) {
      throw "'make root-test' failed with exit code: $LastExitCode"
  }

  make integration CONTAINERD_RUNTIME=io.containerd.runtime.v1.winc
  if ($LastExitCode -ne 0) {
      throw "'make integration' failed with exit code: $LastExitCode"
  }
popd
