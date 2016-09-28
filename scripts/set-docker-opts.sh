#!/bin/sh
set -e

# Set the Docker bridge interface to a standard subnet
# Set user namespace remap setting
subnet=192.168.213.1/24
remap=default

echo "### Setting Docker bridge interface subnet to $subnet ###"
sudo sed -i -e "s|^\(OPTIONS=\".*\)\"$|\1 --bip $subnet\"|" /etc/sysconfig/docker
