#!/bin/sh

#  Setup Vortoj-IoTSystem
#  Update: 2017/12/13
#  Raspbian Nov.2017

# Install
#TODO:洗い出し
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y git hostapd bridge-utils
sudo systemctl stop hostapd

###############   mysql-server導入時のpassword処理らへん　書き方わからない(ごめんなさい)

#eth0 name set
#MACアドレスの取得が必要　(未実装)
sudo echo -e "/etc/nSUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"xx:xx:xx:xx:xx:xx\", ATTR{dev_id}==\"0x0\", ATTR{type}==\"1\", KERNEL==\"eth*\", NAME=\"eth0\"" > /etc/udev/rules.d/70-persistent-net.rules


# Bridge Connection
sudo echo -e "denyinterfaces wlan0 eth0" >> /etc/dhcpcd.conf
sudo brctl addbr br0
sudo brctl addif br0 eth0 wlan0　#すでにここでダメっぽい
cat <<- EOF >> /etc/network/interfaces
	# Bridge setup
	auto br0
	iface br0 inet manual
	bridge_ports eth0 wlan0
	EOF


# Static IP Address
#IPアドレス任意
cat <<- EOF >> /etc/dhcpcd.conf
	interface br0
	static ip_address=10.0.100.1
	static routers=192.168.0.1
	static domain_name_servers=192.168.0.1
	EOF


# Access Point
#(pass直書きはどうなのか)
cat <<- EOF >> /etc/hostapd/hostapd.conf
	interface=wlan0
	bridge=br0
	driver=nl80211
	ssid=Miagete-goLAN
	hw_mode=g
	channel=7
	wmm_enabled=0
	macaddr_acl=0
	auth_algs=1
	ieee80211n=1
	ignore_broadcast_ssid=0
	wpa=2
	wpa_passphrase=Yorunohoshiwo
	wpa_key_mgmt=WPA-PSK
	wpa_pairwise=TKIP
	rsn_pairwise=CCMP
	EOF
sed -e "s/#DAEMON_CONF/DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"/" /etc/default/hostapd
sudo service hostapd start
sudo service dnsmasq start


# Go環境
#(多分色々足りてない)
wget https://storage.googleapis.com/golang/go1.9.2.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.9.2.linux-armv6l.tar.gz
cat <<- EOF >> $HOME/.bashrc
	export GOROOT=/usr/local/go
	export GOPATH=$HOME/IoT-System
	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
	EOF



#TODO:githubから持ってくる処理↓



#Cleanup
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/apt/archives/*
sudo reboot
