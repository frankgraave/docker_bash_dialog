#!/bin/bash

# Include the menuGenerator script.
source ~/bash_scripts/menuGenerator.sh

# Var to check if a file exists in the current dir.
cpwd=$(pwd)
dockerComposeFileExists=(`find ./ -maxdepth 1 -name "docker-compose.yml"`)

# Check containers.
containers=$(docker ps | awk '{if(NR>1) print $NF}')

# Folder name of current project.
project=${PWD##*/}

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
      declare -a options=("Start the $project containers" "Remove stopped containers (Use if you have trouble starting up)" "Exit");
      generateDialog "options" "Project: ${PWD##*/}" "${options[@]}"

      echo "\r\nPlease select your option and press [ENTER]: "
      read choice

      if [ "$choice" == "1" ]; then
        clear
        docker-compose up -d
        sh ~/bash_scripts/startMenu.sh
      fi

      if [ "$choice" == "2" ]; then
        docker-clean run
        clear
        sh ~/bash_scripts/startMenu.sh
      fi

      if [ "$choice" == "0" ]; then
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

      echo "\r\nPlease select your option and press [ENTER]: "
      read choice

      if [ "$choice" == "1" ]; then
        clear
        sh ~/bash_scripts/dockerManager.sh
      fi

      if [ "$choice" == "2" ]; then
        docker-clean -s
        clear
        sh ~/bash_scripts/startMenu.sh
      fi

      if [ "$choice" == "0" ]; then
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
