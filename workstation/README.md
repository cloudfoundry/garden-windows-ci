??? from here until ???END lines may have been inserted/deleted
# workstation

Workstation setup for osx (High Sierra) and linux (Ubunutu 16.04)

### OSx
Remove the following applications from the base installation

- Google chrome
- Shiftit

## Usage:

```console
wget https://github.com/cloudfoundry/garden-windows-ci/archive/master.zip
unzip master.zip
cd garden-windows-ci-master/workstation
```

- Linux `sudo ./setup`
- OSx `./setup`

### Install antivirus SentinelOne

- Ask IT for access to `SentinelOne_linux_v2_0_5_1124.bsx` in Google Drive

```console
chmod +x ~/Downloads/SentinelOne_linux_v2_0_5_1124.bsx
sudo ~/Downloads/SentinelOne_linux_v2_0_5_1124.bsx
```
