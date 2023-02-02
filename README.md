# Docker Buddy
> by Ruben Pereira, v1.1.0

## Index
- [Introduction](#introduction)

- [Install the Docker Buddy](#install-the-docker-buddy)

- [Commands](#commands)
    - [Docker](#docker)
        - [dbuddy](#dbuddy-command)
        - [dbuild](#dbuild-command)
        - [drun](#drun-command)
        - [dmrun](#dmrun-command)
        - [ditrun](#ditrun-command)
        - [dmitrun](#dmitrun-command)
        - [dexec](#dexec-command)
        - [dps](#dps-command)
        - [dgrep](#dgrep-command)
        - [dlogs](#dlogs-command)
        - [dinsp](#dinsp-command)
        - [dlist](#dlist-command)
        - [dclean](#dclean-command)

    - [Docker-Compose](#docker-compose)
        - [dcup](#dcup-command)
        - [dcbuild](#dcbuild-command)

    - [Docker Swarm](#docker-swarm)
        - [dswarm](#dswarm-command)

## Introduction
The main objective is to help the IT enthusiastic human beigns with docker commands. It's just a big set of ready to use and tested docker aliases. (Only working in linux, for now...).

Docker buddy holds support to a variety of docker commands, as well docker-compose and docker swarm and stack commands.

For instances if we want to build a docker container just use the following code (*see next section for further information*):

`dbuild my_container`

## Install the Docker Buddy
It's quite easy, after making the git clone command of the repository, switch to the folder with `cd docker-buddy/` and do the following: 

```bash
1st -> chmod +x ./docker-buddy-install.sh

2nd -> ./docker-buddy-install.sh

3rd -> you are welcome buddy :D
```

## Commands

### Docker

---

- #### dbuddy command
    - The **dbuddy** command can be used with two flags ***-v*** or ***-h***, both are well known typical linux environment flags. One gives the version, the other one offers help, accordingly. Let's see an example:

    `dbuddy -v`

    `dbuddy -h`

---

- #### dbuild command
    - The **dbuild** command enables a quick interaction with the common command docker build where a path for a docker file can be included. Let's see the 2 possible use cases:

    `dbuild my_container`

    `dbuild my_container path/to/my/Dockerfile`

---

- #### drun command
    - The **drun** command enables the user to quickly run a docker container with minimum command line usage (*an image name can be passed or not as option*), the use cases for this command are the following:

    `drun 80:80 my_container`

    `drun 80:80 my_container my_image`

---

- #### dmrun command
    - The **dmrun** command lets the user pass the port binding for the container and also volume binding can be applied, the volume binding as the port binding must be the same as in docker command. The use cases for the command are:

    `dmrun 80:80 /home:/path/in/container my_container`

    `dmrun 80:80 /home:/path/in/container my_container my_image`

---

- #### ditrun command
    - The **ditrun** command enables the user not only run a docker container as well as entering the docker container cli immediately. The sintax is as follows:

    `ditrun 80:80 my_container`

    `ditrun 80:80 my_container my_image`

---

- #### dmitrun command
    - The **dmitrun** command is similar to **ditrun**, but as **dmrun** enables the user to prompt a volume binding. The use cases are:

    `dmitrun 80:80 /home:/path/in/container my_container`

    `dmitrun 80:80 /home:/path/in/container my_container my_images`

---

- #### dexec command
    - The **dexec** command is a simple implementation of the docker exec command. The approach is:

    `dexec my_container`

    - Simple as that, you enter the container cli.

---

- #### dcreate command
    - The **dcreate** command is a interpretation for the docker <network|secret|volume> create command.

    - The usage is as follows:

    `dcreate -n <bridge|overlay> my_network`

    `dcreate -s my_secret_name my_secret_value`

    `dcreate -v my_volume`

---

- #### dps command
    - The **dps** command is a short alias with a specific output, it returns the container ID, the container name, networks, volumes and status. Usage:

    `dps`

---

- #### dgrep command
    - The **dgrep** command is an alias to output docker ps results and filter by container name. Usage:

    `dgrep my_container`

---

- #### dlogs command
    - The **dlogs** command returns the logs for a container or image, given an ID. The user can pass two flags combined in order to get different outputs. `-t` or `-d`. The first one must be followed by an integer. The second, like the first one is optional. `-d` is used for more details and `-t` to tail the results, i.e the last lines of logs encountered. The usage is:

    `dlogs my_container_id`

    `dlogs -d my-container_id`

    `dlogs -d -t 30 my_container_id`

---

- #### dinsp command
    - The **dinsp** command returns the user the output of the docker inspect command,
    with a simple flag, containers, images or networks can be inspected (*must be followed by ID*). Usage is as follows:

    `dinsp -c my_container`

    `dinsp -i my_image`

    `dinsp -n my_network`

---

- #### dlist command
    - The **dlist** command can combine multiple docker ls commands in one output, imagine you want to list the images and the containers, use the `-i` and `-c` flags, like so: `dlist -i -c`. The flags are:

    `-c --containers for containers`

    `-i or --images for images`

    `-n or --networks for networks`

    `-s or --services for services`

    `-S or --secrets for secrets`

    `-v or --volumes for volumes`

---

- #### dclean command
    - **N.B** - This command force cleans the desired docker "service".

    - The **dclean** command can be used with flags to clean up any image, container, secret and so on. The usage is: `dclean -i -c` here with two flags both images and containers are going to be clean.

    - The flags are:

    `-c --containers for containers`

    `-i or --images for images`

    `-n or --networks for networks`

    `-s or --secrets for secrets`

    `-v or --volumes for volumes`

### Docker-Compose

---

- #### dcup command
    - The **dcup** command enables the user to get support for docker-compose up command, the command will execute 
    docker-compose up command with -d by default, to deploy the services in detached mode.

    - The command can be used with two flags: `-b` or `-s`, with the first one enables the docker-compose up to build the image before and the second one is to specify a service (***it only supports 1 for now...***).

    - The command usage is as follows:
    
    `dcup`

    `dcup -b`

    `dcup -b -s my_service`

---

- #### dcbuild command
    - The **dcbuild** command it is similar to the dcup, bu doesn't start the container. It only builds the context.

    - The command can be used with 2 flags: `-n` and `-s`, like before the second one is to specify a service, the first one is to do a build context with no cache.

    - Usage is as follows:

    `dcbuild`

    `dcbuild -n`

    `dcbuild -n -s my_service`

### Docker Swarm

---

- #### dswarm command
    - The **dswarm** command enables the user to start a docker swarm, to get the tokens to add a worker or a manager or join a docker swarm with the generated token.

    - The command has 4 flags and the usage is as follows: (***only one flag supported***)

    `dswarm -i` - Starts a docker swarm

    `dswarm -w` - Generates a join token for a worker

    `dswarm -m` - Generates a join token for a manager

    `dswarm -j <token>` - For a node to join a swarm