#!/bin/bash

# Güncelleme ve yükseltme
sudo apt update && sudo apt upgrade -y


# Ansible sunucusunu kurma

if ! [ -x "$(command -v ansible)" ]; then

	sudo apt install software-properties-common -y
	sudo apt-add-repository --yes --update ppa:ansible/ansible
	sudo apt install ansible -y

	echo "Ansible kurulumu tamamlandı"
else
	echo "Ansible zaten yuklu"
fi

# Ansible hosts dosyasına client makineleri eklemek için bir betik

# Eklenecek IP adreslerini tanımla
CLIENT1="192.168.1.21"
CLIENT2="192.168.1.22"
CLIENT3="192.168.1.23"
CLIENT4="192.168.1.24"

if ! [ -f "/etc/ansible/hosts" ]; then
	# Ansible hosts dosyası oluştur
	echo "host dosyası yok, oluşturuluyor"
        sudo touch /etc/ansible/hosts
fi

if grep -q "\[ubuntu\]" "/etc/ansible/hosts"; then
	echo "ubuntu grubu zaten var"

else
	# Ansible hosts dosyasına ekle
	echo "[ubuntu]" | sudo tee -a /etc/ansible/hosts
	echo $CLIENT1 | sudo tee -a /etc/ansible/hosts
	echo $CLIENT2 | sudo tee -a /etc/ansible/hosts
	echo $CLIENT3 | sudo tee -a /etc/ansible/hosts
	echo $CLIENT4 | sudo tee -a /etc/ansible/hosts

	echo "Ansible hosts dosyası güncellendi:"
	#cat /etc/ansible/hosts
fi

# ssh denkliği için gerekli key oluşturup gönderelim

if [ ! -f ~/.ssh/id_rsa.pub ]; then
	sudo ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
	echo "ssh key olusturuldu"
else
	echo "ssh key zaten olusturulmus"
fi

# copy ssh key to all hosts

sudo ssh-copy-id root@$CLIENT1
sudo ssh-copy-id root@$CLIENT2
sudo ssh-copy-id root@$CLIENT3
sudo ssh-copy-id root@$CLIENT4

echo "ssh key tum istemcilere gonderildi."


