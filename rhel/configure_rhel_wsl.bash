#!/bin/bash

## Variables
## Git configuration
FULL_NAME="Jason Dickerson"
EMAIL=jason.dickerson@gmail.com
export GIT_USER=jasondickerson
export GIT_TOKEN=
export GIT_HOST=github.com

## registry.redhat.io credentials
RH_USER=
RH_PASSWORD=''

## Red Hat Automation Hub token for ansible collection downloads
export RH_AH_TOKEN=''

## Configure non-root ping
sudo setcap "cap_net_admin,cap_net_raw+p" /usr/bin/ping

## Register to and Configure Repositories
sudo subscription-manager register --username ${RH_USER} --password ${RH_PASSWORD}
sudo subscription-manager repos --enable ansible-automation-platform-2.6-for-rhel-9-x86_64-rpms

## Set Package Manager Variable
## actions to fix / mount for podman and install envsubst command
PKG_MGR="sudo dnf -y"
## interactive: possible prompt for sudo password
sudo mount --make-rshared /
${PKG_MGR} install gettext ansible-navigator vim-enhanced man-db tree python3.11-pip wget coreutils-common file dos2unix

## Upgrade OS
${PKG_MGR} --refresh upgrade

## Make / mount change to fix podman persistent
grep 'sudo mount --make-rshared /' ~/.bashrc &> /dev/null
if [ ${?} -ne 0 ] ; then
    echo 'sudo mount --make-rshared /' >> ~/.bashrc
fi

## Start WSL User in home directory like normal linux
if [ "$(grep -v ^$ .bashrc | tail -n1)" != "cd" ] ; then 
    echo 'cd' >> ~/.bashrc
fi

## Configure git
git config --global http.sslverify true
git config --global credential.helper store
git config --global user.name "${FULL_NAME}"
git config --global user.email ${EMAIL}

envsubst << '__EOF__' | git credential approve
protocol=https
host=${GIT_HOST}
username=${GIT_USER}
password=${GIT_TOKEN}

__EOF__

unset GIT_USER
unset GIT_TOKEN

## authenticate to registry, pull EE base image
podman login --authfile ${HOME}/.config/containers/auth.json registry.redhat.io --username ${RH_USER} --password "${RH_PASSWORD}"
podman pull registry.redhat.io/ansible-automation-platform-26/ee-supported-rhel9:latest

## configure ansible.cfg
if [ ! -f ~/.ansible.cfg ] ; then
  envsubst > ~/.ansible.cfg << '__EOF__'
[galaxy]
server_list = automationhub,validated_ah,galaxy

[galaxy_server.galaxy]
url=https://galaxy.ansible.com/

[galaxy_server.automationhub]
url=https://console.redhat.com/api/automation-hub/content/published/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token=${RH_AH_TOKEN}

[galaxy_server.validated_ah]
url=https://console.redhat.com/api/automation-hub/content/validated/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token=${RH_AH_TOKEN}

__EOF__

fi

unset RH_AH_TOKEN

## Configure ansible-navigator
if [ ! -f ~/.ansible-navigator.yml ] ; then
  cat > ~/.ansible-navigator.yml << '__EOF__'
---
ansible-navigator:
  execution-environment:
    pull:
      policy: missing
  playbook-artifact:
    enable: false
  logging:
    file: ~/ansible-navigator.log
#  mode: stdout
...
__EOF__

fi

## generate ssh key pair
if [ ! -f ~/.ssh/id_rsa ] ; then
  ssh-keygen -N '' -f ~/.ssh/id_rsa
fi

## Check for reboot
sudo dnf needs-restarting -r

## Reboot message
echo If reboot is necessary:
echo "1) Exit WSL"
echo "2) Shutdown WSL via command prompt:  wsl --shutdown"
echo "3) Restart WSL via command prompt:   wsl -d RHEL"
