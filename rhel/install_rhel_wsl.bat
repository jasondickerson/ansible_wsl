@echo off
cd $HOME
wsl --import RHEL .\WSL\RHEL .\Downloads\rhel-9.7-x86_64-wsl2.wsl
wsl -s RHEL
wsl --manage RHEL --set-default-user cloud-user
