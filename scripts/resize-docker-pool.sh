#!/bin/bash

# Resize the docker-pool logical volume to use all of its underlying volume group

set -e

volume=docker/docker-pool

echo "### Resizing $volume ###"
sudo lvextend -L 20G $volume
