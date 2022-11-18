#!/usr/bin/env bash

#----------------------------------------------------------------------------Help and Documentation
dbuddy() {
    printf "\
    ############################################### [$LGREEN DOCKER BUDDY$CESC ] ####################################################
    #                                                                                                                   #
    #  $LYELLOW Author: Ruben Pereira$CESC                                                                                           #
    #  $LYELLOW Version: 1.0.0$CESC                                                                                                  #
    #                                                                                                                   #
    #   ---> This is a bash script for docker useful comands that can be used in a daily basis,                         #
    #   it has a lot docker commands that a lot of times are used repeatedly over and over again,                       #
    #   sometimes with the same flags. For example, a common command:                                                   #
    #                                                                                                                   #
    #          $=====================================================================$                                  #
    #          |                                                                     |                                  #
    #          |   Docker normal command                                             |                                  #
    #          |   --> docker run -d -p 443:443 my_container --name my_container     |                                  #
    #          |                                                                     |                                  #
    #          |   Equivalent Docker Buddy command:                                  |                                  #
    #          |   --> drun 443:443 my_container my_container                        |                                  #
    #          |                                                                     |                                  #
    #          $=====================================================================$                                  #
    #                                                                                                                   #
    #   ---> Docker Buddy aims to be an alias for shorter docker commands and to spare a little                         #
    #   time when building, running and inspecting docker processes.                                                    #
    #                                                                                                                   #
    #========================================== [$LGREEN COMMANDS & EXAMPLES$CESC ] ================================================#
    #                                                                                                                   #
    #   --->$LGREEN dbuild <container_name> <directory>$CESC                                                                        #
    #        -> example:$LYELLOW dbuild my_container /mydir$CESC                                                                     #
    #                                                                                                                   #
    #   --->$LGREEN drun <ext_port:int_port> <container_name> <image_name>$CESC                                                     #
    #        -> example:$LYELLOW drun 8000:80 my_container my_custom_name$CESC                                                       #
    #                                                                                                                   #
    #   --->$LGREEN dmrun <ext_port:int_port> <ext_directory:int_directory> <container_name> <image_name>$CESC                      #
    #        -> example:$LYELLOW dmrun 443:443 /home/my_dir:/docker/docker_dir my_container my_image_name $CESC                      #                  
    #                                                                                                                   #
    #   --->$LGREEN ditrun <ext_port:int_port> <container_name> <image_name>$CESC                                                   #
    #        -> example:$LYELLOW ditrun 8000:80$CESC                                                                                 #
    #                                                                                                                   #
    #   --->$LGREEN dexec <image_name>$CESC                                                                                         #
    #        -> example:$LGREEN dexec my_image$CESC                                                                                 #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #                                                                                                                   #
    #####################################################################################################################\n"
}

dhelp() {
    printf "\
    DOCKER BUDDY COMMANDS
    ------------------------------------------------------------------------------------------
    BUILD
    
    Buddy  --->$LGREEN dbuild <container_name> <directory>$CESC
    Normal --->$LYELLOW docker build -t <container_name> <directory> $CESC

    ------------------------------------------------------------------------------------------
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

# Testing port bind pattern
test_port_bind() {
    if [[ ! "$1" =~ $PORT_BIND_REGEX ]]; then
        return 0
    fi
    return 1
}

# Testing directory mapping pattern
test_dir_bind() {
    if [[ ! "$2" =~ $DIR_BIND_REGEX ]]; then
        return 0
    fi
    return 1
}

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
        if test_port_bind; then
            if [ -z "$3" ]; then
                printf "No image name passed in arguments, docker will create one random.\n"
                printf "Running docker command:\n"
                printf "docker run -d -p $1 $2\n"
                docker run -d -p $1 $2
            else
                printf "Running docker command:\n"
                printf "docker run -d -p $1 $1 --name $3\n"
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
}

# Runs a docker container with volume mount
#
# for docker run -d -p <ext_port:int_port> -v <ext_directory:int_directory> <container_name> --name <image_name>*
# * image_name is optional
dmrun() {
    # Checking if no arguments passed
    if [[ $# == 0 ]]; then
        printf "$LRED-> No arguments passed.$CESC\n"
        printf "Usage example ---> dmrun 443:443 '/home/ubnutu/my_dir:/docker/my_docker_dir' 'my_container_tag' 'my_image_name'\n"
        return
    fi

    # Command needs at least 3 arguments to run
    if [[ $# -ge 3 ]]; then
        # Testing port bind pattern
        if ! test_port_bind; then
            printf "$LRED Port bind pattern incorrect.$CESC\n"
            return
        # Testing directory mapping pattern
        elif ! test_dir_bind; then
            printf "$LRED Directory bind patter incorrect\n"
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
        if test_port_bind; then
            printf "Running docker command:\n"
            if [[ -z "$#" ]]; then
                printf "docker run -it $1 $2 bash\n"
                docker run -it $1 $2 bash
            else
                printf "docker run -it $1 $2 --name $3 bash\n"
                docker run -it $1 $2 --name $3 bash
            fi
        else
            printf "Port binding incorrect.\n"
            return
        fi
    else 
        printf "$LRED Too few arguments.\n"
        printf "Usage example ---> ditrun 443:443 'my_container_tag' 'my_image_name'\n"
        return
    fi
}

# Runs a docker container with a mounted volume and starts a bash shell immediately after
#
# for docker run -it -p <ext_port:int_port> -v <ext_directory:int_directory> <container_name> --name <image_name>* bash
# * image_name is optional
dmitrun() {

}

# Runs a bash shell inside of a docker image
#
# for docker exec -it <image_name> bash
dexec() {

}

#------------------------------------------------------------ Inspect Docker Processes Commands
# Shows current docker processes, including IP addresses and RAM usage
#
# for docker ps
dps() {

}

# Shows current docker processes that match the search pattern
#
# for docker ps | grep <pattern>
dpgrep() {

}

#------------------------------------------------------------------------------ Remove Commands
# Cleans all docker images
#
# force cleans all docker images in order to clean docker environment, restarts docker after
dclean() {

}