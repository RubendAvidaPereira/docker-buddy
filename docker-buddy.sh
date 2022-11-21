#!/usr/bin/env bash
# Author: Ruben Pereira
# Version: 1.0.2

#----------------------------------------------------------------------------Help and Documentation
#
#                               [ Installation of docker buddy ]
#
#
# ---> You can git clone from the repository on github using the following command:
#     -> git clone https://github.com/RubendAvidaPereira/docker-buddy/
# 
# ---> Once you cloned it you should do the following commands
#     -> cd docker-buddy                       ; Moves to the recently docker-buddy directory cloned from github
#     -> mv docker-buddy.sh .docker-buddy      ; Changes docker-buddy file name and extension
#
# ---> On your base folder of linux, generally /home/<username>, edit the file named .bashrc,
# at the end of the file add the following lines accordingly:
#     -> if [ -f ~/docker-buddy/.docker-buddy ]; then
#           source ~/docker-buddy/.docker-buddy
#        fi
# 
# ---> You are ready to use Docker Buddy   
#         _____    _____
#        /  /  \__/  \  \
#        \ /|  /\/\  |\ /
#          _| |o o | |_
#         / . .\__/. . \     WOOF
#        /  . .(__). .  \
#        \  .  /__\  .  /
#         \___/\__/\___/
#

dhelp() {
    printf "\
    DOCKER BUDDY COMMANDS                                                                                                                          HELP
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    BUILD
    
    Buddy  --->$LGREEN dbuild <container_name> <directory>$CESC
    Normal --->$LYELLOW docker build -t <container_name> <directory> $CESC

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    RUN
    
    Buddy  --->$LGREEN drun <ext_port:int_port> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -d -p <ext_port:int_port> <container_name> --name <image_name>$CESC
    
    Buddy  --->$LGREEN dmrun <ext_port:int_port> <ext_directory:int_directory> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -d -p <ext_port:int_port> -v <ext_directory:int_directory> <container_name> --name <image_name>$CESC
    
    Buddy  --->$LGREEN ditrun <ext_port:int_port> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -it <external_port:inside_port> <container_name> --name <image_name> bash$CESC

    Buddy  --->$LGREEN dmitrun <ext_port:int_port> <ext_directory:int_directory> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -it -p <ext_port:int_port> -v <ext_directory:int_directory> <container_name> --name <image_name> bash$CESC
    
    Buddy  --->$LGREEN dexec <image_name>$CESC
    Normal --->$LYELLOW docker exec -it <image_name> bash

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    INSPECT

    Buddy  --->$LGREN dps$CESC
    Normal --->$LYELLOW docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'$CESC

    Buddy  --->$LGREEN dgrep <container_name|id>$CESC
    Normal --->$LYELLOW docker ps --filter name=$1 --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'$CESC
    "
}


#------------------------------------------------------------------ General Tasks and Variables
LRED="\e[1;31m"     # FOR LIGHT RED COLOR IN TERMINAL
LGREEN="\e[1;32m"   # FOR LIGHT BLUE COLOR IN TERMINAL
LYELLOW="\e[1;33m"  # FOR LIGHT YELLOW COLOR IN TERMINAL
CESC="\e[0m"        # TO ESCAPE PREVIOUS COLOR MODIFICATIONS

# RegEx for <ext_port:int_port>
PORT_BIND_REGEX="^[0-9]{2,}:[0-9]{2,}$"

# RegEx for <ext_directory:int_directory>
DIR_BIND_REGEX="^([\/][a-zA-Z0-9_-]{1,}.*[^\/]):([\/][a-zA-Z0-9_-]{1,}.*[^\/])$"

