#!/bin/bash

# might be nice to do this with a ${USER} variable instead of static wf

# call this script with sudo

dpkg --add-architecture i386; sudo apt -y update

apt -y install curl wget ca-certificates file bsdmainutils util-linux python bzip2 gzip unzip binutils bc jq tmux lib32gcc1 libstdc++6:i386 npm ipcalc ufw traceroute

useradd -m wf -k /etc/skel -s /bin/bash

cd ~wf

wget https://raw.githubusercontent.com/psymin/wf_tool/master/wfserver

chmod +x ~wf/wfserver
chown wf.wf ~wf/wfserver

# npm stuff

# maybe check if these things are set already before doing it again

su -c 'echo "prefix = ~/.node" >> ~/.npmrc' wf
su -c 'echo "PATH=\"\$HOME/.node/bin:\$PATH\"" >> ~/.profile' wf
su -c 'echo "NODE_PATH=\"\$HOME/.node/lib/node_modules:\$NODE_PATH\"" >> ~/.profile' wf
su -c 'echo "MANPATH=\"\$HOME/.node/share/man:\$MANPATH\"" >> ~/.profile' wf
su -c 'npm install gamedig -g' wf

# wfserver install
# using sudo since su doesn't allow interactive
# interaction shouldn't be necessary
# LinuxGSM does prompt for interaction at times if there are issues

sudo -u wf ~wf/wfserver auto-install

# do the ip stuff here
# setting it static for now

ip="157.230.219.82"

sudo -u wf echo ip=\"${ip}\" >> ~wf/lgsm/config-lgsm/wfserver/common.cfg
chown wf.wf ~wf/lgsm/config-lgsm/wfserver/common.cfg

# show details output, verify ip error isn't there

sudo -u wf ~wf/wfserver details

sudo -u wf ~wf/wfserver start

sudo -u wf ~wf/wfserver postdetails

sudo -u wf ~wf/wfserver postconsole

# setting crontabs

su -c 'curl -s https://raw.githubusercontent.com/psymin/wf_tool/master/wfcron | crontab' wf


echo "Warfork server is now installed as user wf."
echo "To become that user type: sudo su -l wf"
echo
echo "If the server install doesn't work, the details and console log URLs are helpful."
