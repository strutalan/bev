# Updates & prepares the armbian environment for mdns & samba
#! /bin/sh

#remove any conflicting docker packages for docker
apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

#update & upgrade
sudo apt update && apt upgrade -y

#install git, docker, net-tools, wget, avahi-daemon (for mdns), and docker packages
sudo apt install lolcat vim wget git net-tools avahi-daemon samba gnome-terminal docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nodejs npm —install-recommends -f -y 

#ensure cached writes are completed (probably unneccesary)
sync 

#docker should be available immediately after install 
#sudo systemctl status docker

#set hostname
CURRENT_HOSTNAME=$(hostname)
printf "Enter new hostname (default: %s): " "$CURRENT_HOSTNAME"
read -r NEW_HOSTNAME
if [ -z "$NEW_HOSTNAME" ]; then
	NEW_HOSTNAME="$CURRENT_HOSTNAME"
fi

sudo hostnamectl set-hostname "$NEW_HOSTNAME"
echo $NEW_HOSTNAME | sudo tee /etc/hostname

# Configure Samba to share the user's home directory.
TARGET_USER=${SUDO_USER:-$USER}
HOME_DIR=/home
SMB_CONF="/etc/samba/smb.conf"
SMB_MARKER="# --- home-share ---"

if ! grep -q "$SMB_MARKER" "$SMB_CONF" 2>/dev/null; then
	sudo tee -a "$SMB_CONF" >/dev/null <<EOF

$SMB_MARKER
[home]
	path = $HOME_DIR
	browseable = yes
	read only = no
	create mask = 0644
	directory mask = 0755
EOF
fi

#restart samba to apply share
sudo systemctl restart smbd


#run huntly’s docker setup
cd ~
git clone https://github.com/strutalan/bev
cd bev

#install wordpress
cd wp
wget https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz 
rm latest.tar.gz 
mv wordpress/* ./
rmdir wordpress

cd ~/bev
sudo docker compose up -d

