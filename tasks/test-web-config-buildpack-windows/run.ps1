$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd web-config-buildpack
./build.ps1 Test --stack Windows