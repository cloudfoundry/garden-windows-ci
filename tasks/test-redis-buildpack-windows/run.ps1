$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd redis-buildpack
git checkout "$env:BRANCH"

dotnet --version
./build.ps1 Test --stack Windows
exit $LASTEXITCODE
