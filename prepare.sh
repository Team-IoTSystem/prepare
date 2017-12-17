#!/bin/sh

set -Ceu

#  Setup Vortoj-IoTSystem
#  Update: 2017/12/16
#  Raspbian Nov.2017


CMDNAME=`basename $0`

br="192.168.100.100"
ssid="Miagete-goLAN"
password="yorunohoshiwo"

while getopts e:w:h OPT
do
  case $OPT in
	b) br="$OPTARG" ;;
    p) password="$OPTARG" ;;
	s) ssid="$OPTARG" ;;      
    h) abort "Usage: $CMDNAME  [-b bridge_ip(default:$br)] [-s wifi ssid(default:$ssid) ]  [-p wifi passphrase(default:$password) ]  " ;;
  esac
done

cat <<- EOF
	your setting on
	
	bridge
		ip: $br
	
	wifis:
		ssid: $ssid
		password: $password
EOF

sudo ifup br0

# Install
#TODO:洗い出し
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y hostapd bridge-utils git
sudo systemctl stop hostapd
###############   mysql-server 


# Bridge Connection
cat <<- EOF >> /etc/network/interfaces
	# Bridge setup
	auto br0
	iface br0 inet dhcp
	bridge_ports eth0 wlan0
	EOF
sudo ifup br0


# Access Point
#(pass直書きはどうなのか)
sudo bash -c "zcat /usr/share/doc/hostapd/examples/hostapd.conf.gz > /etc/hostapd/hostapd.conf"
sudo chmod 600 /etc/hostapd/hostapd.conf
sudo grep -v '^\s*#' /etc/hostapd/hostapd.conf | grep -v '^\s*$' | sudo tee /etc/hostapd/hostapd.conf
sudo sed -i -e "/channel=1/d" -e "/auth_algs/d" -e "/ssid/d" -e "/interface/d" /etc/hostapd/hostapd.conf
cat <<- EOF >> /etc/hostapd/hostapd.conf
	interface=wlan0
	bridge=br0
	driver=nl80211
	ssid=$ssid
	channel=7
	auth_algs=1
	ieee80211n=1
	wpa=2
	wpa_passphrase=$password
	wpa_key_mgmt=WPA-PSK
	rsn_pairwise=CCMP
	EOF
sudo sed -i -e "s@#DAEMON_CONF@DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"@" /etc/default/hostapd
sudo service hostapd start



# Static IP Address
#TODO:IPアドレス書き換え(入力制にすべき？)
# echo -e "net.ifname=0" | sudo tee /boot/cmdline.txt
# sudo echo -e "denyinterfaces eth0" >> /etc/dhcpcd.conf
cat <<- EOF >> /etc/dhcpcd.conf
	interface br0
	static ip_address={$br}/24
	static routers=${br%.*}.1
	static domain_name_servers=${br%.*}.1
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



#TODO:githubから $HOME/IoT-System へ持ってくる処理↓


#Cleanup
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/apt/archives/*
sudo reboot
