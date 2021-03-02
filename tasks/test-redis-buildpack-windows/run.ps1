$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd redis-buildpack
git checkout "$env:BRANCH"

Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -Proxy $env:HTTP_PROXY -ProxyUseDefaultCredentials -OutFile 'dotnet-install.ps1';
./dotnet-install.ps1 -InstallDir '~/.dotnet' -Version '3.1.201' -ProxyAddress $env:HTTP_PROXY -ProxyUseDefaultCredentials;

./build.ps1 Test --stack Windows
exit $LASTEXITCODE
