#!/bin/bash

# call this script with sudo

dpkg --add-architecture i386; sudo apt -y update

apt -y install curl wget ca-certificates file bsdmainutils util-linux python bzip2 gzip unzip binutils bc jq tmux lib32gcc1 libstdc++6:i386 npm ipcalc ufw traceroute

useradd -m wf -k /etc/skel -s /bin/bash

cd ~wf

wget https://raw.githubusercontent.com/psymin/wf_tool/master/wfserver

chmod +x ~wf/wfserver
chown wf.wf ~wf/wfserver

# npm stuff

su -c 'echo "prefix = ~/.node" >> ~/.npmrc' wf
su -c 'echo "PATH=\"\$HOME/.node/bin:\$PATH\"" >> ~/.profile' wf
su -c 'echo "NODE_PATH=\"\$HOME/.node/lib/node_modules:\$NODE_PATH\"" >> ~/.profile' wf
su -c 'echo "MANPATH=\"\$HOME/.node/share/man:\$MANPATH\"" >> ~/.profile'
su -c 'npm install gamedig -g'

# wfserver install

su -c './wfserver auto-install' wf

# do the ip stuff here

su -c 'echo ip=\"${ip}\" >> ~wf/lgsm/config-lgsm/wfserver/wfserver.cfg'
