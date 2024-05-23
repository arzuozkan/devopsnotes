#!/bin/bash

# Flannel network değeri
FLANNEL_NETWORK="10.240.0.0/16"
echo "Flannel Network: $FLANNEL_NETWORK"

# Kullanıcıdan Flannel Subnet değerini al
read -p "Lütfen Flannel Subnet değerini girin (örn: 10.240.0.1/24): " FLANNEL_SUBNET

# Flannel dizinini kontrol et, yoksa oluştur
if [ ! -d "/run/flannel" ]; then
  mkdir -p /run/flannel
fi

# subnet.env dosyasını oluştur ve içeriği yaz
cat <<EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=$FLANNEL_NETWORK
FLANNEL_SUBNET=$FLANNEL_SUBNET
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF

# kubelet ve docker servislerini yeniden başlat
systemctl restart kubelet
systemctl restart docker

echo "İşlem tamamlandı. kubelet ve docker servisleri yeniden başlatıldı."
