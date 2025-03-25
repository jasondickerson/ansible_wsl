#!/bin/bash
sudo dnf --refresh upgrade
sudo dnf needs-restarting
if [ ${?} != 0 ] ; then
  echo 'Please exit your WSL Shells, run "wsl --shutdown", and restart your WSL'
fi