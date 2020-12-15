#!/bin/bash
echo "Welcome it will take a little bit of time"

# control if you are root 
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# changing ownership
sudo chown -R $USER:staff .config
sudo chown $USER:staff .profile
sudo chown $USER:staff .zprofile

cd

echo "Made by: Jac-Zac"
