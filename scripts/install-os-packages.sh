#!/bin/sh
set -e

# Add additional OS packages
packages="aws-cfn-bootstrap bind-utils lsof ltrace pv strace telnet tcpdump traceroute awslogs jq"

# Exclude Docker and ECS Agent from update
sudo yum -y -x docker\* -x ecs\* update
echo "### Installing extra packages: $packages ###"
sudo yum -y install $packages
# See https://access.redhat.com/solutions/1498913
sudo ln -s /bin/traceroute /bin/tcptraceroute