#------------------------------------------------------------------------------- Build Commands
# Builds a docker container with a tag for the container, directory of Dockerfile can be passed
#
# for docker build -t <container_name> <directory>*
# *if <directory> not passed runs on current directory
dbuild() {
    if [[ $# == 0 ]]; then
        printf "$LRED No arguments passed.$CESC\n"
        printf "Usage example ---> dbuild 'my_container' '/home/ubuntu/my_dir'\n"
        return
    fi

    if [[ $# -ge 1 ]]; then
        if [[ -z "$2" ]]; then
            printf "Running docker command:\n"
            printf "docker build -t $1 .\n"
            docker build -t $1 .
            return
        fi

        if [[ -d "$2" ]]; then
            printf "Running docker command:\n"
            printf "docker build -t $1 $2\n"
            docker build -t $1 $2
            return
        else
            printf "$LRED Directory provided doesn't exist.$CESC\n"
            return
        fi
    else 
        printf "$LRED Too few arguments.$CESC\n"
    fi
    return
}

#-------------------------------------------------------------------------------- Run Commands
# Runs a docker container in the background, can specify the image name
#
# for docker run -d -p <ext_port:int_port> <container_name> --name <image_name>*
# * image_name is optional 
drun() {
    # Check if no arguments are passed
    if [[ $# == 0 ]]; then
        printf "$LRED-> No arguments passed.$CESC\n"
        printf "Usage example ---> drun 443:443 'my_container_tag' 'my_image_name'\n"
        return
    fi

    # Command needs at least 2 arguments to run
    if [[ $# -ge 2 ]]; then
        if [[ "$1" =~ $PORT_BIND_REGEX ]]; then
            if [ -z "$3" ]; then
                printf "No image name passed in arguments, docker will create one random.\n"
                printf "Running docker command:\n"
                printf "docker run -d -p $1 $2\n"
                docker run -d -p $1 $2
            else
                printf "Running docker command:\n"
                printf "docker run -d -p $1 $2 --name $3\n"
                docker run -d -p $1 $2 --name $3
            fi
        else
            printf "$LRED->Port bind pattern incorrect.$CESC\n"
            printf "Usage example ---> drun 443:443 'my_container_tag' 'my_image_name'\n"
            return
        fi
    else
        printf "$LRED-> Too few arguments.$CESC\n"
        printf "Usage example ---> drun 443:443 'my_container_tag' 'my_image_name'\n"
        return
    fi
    return
}

# Runs a docker container with volume mount
#
# for docker run -d -p <ext_port:int_port> -v <ext_directory:int_directory> <container_name> --name <image_name>*
# * image_name is optional
dmrun() {
    # Checking if no arguments passed
    if [[ $# == 0 ]]; then
        printf "$LRED No arguments passed.$CESC\n"
        printf "Usage example ---> dmrun 443:443 '/home/ubnutu/my_dir:/docker/my_docker_dir' 'my_container_tag' 'my_image_name'\n"
        return
    fi

    # Command needs at least 3 arguments to run
    if [[ $# -ge 3 ]]; then
        # Testing port bind pattern
        if [[ ! "$1" =~ $PORT_BIND_REGEX ]]; then
            printf "$LRED Port bind pattern incorrect.$CESC\n"
            return
        # Testing directory mapping pattern
        elif [[ ! "$2" =~ $DIR_BIND_REGEX ]]; then
            printf "$LRED Directory bind pattern incorrect\n"
            return
        else
            # Split the 2nd argument to verify if directory exists
            # Using IFS variable (Internal Field Separator) to separate 1st from 2nd directory in for loop
            IFS=":"
            DIR_BIND=($2)
            
            # Declaring directories array
            declare -a directories
            i=0
            
            for directory in "${DIR_BIND[@]}"
            do
                directories[i]=$directory
                ((i++))
            done

            if [[ ! -d ${directories[0]} ]]; then
                printf "$LRED Directory provided: ${directories[0]} don't exists.$CESC\n"
            else
                printf "Running docker command:\n"
                if [[ -z $4 ]]; then
                    printf "docker run -d -p $1 -v $2 $3\n"
                    docker run -d -p $1 -v $2 $3
                else
                    printf "docker run -d -p $1 -v $2 $3 --name $4\n"
                    docker run -d -p $1 -v $2 $3 --name $4
                fi
            fi
            return
        fi
    else
        printf "$LRED Too few arguments.$CESC\n"
        printf "Usage example ---> dmrun 443:443 '/home/ubnutu/my_dir:/docker/my_docker_dir' 'my_container_tag' 'my_image_name'\n"
        return
    fi
    return
}

# Runs a docker container and starts a bash shell immediately after
#
# for docker run -it <external_port:inside_port> <container_name> --name <image_name>* bash
# * image_name is optional 
ditrun() {
    # Checking if no arguments passed
    if [[ $# == 0 ]]; then
        printf "$LRED No arguments passed.$CESC\n"
        printf "Usage example ---> ditrun 443:443 'my_container_tag' 'my_image_name'\n"
        return
    fi

    if [[ $# -ge 2 ]]; then
        if [[ "$1" =~ $PORT_BIND_REGEX ]]; then
            printf "Running docker command:\n"
            if [[ -z "$3" ]]; then
                printf "docker run -it $1 $2 bash\n"
                docker run -it -p $1 $2 bash
            else
                printf "docker run -it $1 $2 --name $3 bash\n"
                docker run -it -p $1 $2 --name $3 bash
            fi
        else
            printf "$LRED Port binding incorrect.$CESC\n"
            return
        fi
    else 
        printf "$LRED Too few arguments.$CESC\n"
        printf "Usage example ---> ditrun 443:443 'my_container_tag' 'my_image_name'\n"
        return
    fi
    return
}

# Runs a docker container with a mounted volume and starts a bash shell immediately after
#
# for docker run -it -p <ext_port:int_port> -v <ext_directory:int_directory> <container_name> --name <image_name>* bash
# * image_name is optional
dmitrun() {
    # Checking if no arguments passed
    if [[ $# == 0 ]]; then
        printf "$LRED No arguments passed.$CESC\n"
        printf "Usage example ---> dmitrun 443:443 /home:/docker 'my_container_tag' 'my_image_name'\n"
        return
    fi

    if [[ $# -ge 3 ]]; then
        if [[ ! "$1" =~ $PORT_BIND_REGEX ]]; then
            printf $"$LRED Port binding incorrect.$CESC\n"
            return
        else
            if [[ ! "$2" =~ $DIR_BIND_REGEX ]]; then
                printf "$LRED Directory binding incorrect.$CESC\n"
                return
            else
                # Split the 2nd argument to verify if directory exists
                # Using IFS variable (Internal Field Separator) to separate 1st from 2nd directory in for loop
                IFS=":"
                DIR_BIND=($2)
                
                # Declaring directories array
                declare -a directories
                i=0
                
                for directory in "${DIR_BIND[@]}"
                do
                    directories[i]=$directory
                    ((i++))
                done

                if [[ ! -d ${directories[0]} ]]; then
                    printf "$LRED Directory provided: ${directories[0]} don't exists.$CESC\n"
                else
                    printf "Running docker command:\n"
                    if [[ -z "$4" ]]; then
                        printf "docker run -it $1 $2 -v $3 bash\n"
                        docker run -it $1 $2 -v $3 bash
                    else
                        printf "docker run -it $1 $2 -v $4 --name $3 bash\n"
                        docker run -it $1 $2 -v $3 --name $4 bash
                    fi
                fi
            fi
        fi
    else 
        printf "$LRED Too few arguments.$CESC\n"
        printf "Usage example ---> ditrun 443:443 'my_container_tag' 'my_image_name'\n"
        return
    fi
    return
}

# Runs a bash shell inside of a docker image
#
# for docker exec -it <image_name> bash
dexec() {
    if [[ $# == 0]]; then
        printf "$LRED No arguments passed.$CESC"
        printf "Usage example ---> dexec my_image"
        return
    else
        if [[ ! $# -gt 1]]; then
            printf "$LRED Too much arguments passed, only 1 required.$CESC"
            printf "Usage example ---> dexec my_image"
            return
        else
            printf "Running docker command:\n"
            printf "docker exec -it $1 bash"
            docker exec -it $1 bash
        fi
    fi
    return
}

#------------------------------------------------------------ Inspect Docker Processes Commands
# Shows current docker processes
#
# for docker ps
dps() {
    printf "Running docker command:\n"
    printf "docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'"
    docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'
}

# Shows current docker processes that match the search pattern
#
# for docker ps --filter name=<container_name|id> 
dgrep() {
    if [[ $# -ge 1 ]]; then
        printf "Running docker command:\n"
        printf "docker ps --filter name=$1 --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'"
        docker ps --filter name=$1 --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'
    else
        printf "No arguments passed.\n"
        printf "Usage example ---> dgrep my_image_name\n"
        return
    fi
    return
}

#------------------------------------------------------------------------------ Remove Commands
# Cleans all docker images
#
# force cleans all docker images in order to clean docker environment, restarts docker after
#dclean() {
#
#}