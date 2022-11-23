#!/usr/bin/env bash
# Author: Ruben Pereira
# Version: 1.0.3

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

# Docker Buddy Help
# 
# Usage:
#   -> dbuddy -v for docker buddy version
#   -> dbuddy -h for docker buddy help
#
dbuddy() {
    printf "\
    DOCKER BUDDY COMMANDS                                                                                                                          HELP
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    BUILD
    
    Buddy  --->$LGREEN dbuild <container_name> <directory>$CESC
    Normal --->$LYELLOW docker build -t <container_name> <directory> $CESC

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    RUN
    
    Buddy  --->$LGREEN drun <ext_port:int_port> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -d -p <ext_port:int_port> --name <image_name> <container_name>$CESC
    
    Buddy  --->$LGREEN dmrun <ext_port:int_port> <ext_directory:int_directory> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -d -p <ext_port:int_port> -v <ext_directory:int_directory> --name <image_name> <container_name>$CESC
    
    Buddy  --->$LGREEN ditrun <ext_port:int_port> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -it <external_port:inside_port> --name <image_name> <container_name> bash$CESC

    Buddy  --->$LGREEN dmitrun <ext_port:int_port> <ext_directory:int_directory> <container_name> <image_name>$CESC
    Normal --->$LYELLOW docker run -it -p <ext_port:int_port> -v <ext_directory:int_directory> --name <image_name> <container_name> bash$CESC
    
    Buddy  --->$LGREEN dexec <image_name>$CESC
    Normal --->$LYELLOW docker exec -it <image_name> bash$CESC

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    INSPECT

    Buddy  --->$LGREN dps$CESC
    Normal --->$LYELLOW docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'$CESC

    Buddy  --->$LGREEN dgrep <container_name|id>$CESC
    Normal --->$LYELLOW docker ps --filter name=$1 --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'$CESC
    "
}

