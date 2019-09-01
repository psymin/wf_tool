#!/bin/bash

# set up the npm environment for local user installs
# And install gamedig

mkdir ~/.node

echo "prefix = ~/.node" >> ~/.npmrc
echo "PATH=\"\$HOME/.node/bin:\$PATH\"" >> ~/.profile
echo "NODE_PATH=\"\$HOME/.node/lib/node_modules:\$NODE_PATH\"" >> ~/.profile
echo "MANPATH=\"\$HOME/.node/share/man:\$MANPATH\"" >> ~/.profile

#npm install gamedig -g
