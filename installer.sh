#!/bin/bash

# Start clean.
clear

shopt -s expand_aliases

# Declare vars.
user=$(eval echo ~$USER)
currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Declare functions.
function checkDestinationAndCreate() {
  # Create destination folder.
  if [ -d "$user/$foldername" ]; then
    echo "Sorry, this folder already exists. Please try again!"
    promptInstallDir
  else
    echo ""
    echo "Creating new directory: $user/$foldername"
    mkdir ${DESTINATION}
    echo ""
    echo "Copying files..."
    cp -r $currentDir/src/. $user/$foldername
  fi
}

function promptInstallDir() {
  echo ""
  echo "What should the folder's name be?"
  echo ""
  read foldername
  # Set destination variable.
  DESTINATION="$user/$foldername"
  # Re-run the check.
  checkDestinationAndCreate
}

function finishAndCleanup() {
  rm -rf $currentDir
}

# Install prompt.
echo "This will install Docker Bash Dialog. Do you wish to continue? (y/n)"
old_stty_cfg=$(stty -g)
stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ; then

  # Run the install function.
  promptInstallDir

  # TODO find with $SHELL which bashrc or zshrc and insert the alias there.
  echo "\r\nDo you want to give the Docker Bash Dialog an alias?\r\n(This creates an alias for you, leave empty and hit enter if you don't want to set an alias)"
  read al
  if [ $al ]; then
    alias $al="sh ~$foldername/src/startMenu.sh"
  else
    continue
  fi

  echo ""
  echo "Installation complete."
  echo ""
  # Exit from the script with success (0).
  exit 0
else
  echo No
fi
