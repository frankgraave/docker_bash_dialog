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
project=$(basename $(dirname ${PWD}))/$(basename ${PWD})

# Check for file in current dir.
dockerComposeFileExists=(`find ./ -maxdepth 1 -name "docker-compose.yml"`)

if [ $dockerComposeFileExists ]; then
  # Create empty array to store container names.
  declare -a containerNames
  while IFS= read -r line; do
    echo ""
    echo "${LIGHTGRAY}All available containers in $project:${RESTORE}"
    # Search docker-compose file for container names.
    container=$(grep -F 'container_name: ' | sed -e 's/^[ \t]*//' | cut -d ":" -f 2)
    # Append container in array.
    containerNames=("${containerNames[@]}" "$container")
  done < "${PWD}/docker-compose.yml"
else
  continue
fi

# Print array of containers found in the docker-compose.yml file.
for container in $containerNames
do
  echo "${YELLOW} - $container  ${RESTORE}"
done

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
    declare -a options=("Start the $project containers" "Return to menu" "Exit");

    # Generate the dialog with the script.
    generateDialog "options" "Project: $project - Choose an option" "${options[@]}"

    # Get the input.
    echo "\r\nPlease select your option: "
    # Read the choice.
    old_stty_cfg=$(stty -g)
    stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

    # Do something with the input.
    if echo "$answer" | grep -iq "1" ; then
      clear
      docker-compose up -d
      sh ~/bashproject/docker_bash_dialog/src/dockerManager.sh
    fi
    # Do something with the input.
    if echo "$answer" | grep -iq "2" ; then
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
    echo ""
    echo "${LIGHTGRAY}Docker machine is running at:${RESTORE} \r\n - ${GREEN}$machine${RESTORE} \r\n"
    echo "${LIGHTGRAY}Current running containers:${RESTORE}"
    for container in $containers
    do
      echo "${GREEN} - $container  ${RESTORE}"
    done
    echo ""

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
      declare -a options=("Stop all active containers" "Restart all $project containers" "Recreate all $project containers" "Return to menu" "Exit");

      # Generate the dialog with the script.
      generateDialog "options" "Project: $project - Choose an option" "${options[@]}"

      # Get the input.
      echo "\r\nPlease select your option: "
      # Read the choice.
      old_stty_cfg=$(stty -g)
      stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

      # Do something with the input.
      if echo "$answer" | grep -iq "1" ; then
        unset $containers
        docker stop $(docker ps -a -q)
        sh ~/bashproject/docker_bash_dialog/src/dockerManager.sh
      fi

      if echo "$answer" | grep -iq "2" ; then
        unset $containers
        clear
        echo "Restarting containers..."
        sleep 0.2s
        docker-compose restart
        sleep 0.5s
        sh ~/bashproject/docker_bash_dialog/src/dockerManager.sh
      fi

      if echo "$answer" | grep -iq "3" ; then
        unset $containers
        clear
        echo "Recreating containers..."
        sleep 0.2s
        docker-compose up -d --force-recreate
        sleep 0.5s
        sh ~/bashproject/docker_bash_dialog/src/dockerManager.sh
      fi

      if echo "$answer" | grep -iq "4" ; then
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
