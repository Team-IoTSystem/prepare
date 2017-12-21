#!/bin/sh

#  Setup Vortoj-IoTSystem
#  Update: 2017/12/21
#  Raspbian Nov.2017

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y hostapd bridge-utils
sudo systemctl stop hostapd

#sudo echo -e "denyinterfaces wlan0" >> /etc/dhcpcd.conf
cat <<- EOF >> /etc/dhcpcd.conf
	interface br0
	static ip_address=192.168.0.99/24
	static routers=192.168.0.1
	static domain_name_servers=192.168.0.1

	interface eth0
	static ip_address=192.168.0.100/24
	static routers=192.168.0.1
	static domain_name_servers=192.186.0.1
	EOF
sudo service dhcpcd reload

sudo brctl addbr br0
cat <<- EOF > /etc/hostapd/hostapd.conf
	interface=wlan0
	bridge=br0
	#driver=nl80211
	ssid=Miagete-goLAN
	hw_mode=g
	channel=7
	wmm_enabled=0
	macaddr_acl=0
	auth_algs=1
	ignore_broadcast_ssid=0
	wpa=2
	wpa_passphrase=yorunohoshiwo
	wpa_key_mgmt=WPA-PSK
	wpa_pairwise=TKIP
	rsn_pairwise=CCMP
	EOF
sudo sed -i -e "s@#DAEMON_CONF=""@DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"@" /etc/default/hostapd

sudo brctl addif br0 eth0
cat <<- EOF >> /etc/network/interfaces
	# Bridge setup
	auto br0
	iface br0 inet static
	bridge_ports eth0 wlan0
	EOF

# Go環境
#(多分色々足りてない)
wget https://storage.googleapis.com/golang/go1.9.2.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.9.2.linux-armv6l.tar.gz
cat <<- EOF >> $HOME/.bashrc
	export GOROOT=/usr/local/go
	export GOPATH=$HOME/IoT-System
	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
	EOF

#Cleanup
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/apt/archives/*
sudo reboot