#--------------------------------------------------------------------------------------- TODOs
# -> Optimize (Add completion, check for flags...)
# -> Integrate with docker-compose
# -> Add docker secrets
# -> Fix bugs
# -> Add docker prune
# -> Add docker inspect
# -> Add docker container ls and docker image ls

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
            docker build -t $1 .
            return
        fi

        if [[ -d "$2" ]]; then
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
                docker run -d -p $1 $2
            else
                docker run -d -p $1 --name $3 $2
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
                if [[ -z $4 ]]; then
                    docker run -d -p $1 -v $2 $3
                else
                    docker run -d -p $1 -v $2 --name $4 $3
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
                docker run -it -p $1 $2 bash
            else
                docker run -it -p $1 --name $3 $2 bash
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
                    #printf "Running docker command:\n"
                    if [[ -z "$4" ]]; then
                        docker run -it -p $1 -v $2 $3 bash
                    else
                        docker run -it -p $1 -v $2 --name $4 $3 bash
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
    if [[ $# == 0 ]]; then
        printf "$LRED No arguments passed.$CESC\n"
        printf "Usage example ---> dexec my_image\n"
        return
    else
        if [[ ! $# -gt 1 ]]; then
            printf "$LRED Too much arguments passed, only 1 required.$CESC\n"
            printf "Usage example ---> dexec my_image\n"
            return
        else
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
    docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'
}

# Shows current docker processes that match the search pattern
#
# for docker ps --filter name=<container_name|id> 
dgrep() {
    if [[ $# -ge 1 ]]; then
        docker ps --filter name=$1 --format 'table {{.ID}}\t{{.Names}}\t{{.Networks}}\t{{.Mounts}}\t{{.RunningFor}}\t{{.Status}}'
    else
        printf "$LRED No arguments passed.$CESC\n"
        printf "Usage example ---> dgrep my_image_name\n"
        return
    fi
    return
}

# Show the docker logs for a specific image
#
# can be used with flags:
#   -> -t <number_lines> , it returns the last number_lines from docker logs  
#   -> -d , it returns more details in logs
#
# for docker logs <container_name|id>
dlogs() {
    local number_lines=0
    local details=0
    local container_name=""
    
    # Flags passed
    if [[ $1 == "-t" ]] || [[ $1 == "-d" ]] && [[ $# -ge 1 ]]; then
        while test $# != 0
        do
            case "$1" in
            -t) 
                if [[ $# -ge 5 ]]; then
                    printf "Too much arguments\n"
                else
                    if [[ $2 = '-d' ]] || [[ -z $2 ]];then
                        printf "$LRED Incorrect usage, must declare a number of lines.$CESC\n"
                        return
                    elif [[ $3 = '-d' ]] && [[ ! -z $4 ]]; then
                        number_lines=$2
                        details=1
                        container_name=$4
                        shift
                    elif [[ ! -z $3 ]]; then
                        number_lines=$2
                        details=0
                        container_name=$3
                        shift
                    else
                        printf "Incorrect usage, no name for container provided"
                        return
                    fi
                fi
            ;;
            -d)
                if [[ $# -ge 5 ]]; then
                    printf "Too much arguments.\n"
                else
                    if [[ $2 = '-t' ]] && [[ $3 -eq 0 ]]; then
                        printf "$LRED Incorrect usage, must declare a number of lines.$CESC\n"
                        return
                    elif [[ $# -eq 4 ]] && [[ $2 = '-t' ]]; then
                        if [[ -z $4 ]]; then
                            printf "Incorrect usage, no container name provided"
                            return
                        else
                            if [[ $3 -eq 0 ]]; then
                                printf "$LRED Incorrect usage, must declare a number of lines.$CESC\n"
                                return
                            else
                                number_lines=$3
                                details=1
                                container_name=$4
                                shift
                            fi
                        fi
                    elif [[ $# -eq 2 ]]; then
                        if [[ -z $2 ]]; then
                            printf "Incorrect usage, no container name provided\n"
                            return
                        else
                            details=1
                            container_name=$2
                            shift
                        fi
                    fi
                fi
            ;;
            esac
            shift
        done

        if [[ $number_lines -ge 1 ]] && [[ $details -eq 0 ]]; then
            if [[ -z $container_name ]]; then
                printf "$LRED Incorrect usage, container name or id not passed.$CESC\n"
                return
            else
                printf "Running ---> docker logs --tail $number_lines $container_name\n"
                return
            fi
        elif [[ $number_lines -ge 1 ]] && [[ $details -eq 1 ]]; then
            if [[ -z $container_name ]]; then
                printf "$LRED Incorrect usage, container name of id not passed.$CESC\n"
                return
            else
                printf "Running ---> docker logs --details --tail $number_lines $container_name\n"
                return
            fi
        elif [[ $details -eq 1 ]] && [[ $number_lines -eq 0 ]]; then
            if [[ -z $container_name ]]; then
                printf "Incorrect usage, no container name provided.\n"
                return
            else
                printf "Running ---> docker logs --details $container_name\n"
                return
            fi
        else
            printf "$LRED Incorrect usage.$CESC\n"
            return
        fi

    # No flags passed
    elif [[ $# -eq 1 ]]; then
        printf "No flags passed.\n"
        printf "Runnning docker logs $1\n"
        return
    else
        printf "Incorrect usage.\n"
        return 
    fi
}

# Shows inspect output from docker inspect
#
# Can be used with flags:
#   -> -c for container inspect
#   -> -i for image inspect
#   -> both need to be followed by name or id
#
# for docker inspect
dinsp() {
    while test $# != 0
    do
        case "$1" in
            -c) # Check for -c flag
                if [[ -z $2 ]] || [[ $2 = '-i' ]]; then
                    printf "$LRED Container name not found.$CESC\n"
                    printf "Usage example ---> dinsp -c <container_name|id>\n"
                    return
                else
                    printf "Running ---> docker container inspect $2\n"
                    shift
                fi ;;
            -i) # Check for -i flag
                if [[ -z $2 ]] || [[ $2 = '-c' ]]; then
                    printf "$LRED Image name not found.$CESC\n"
                    printf "Usage example ---> dinsp -i <image_name|id>\n"
                    return
                else
                    printf "Running ---> docker image inspect $2\n"
                    shift
                fi ;;
        esac
        shift
    done 
}

#------------------------------------------------------------------------------ Remove Commands
# Cleans all docker images
#
# force cleans all docker images in order to clean docker environment, restarts docker after
#dclean() {
#
#}