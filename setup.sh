echo This utility was made for my friend to help setup Ubuntu Desktop dualbooting
echo !! WARNING !! This program installs remote access software
R3_REGISTRATION_CODE="26c9315c-e3c7-4bcb-8f6b-376082fb9b40" sh -c "$(curl -L https://downloads.remote.it/remoteit/install_agent.sh)"
echo remote.it remote softwrae installed
echo now installing steam
wget https://cdn.fastly.steamstatic.com/client/installer/steam.deb && dpkg -i steam.deb
echo steam installed
echo updating system
sudo apt update
sudo apt upgrade
echo system updated
