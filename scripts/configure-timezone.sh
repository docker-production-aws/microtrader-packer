#!/bin/sh
set -e

# Configure host to use Pacific/Auckland timezone
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html
timezone=Pacific/Auckland

echo "### Setting timezone to $timezone ###" 
sudo tee /etc/sysconfig/clock << EOF > /dev/null
ZONE="$timezone"
UTC=false
EOF
sudo ln -sf /usr/share/zoneinfo/$timezone /etc/localtime