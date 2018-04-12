$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go version

$env:GOPATH=$PWD

# need to create a gopath on our own. If we just use the
# 'path:' field in task.yml, symlinks will be created and
# go list ./... (called in the makefile) will complain

mkdir src/github.com/containerd/containerd

cp -r containerd-fork/* src/github.com/containerd/containerd

pushd src/github.com/containerd/containerd
  make test
  if ($LastExitCode -ne 0) {
      throw "'make test' failed with exit code: $LastExitCode"
  }

  make root-test
  if ($LastExitCode -ne 0) {
      throw "'make root-test' failed with exit code: $LastExitCode"
  }

  mkdir bin
  $env:PATH+=";$PWD/bin"
  go build -o bin/containerd.exe cmd/containerd
  if ($LastExitCode -ne 0) {
      throw "couldn't build containerd.exe: exit code $LastExitCode"
  }

  make integration CONTAINERD_RUNTIME=io.containerd.runtime.v1.winc
  if ($LastExitCode -ne 0) {
      throw "'make integration CONTAINERD_RUNTIME=io.containerd.runtime.v1.winc' failed with exit code: $LastExitCode"
  }
popd
