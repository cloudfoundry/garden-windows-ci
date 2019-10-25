mkdir C:/tcpdump
push-location C:/tcpdump
curl.exe -LO http://www.microolap.com/downloads/tcpdump/tcpdump_trial_license.zip
Expand-Archive tcpdump_trial_license.zip
rm -Force tcpdump_trial_license.zip
cp tcpdump_trial_license/tcpdump.exe .
rm -Recurse -Force tcpdump_trial_license/
$env:PATH+=";$PWD;"
pop-location
# usage:
# C:/tcpdump/tcpdump.exe -nn -s0 -w <name of file>
  # -nn will not resolve hostnames or ports
  # -s0 will set the size of the packet to capture to unlimited
  # - capture file
# use network packet analyzer to view capture file
