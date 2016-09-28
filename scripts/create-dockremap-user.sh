#!/bin/sh
set -e

# Create dockremap user and group
username=dockremap
group=$username
uid=1000
gid=$uid
datadir=/srv

echo "### Creating subuid and subgid mapping files ###"
echo $username:100000:65536 | sudo tee /etc/subuid > /dev/null
echo $username:100000:65536 | sudo tee /etc/subgid > /dev/null
echo "### Creating group $group with ID $gid ###"
sudo groupadd -g $gid $group
echo "### Creating user $username with ID $uid ###"
sudo useradd -u $uid -g $gid -s /sbin/nologin -c "Yellow app remap user" -M -d / $username
echo "### Creating container data directory $datadir ###"
sudo mkdir -p $datadir
sudo chown $username:$group $datadir
sudo chmod 755 $datadir
