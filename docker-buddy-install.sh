#!/usr/bin/env bash
# Author: Ruben Pereira
# Version: 1.0.5

# This file is a simple script for the docker-buddy installation

# 1. Set the file to write to
user=$(whoami)
file="/home/$user/.bashrc"

# 2. Append multiple lines with '>>' and 'cat', EOT represents end of file
cat << EOT >> $file
if [ -f ~/docker-buddy/.docker-buddy ]; then
   source ~/docker-buddy/.docker-buddy
fi

if [ -f ~/docker-buddy/.docker-buddy-usage ]; then
   source ~/docker-buddy/.docker-buddy-usage
fi
EOT

# 3. Execute bash for docker buddy ready to use
exec bash