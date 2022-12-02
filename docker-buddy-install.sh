#!/usr/bin/env bash
# Author: Ruben Pereira
# Version: 1.0.8

# This file is a simple script for the docker-buddy installation
#   
#         _____    _____
#        /  /  \__/  \  \
#        \ /|  /\/\  |\ /
#          _| |o o | |_
#         / . .\__/. . \     WOOF, let's install it
#        /  . .(__). .  \
#        \  .  /__\  .  /
#         \___/\__/\___/
#

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

if [ -f ~/docker-buddy/docker-buddy-tests/.docker-buddy-test ]; then
   source ~/docker-buddy/docker-buddy-tests/.docker-buddy-test
fi

if [ -f ~/docker-buddy/docker-buddy-tests/.unit-tests ]; then
   source ~/docker-buddy/docker-buddy-tests/.unit-tests
fi
EOT

# 3. Execute bash for docker buddy ready to use
exec bash