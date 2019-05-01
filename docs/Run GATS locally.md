This document explains how to build dependencies and run `GATS` (Garden Acceptance Tests) locally on windows from scratch.

To test changes in a particular component, skip cloning it and keep the source code of the component in the desired location.

For e.g., to test some changes you have made in `winc`, skip cloning winc in `step 3` and keep your modified winc in `$env:GOPATH\src\code.cloudfoundry.org\winc`.

<br/>

### Requirements
* [git](https://git-scm.com/)
* [go](https://golang.org/dl/)
<br/>

### Build and Run
#### 1. Make a test workspace directory and cd into it
```
rm -r -force testworkspace -ea 0
mkdir testworkspace
push-location testworkspace
```
<br/>

#### 2. Set env variables

Set env variables `GOPATH`, `WINDOWS_VERSION`, `INC_TEST_ROOTFS`, `GROOT_IMAGE_STORE` and `$env:EPHEMERAL_DISK_TEMP_PATH`.

**E.g.**
```
$env:GOPATH=$PWD
$env:WINDOWS_VERSION="1803"
$env:WINC_TEST_ROOTFS="docker:///cloudfoundry/windows2016fs:1803"
$env:EPHEMERAL_DISK_TEMP_PATH=$env:TMP
$env:GROOT_IMAGE_STORE="$env:EPHEMERAL_DISK_TEMP_PATH\groot"
```
<br/>

#### 3. Clone dependent git repos

Clone `garden-windows-ci`, `winc`, `winc-release`, `groot-windows`, `garden-runc-release` and `garden-integration-tests`
```
git clone https://github.com/cloudfoundry/garden-windows-ci.git
git clone https://github.com/cloudfoundry/winc.git $env:GOPATH\src\code.cloudfoundry.org\winc
git clone --recurse-submodules https://github.com/cloudfoundry/winc-release.git $env:GOPATH\src\code.cloudfoundry.org\winc-release
git clone https://github.com/cloudfoundry/groot-windows.git $env:GOPATH\src\code.cloudfoundry.org\groot-windows
git clone  --recurse-submodules https://github.com/cloudfoundry/garden-runc-release.git $env:GOPATH\src\code.cloudfoundry.org\garden-runc-release
```
<br/>

#### 4. Plug in windows based garden integration tests into the release
```
rm -r -force $env:GOPATH\src\code.cloudfoundry.org\garden-runc-release\src\garden-integration-tests
git clone -b fork-master https://github.com/greenhouse-org/garden-integration-tests.git $env:GOPATH\src\code.cloudfoundry.org\garden-runc-release\src\garden-integration-tests
```
<br/>

#### 5. Build winc
```
go build -o "winc-binary\winc.exe" $env:GOPATH\src\code.cloudfoundry.org\winc\cmd\winc
```
The gats test script expects the winc binary to be in path `winc-binary\winc.exe` (See step 10)
<br/>

#### 6. Build winc-network
```
mkdir winc-network-binary -ea 0
powershell ./garden-windows-ci/tasks/build-winc-network/run.ps1
```
<br/>

#### 7. Build groot-windows
```
mkdir groot-binary -ea 0
powershell ./garden-windows-ci/tasks/build-groot/run.ps1
```
<br/>

#### 8. Build nstar
```
$env:GOPATH = "$PWD\src\code.cloudfoundry.org\winc-release"
go build -o "nstar-binary\nstar.exe" $env:GOPATH\src\nstar
$env:GOPATH = $PWD
```
<br/>

#### 9. Build garden-runc and copy to expected location
```
go build -o "garden-init-binary\garden-init.exe" $env:GOPATH\src\code.cloudfoundry.org\garden-runc-release\src\guardian\cmd\winit
cp -r $env:GOPATH\src\code.cloudfoundry.org\garden-runc-release .
```
<br/>

#### 10. Pull rootfs layers into the image-store
```
& ".\groot-binary\groot.exe" --driver-store $env:GROOT_IMAGE_STORE pull $env:WINC_TEST_ROOTFS
```
<br/>

#### 11. Run local-gats
```
powershell ./garden-windows-ci/tasks/run-local-gats/run.ps1
```
<br/>

### Clean up (Optional)
```
pop-location
rm -r -force testworkspace
```
