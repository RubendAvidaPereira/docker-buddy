#!/usr/bin/env bash
# Author: Ruben Pereira
# Version: 1.1.0

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

# 2. Set the path to the docker-buddy files
docker_buddy_path=~/docker-buddy

# 3. Array of files to source
files=(".docker-buddy" ".docker-buddy-usage" "docker-buddy-tests/.docker-buddy-test" "docker-buddy-tests/.unit-tests")

# 4. Iterate over the array and source the files if they exist
for file in "${files[@]}"
do
   if [ -f "$docker_buddy_path/$file" ]; then
      echo "source $docker_buddy_path/$file" >> $file
   fi
done

# 5. Execute bash for docker buddy ready to use
exec bash