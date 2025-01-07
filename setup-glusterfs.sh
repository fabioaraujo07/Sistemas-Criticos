#!/bin/bash

# Install GlusterFS
sudo apt install glusterfs-server -y

# Enable and start the service
sudo systemctl enable --now glusterd

# Create the Folder where the GlusterFS volume will be mounted
sudo mkdir -p /raid1/glusterfs