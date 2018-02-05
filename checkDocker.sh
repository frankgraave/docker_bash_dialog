#!/bin/bash

clear

# For the sake of simplicity, declare vars for colors
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
# Restore the color after you use it
RESTORE='\033[0m'

# Include the menuGenerator script
source ~/bash_scripts/menuGenerator.sh

# Get all running docker container names
containers=$(docker ps | awk '{if(NR>1) print $NF}')
machine=$(docker-machine ip)
host=$(hostname)

# Loop through all containers and provide a list with
# the running containers if there are any
if [ -z "${containers[@]:1}" ]; then
  echo "\r\n ${RED}There are currently no containers running!${RESTORE} \r\n"
  # Declare an array
  declare -a options=("Return to menu");
  # Generate the dialog with the script
  generateDialog "options" "Choose an option" "${options[@]}"
  # Get the input
  echo "Please select your option and press [ENTER]: "
  read choice
  # Do something with the input
  if [ "$choice" == "1" ]; then
    unset $containers
    sh ~/bash_scripts/ben_menu.sh
  fi
else
  echo " "
  echo " "
  echo "Docker machine IP: \r\n - ${PURPLE}$machine${RESTORE} \r\n"
  echo "${RESTORE}Current running containers:"
  for container in $containers
  do
    ports="$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' $container)"
    echo "${BLUE} - $container  ${RESTORE}-> Exposed ports:${PURPLE}$ports${RESTORE}"
  done
  echo " "
  echo " "

  # If the containers array is empty then we provide
  # the option to return to the main menu
  if [ -z "${containers[@]:1}" ]; then
    # Declare an array
    declare -a options=("Return to menu");
    # Generate the dialog with the script
    generateDialog "options" "Choose an option" "${options[@]}"
    # Get the input
    echo "Please select your option and press [ENTER]: "
    read choice
    # Do something with the input
    if [ "$choice" == "1" ]; then
      unset $containers
      sh ~/bash_scripts/ben_menu.sh
    fi
  # If there are containers running then you can choose to
  # stop all the running containers or simply return to the
  # menu if you like
  else
    declare -a options=("Stop all containers" "Return to menu");

    generateDialog "options" "Choose an option" "${options[@]}"

    echo "Please select your option and press [ENTER]: "
    read choice

    if [ "$choice" == "1" ]; then
      unset $containers
      docker-clean -s
      sh ~/bash_scripts/ben_menu.sh
    fi

    if [ "$choice" == "2" ]; then
      unset $containers
      sh ~/bash_scripts/ben_menu.sh
    fi
  fi
fi
