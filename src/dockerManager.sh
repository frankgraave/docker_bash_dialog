#!/bin/bash

clear

# For the sake of simplicity, we declare vars for colors.
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
# Restore the color after you use it.
RESTORE='\033[0m'

# Folder name of current project.
project=${PWD##*/}

# Check for file in current dir.
dockerComposeFileExists=(`find ./ -maxdepth 1 -name "docker-compose.yml"`)

if [ $dockerComposeFileExists ]; then
  # Create empty array to store container names.
  declare -a containerNames=();

  while IFS= read -r line; do
    echo "${BLUE}Containers in docker-compose.yml file:${RESTORE}"
    # Search docker-compose file for container names
    # and remove trailing white space.
    container= grep -F "container_name: " | sed -e 's/^[ \t]*//'
    containerNames=("${containerNames[@]}" $container)
    # echo ${containerNames[@]}
  done < "${PWD}/docker-compose.yml"
else
  continue
fi

# Include the menuGenerator script.
source ~/bashproject/docker_bash_dialog/src/menuGenerator.sh

# First check if the docker-machine is running
# before we get the stuff we need.
dockerStatus=$(docker-machine status)
if [ $dockerStatus == "Running" ]; then
  # Get all running docker container names.
  containers=$(docker ps | awk '{if(NR>1) print $NF}')
  machine=$(docker-machine ip)
  host=$(hostname)

  # Loop through all containers and provide a list with
  # the running containers if there are any.
  if [ -z "${containers[@]:1}" ]; then
    echo "\r\n ${RED}There are currently no containers running!${RESTORE} \r\n"
    # Declare an array.
    declare -a options=("Return to menu" "Exit");

    # Generate the dialog with the script.
    generateDialog "options" "Project: $project - Choose an option" "${options[@]}"

    # Get the input.
    echo "\r\nPlease select your option: "
    # Read the choice.
    old_stty_cfg=$(stty -g)
    stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

    # Do something with the input.
    # if [ "$choice" == "1" ]; then
    if echo "$answer" | grep -iq "1" ; then
      unset $containers
      sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
    fi
    # Provide exit option.
    if echo "$answer" | grep -iq "0" ; then
      break
      clear
      echo "\r\nProgram has been terminated. Notice: there are no containers running."
    fi
  else
    echo "\r\n"
    echo "Docker machine IP: \r\n - ${PURPLE}$machine${RESTORE} \r\n"
    echo "${RESTORE}Current running containers:"
    for container in $containers
    do
      echo "${BLUE} - $container  ${RESTORE}"
    done
    echo "\r\n"

    # If for any reason the the containers array
    # is empty then we provide the option to
    # return to the main menu.
    if [ -z "${containers[@]:1}" ]; then
      # Declare an array.
      declare -a options=("Return to menu" "Exit");

      # Generate the dialog with the script.
      generateDialog "options" "Project: $project - Choose an option" "${options[@]}"

      # Get the input.
      echo "\r\nPlease select your option: "
      # Read the choice.
      old_stty_cfg=$(stty -g)
      stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

      # Do something with the input.
      # if [ "$choice" == "1" ]; then
      if echo "$answer" | grep -iq "1" ; then
        unset $containers
        sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
      fi
      # Provide exit option.
      if echo "$answer" | grep -iq "0" ; then
        break
        clear
        echo "\r\nProgram has been terminated. Notice: there are no containers running."
      fi

    # If there are containers running then you can choose to
    # stop all the running containers or simply return to the
    # menu if you like.
    else
      # Declare an array.
      declare -a options=("Stop all active containers" "Return to menu" "Exit");

      # Generate the dialog with the script.
      generateDialog "options" "Project: $project - Choose an option" "${options[@]}"

      # Get the input.
      echo "\r\nPlease select your option: "
      # Read the choice.
      old_stty_cfg=$(stty -g)
      stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

      # Do something with the input.
      # if [ "$choice" == "1" ]; then
      if echo "$answer" | grep -iq "1" ; then
        unset $containers
        docker stop $(docker ps -a -q)
        sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
      fi

      # if [ "$choice" == "2" ]; then
      if echo "$answer" | grep -iq "2" ; then
        unset $containers
        sh ~/bashproject/docker_bash_dialog/src/startMenu.sh
      fi

      # Provide exit option.
      if echo "$answer" | grep -iq "0" ; then
        break
        clear
        echo "\r\nProgram has been terminated. Containers are still running."
      fi
    fi
  fi
else
  echo "\r\nYour docker-machine is not running. Please start your docker-machine first!"
fi
