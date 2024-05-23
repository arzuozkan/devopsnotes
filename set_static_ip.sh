#/bin/bash

#for ubuntu
sudo tee /etc/netplan/00-installer-config.yaml > /dev/null <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      addresses: [192.168.1.20/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOT

sudo netplan apply


#for centos

# Ağ Ayarlarını Yapılandır
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ens33
DEVICE="ens33"
BOOTPROTO=none
ONBOOT=yes
IPADDR="192.168.1.20"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS1="8.8.8.8"
EOF

sudo systemctl restart network

