#!/bin/bash
source ~/bash_scripts/menuGenerator.sh

# Function to check if a file exists in the current dir.
cpwd=$(pwd)
dockerComposeFileExists=(`find ./ -maxdepth 1 -name "docker-compose.yml"`)

# Check containers
containers=$(docker ps | awk '{if(NR>1) print $NF}')

# Folder name of current project
project=${PWD##*/}

# Start clean
echo " "
clear
echo " "

# If there is a docker-compose file in the current workdir
# and there are no containers running, then we provide
# the option to start the containers of this Project
if [ $dockerComposeFileExists ] && [ -z "${containers[@]:1}" ]; then
  declare -a options=("Start the $project containers" "Remove stopped containers (If you have trouble starting up)" "Exit");
  generateDialog "options" "Project: ${PWD##*/}" "${options[@]}"

  echo "Please select your option and press [ENTER]: "
  read choice

  if [ "$choice" == "1" ];
  then
    clear
    docker-compose up -d
    sh ~/bash_scripts/ben_menu.sh
  fi

  if [ "$choice" == "2" ];
  then
    docker-clean run
    clear
    sh ~/bash_scripts/ben_menu.sh
  fi

  if [ "$choice" == "0" ];
  then
    break
    clear
    echo "Program has been terminated."
  fi
else
  if ! [ $dockerComposeFileExists ]; then
    echo "\r\n Sorry, there's no docker-compose.yml file in this directory. \r\n"
  fi
fi

# If there are active containers running, then we simply
# show the following options
if [ "${containers[@]:1}" > 0 ]; then
  declare -a options=("Show the active containers" "Stop all containers" "Exit");
  generateDialog "options" "Project: ${PWD##*/}" "${options[@]}"

  echo "Please select your option and press [ENTER]: "
  read choice

  if [ "$choice" == "1" ];
  then
    clear
    sh ~/bash_scripts/checkDocker.sh
  fi

  if [ "$choice" == "2" ];
  then
    docker-clean -s
    clear
    sh ~/bash_scripts/ben_menu.sh
  fi

  if [ "$choice" == "0" ];
  then
    break
    clear
    echo "Program has been terminated."
  fi
fi
