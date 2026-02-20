# Updates & prepares the armbian environment for mdns & samba
#! /bin/sh

#check if sudo, if not, exit with error
if [ "$(id -u)" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

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
sudo apt install lolcat vim wget git net-tools avahi-daemon samba gnome-terminal docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nodejs npm -y 

#ensure cached writes are completed (probably unneccesary)
sync 

#check docker & samba are installed before continuing
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker could not be found, please check the output above for apt errors and try again."
    exit 1
fi
if ! command -v smbd >/dev/null 2>&1; then
	echo "Samba could not be found, please check the output above for apt errors and try again."
	exit 1
fi

#docker should be available immediately after install 
#sudo systemctl status docker

#set hostname
CURRENT_HOSTNAME=$(hostname)
printf "Enter new hostname (default: %s): " "$CURRENT_HOSTNAME"
read -r NEW_HOSTNAME
if [ -z "$NEW_HOSTNAME" ]; then
	NEW_HOSTNAME="$CURRENT_HOSTNAME"
fi

echo "Setting hostname to: $NEW_HOSTNAME"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"
echo $NEW_HOSTNAME | sudo tee /etc/hostname

echo "Configuring samba and docker, this may take a moment..."
# Configure Samba to share the home directory
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

echo "Samba configured to share $HOME_DIR as 'home'."
echo "Restarting samba..."
#restart samba to apply share
sudo systemctl restart smbd

echo "Samba restarted. You should now be able to access the 'home' share from other devices on the network."

echo "Cloning the bev repository and setting up the docker environment..."
#run huntly’s docker setup
cd ~
git clone https://github.com/strutalan/bev
cd bev

echo "Pre-installing Wordpress latest"
#install wordpress
cd wp
wget https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz 
rm latest.tar.gz 
mv wordpress/* ./
rmdir wordpress



echo "Starting the docker containers - this will take some time, please be patient..."
cd ~/bev
sudo docker compose up -d


echo "Running fix-permissions and generate-ssl..."
./generate-ssl.sh
./fix-permissions.sh

##check status of docker containers
echo "Checking status of docker containers..."
sudo docker ps
echo "Setup complete!"
echo "You can access the Wordpress site at https://$NEW_HOSTNAME.local and the Samba share at smb://$NEW_HOSTNAME.local/home and the adminer dashboard at https://$NEW_HOSTNAME.local:8080"


