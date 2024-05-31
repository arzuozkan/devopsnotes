#!/bin/bash
hosts=(
    "192.168.1.20 master.academy.local master"
    "192.168.1.21 docker1.academy.local docker1"
    "192.168.1.22 docker2.academy.local docker2"
    "192.168.1.23 docker3.academy.local docker3"
)

for host in "${hosts[@]}"; do
    echo "$host" | sudo tee -a /etc/hosts > /dev/null
done

echo "Hosts dosyası güncellendi."
# Adım 1 ve 2: Güncelleme ve Docker'ı yükleme
sudo apt update
sudo apt upgrade -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adım 3 ve 4: Alternatif Repo eklemesi
sudo apt install -y apt-transport-https curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Adım 5 ve 6: Swap kapama
sudo swapoff -a
sudo sed -i '/\/swap.img/ s/^/#/' /etc/fstab

# Adım 7 ve 8: containerd.conf düzenleme
echo 'overlay' | sudo tee -a /etc/modules-load.d/containerd.conf
echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/containerd.conf

# Adım 9 ve 10: Kernel modüllerini yükleme
sudo modprobe overlay
sudo modprobe br_netfilter

# Adım 11, 12 ve 13: Kubernetes.conf düzenleme ve sistemi yeniden başlatma
echo 'net.bridge.bridge-nf-call-ip6tables = 1' | sudo tee /etc/sysctl.d/kubernetes.conf
echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.d/kubernetes.conf
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/kubernetes.conf
sudo sysctl --system

# Adım 14: kubelet ayarlarını düzenleme
echo 'KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"' | sudo tee -a /etc/default/kubelet

# Adım 15 ve 16: systemd servislerini yeniden yükleme
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Adım 17 ve 18: Docker ayarlarını düzenleme
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}' | sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker

# Adım 19, 20 ve 21: kubelet servisi yeniden yükleme
sudo sed -i '/Environment=KUBELET_EXTRA_ARGS=/d' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet





# flannel network modülü kullanılacaksa 
subnet_env_file="/run/flannel/subnet.env"
subnet_env_content="FLANNEL_NETWORK=10.240.0.0/16\nFLANNEL_SUBNET=10.240.0.1/24\nFLANNEL_MTU=1450\nFLANNEL_IPMASQ=true"

# Subnet env dosyasını oluştur veya güncelle
sudo mkdir -p /run/flannel  # Dizin var olmayabilir, bu yüzden -p kullanarak oluşturuyoruz
echo -e "$subnet_env_content" | sudo tee "$subnet_env_file" > /dev/null

if [ $? -eq 0 ]; then
    echo "Dosya $subnet_env_file oluşturuldu veya güncellendi."
else
    echo "Dosya $subnet_env_file oluşturulurken bir hata oluştu."
    exit 1
fi

# Servisleri yeniden başlat
sudo systemctl restart kubelet
sudo systemctl restart docker




