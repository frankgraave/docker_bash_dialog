#!/bin/bash

# Include the menuGenerator script.
source ~/bashproject/docker_bash_dialog/src/menuGenerator.sh

# Var to check if a file exists in the current dir.
cpwd=$(pwd)
dockerComposeFileExists=(`find ./ -maxdepth 1 -name "docker-compose.yml"`)

# Check containers.
containers=$(docker ps | awk '{if(NR>1) print $NF}')

# Folder name of current project.
project=$(basename $(dirname ${PWD}))/$(basename ${PWD})

# Start clean.
echo "\r\n"
clear
echo "\r\n"

if ! [ $dockerComposeFileExists ]; then
  echo "\r\n Oh-oh! There is no docker-compose.yml file in the '$project' directory. \r\n"
  break
else
  # First check if the docker-machine is running
  # before we get the stuff we need.
  dockerStatus=$(docker-machine status)
  if [ $dockerStatus == "Running" ]; then
    # Get all running docker container names.
    containers=$(docker ps | awk '{if(NR>1) print $NF}')
    machine=$(docker-machine ip)
    host=$(hostname)

    # If there is a docker-compose file in the current workdir
    # and there are no containers running, then we provide
    # the option to start the containers of this Project.
    if [ $dockerComposeFileExists ] && [ -z "${containers[@]:1}" ]; then
      declare -a options=("Check containers" "Start the ${PWD##*/} containers" "Remove stopped containers" "Exit");
      generateDialog "options" "Project: $project" "${options[@]}"

      echo "\r\nPlease select your option: "
      # Read the choice.
      old_stty_cfg=$(stty -g)
      stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

      if echo "$answer" | grep -iq "1" ; then
        clear
        sh ~/bashproject/docker_bash_dialog/src/dockerManager.sh
      fi

      if echo "$answer" | grep -iq "2" ; then
        clear
        docker-compose up -d
        sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
      fi

      if echo "$answer" | grep -iq "3" ; then
        # Ask again, just to be sure you don't mess up.
        echo "\r\nThis will delete all your stopped containers, do you wish to continue? (y/n)"
        echo "(Only use this if you have trouble starting up due to other docker projects)"
        # Read the choice.
        old_stty_cfg=$(stty -g)
        stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg
        if echo "$answer" | grep -iq "^y" ; then
          docker ps -aq --no-trunc | xargs docker rm
          clear
          sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
        else
          echo "Aborting..."
          sleep 1s
          sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
        fi
      fi

      if echo "$answer" | grep -iq "0" ; then
        break
        clear
        echo "\r\nProgram has been terminated. Notice: there are no containers running."
      fi
    fi

    # If there are active containers running, then we simply
    # show the following options.
    if [ "${containers[@]:1}" ]; then
      declare -a options=("Show the active containers" "Stop all containers" "Exit");
      generateDialog "options" "Project: ${PWD##*/}" "${options[@]}"

      echo "\r\nPlease select your option: "
      # Read the choice.
      old_stty_cfg=$(stty -g)
      stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

      if echo "$answer" | grep -iq "1" ; then
        clear
        sh ~/bashproject/docker_bash_dialog/src/dockerManager.sh
      fi

      if echo "$answer" | grep -iq "2" ; then
        docker-clean -s
        clear
        sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
      fi

      if echo "$answer" | grep -iq "0" ; then
        if [ "${containers[@]:1}" ]; then
          break
          clear
          echo "\r\n Program has been terminated. Containers are still running."
        elif [ -z "${containers[@]:1}" ]; then
          break
          clear
          echo "\r\n Program has been terminated. Notice: there are no containers running."
        fi
      fi
    fi
  else
    echo "\r\nYour docker-machine is not running. Please start your docker-machine first!"
  fi
fi
