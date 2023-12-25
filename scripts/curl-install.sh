#!/bin/bash

# Checking if is running in Repo Folder
if [[ "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')" =~ ^scripts$ ]]; then
    echo "You are running this in Turbine Folder."
    echo "Please use ./turbune.sh instead"
    exit
fi

# Installing git

echo "Installing git."
pacman -Sy --noconfirm --needed git glibc

echo "Cloning the TurbineOS Project"
git clone https://github.com/CaptainsCrew/TurbineOS

echo "Executing TubineOS Script"

cd $HOME/TurbineOS

exec ./turbine.sh
