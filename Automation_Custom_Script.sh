#!/bin/bash
# replace this with your desired static ip address if dhcp isn't available
# this will also serve as the ip is gonna get if connected directly to the ps2
staticAddr="192.168.1.9"

# replace this if your drive is recognized 
# it would typicaly be "sda" or "sda1"
drive="/dev/sda"

#
# modify the lines below at your own risk
#
# ensure we are in root home folder
cd ~
# install unzip and build-essential to build udpbd server later
apt install -y unzip build-essential
#git clone https://github.com/israpps/udpbd-server.git
# better use wget to avoid installing git
# get udpbd-server source code
wget https://github.com/Sakitoshi/udpbd-server_dietpi/raw/refs/heads/main/udpbd-server.zip
# unzip it
unzip udpbd-server.zip
rm udpbd-server.zip
cd udpbd-server
# finally build it
# this takes like 10 minutes, so be patient
make
# install udpbd-server as a service
echo "[Unit]
Description=UDP Block Device Server
After=multi-user.target

[Service]
Type=simple
ExecStart=$HOME/udpbd-server/udpbd-server $drive
Restart=always

[Install]
WantedBy=multi-user.target" > udpbd-server.service
systemctl enable --now ./udpbd-server.service
# set dhcp timeout to 5 seconds to get a fixed ip faster
echo "timeout 5;" >> /etc/dhcp/dhclient.conf
# set a fixed ip
echo "lease {
  interface "eth0";
  fixed-address $staticAddr;
  option subnet-mask 255.255.255.0;
  renew never;
  rebind never;
  expire never;
}" >> /etc/dhcp/dhclient.conf
# all done, let's leave a file to know
touch ../all_done
