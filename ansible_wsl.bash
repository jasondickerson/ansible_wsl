#!/bin/bash

## Tested with Windows 10 and 11 WSL2 with following OS's:
## (Default WSL2) Ubuntu 22.04.4 LTS
## Fedora WSL by Vineel Sai, available for Free on the Microsoft Store

## Variables
## Git configuration
FULL_NAME="Jason Dickerson"
EMAIL=jason.dickerson@gmail.com
export GIT_USER=jasondickerson
export GIT_TOKEN=
export GIT_HOST=github.com

## Get OS ID Variable
source /etc/os-release

## Set Package Manager Variable
## Fedora actions to fix / mount for podman and install envsubst command
case ${ID} in

  fedora)
    PKG_MGR="sudo dnf -y"
    ## interactive: possible prompt for sudo password
    sudo mount --make-rshared /
    ${PKG_MGR} install gettext-envsubst
    ;;

  ubuntu)
    PKG_MGR="sudo apt-get -y"
    ;;

  *)
    echo "Unknown OS"
    exit 1
    ;;

esac

## Configure sudo
if [ ! -f /etc/sudoers.d/${USER} ] ; then
  envsubst > ~/${USER} << '__EOF__'
${USER}   ALL=(ALL) NOPASSWD: ALL
__EOF__

  sudo chown root:root ~/${USER}
  sudo chmod 0440 ~/${USER}
  sudo mv ~/${USER} /etc/sudoers.d
fi

## Upgrade OS
case ${ID} in

  fedora)
    ${PKG_MGR} update
    ## fix shadow-utils capabilities for podman
    ${PKG_MGR} reinstall shadow-utils
    ;;

  ubuntu)
    ${PKG_MGR} update
    ${PKG_MGR} upgrade
    ;;

esac

#### Possible pkgs for Ubuntu
# sudo apt-get install curl wget gnupg2

## Install required os packages
${PKG_MGR} install podman python3-pip tree

## Install Community Ansible Navigator
python3 -m pip install ansible-navigator --user

## Add Ansible commands to the PATH
## Set Profile Variable
case ${ID} in

  fedora)
    USER_PROFILE=".bash_profile"
    ;;

  ubuntu)
    USER_PROFILE=".profile"
    ;;

esac

grep 'export PATH=$HOME/.local/bin:$PATH' ~/${USER_PROFILE} &> /dev/null
if [ ${?} -ne 0 ] ; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/${USER_PROFILE}
fi
source ~/${USER_PROFILE}

## Make / mount change to fix podman persistent
## Configure Fedora WSL to boot using systemd
case ${ID} in

  fedora)
    grep 'sudo mount --make-rshared /' ~/.bashrc &> /dev/null
    if [ ${?} -ne 0 ] ; then
      echo 'sudo mount --make-rshared /' >> ~/.bashrc
    fi

    if [ ! -f /etc/wsl.conf ] ; then 
      cat > ~/wsl.conf << '__EOF__'

[boot]
systemd=true
__EOF__

      sudo mv ~/wsl.conf /etc/wsl.conf
      sudo chown root:root /etc/wsl.conf
      sudo chmod 0644 /etc/wsl.conf
    fi
    ;;

esac

## Create required directories
mkdir -p ~/.ansible/collections
mkdir -p ~/.ansible/plugins/modules
mkdir -p ~/exec_envs
mkdir -p ~/git-repos

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

## Configure gitignore
if [ ! -f ~/git-repos/sample_gitignore ] ; then
  cat > ~/git-repos/sample_gitignore << '__EOF__'
.gitignore
.vscode
ansible.cfg
.secret
ansible-navigator.yml
__EOF__

fi

## Configure Sample Ansible configuration file for ansible-vault
if [ ! -f ~/git-repos/sample_ansible_cfg ] ; then
  cat > ~/git-repos/sample_ansible_cfg << '__EOF__'
[defaults]
vault_password_file = .secret
__EOF__

fi

## Instruct Fedora WSL User to restart WSL to boot via systemd
## This is required for podman usage
case ${ID} in

  fedora)
    echo "If this is your first script run, please perform the following steps to enable systemd:"
    echo ""
    echo "  - exit all WSL Shells"
    echo "  - from a cmd.exe or powershell.exe prompt, run wsl --shutdown"
    echo "  - launch the Fedora application"
    echo ""
    echo "Fedora WSL is now booted via systemd"
    echo ""
    echo "NOTE: It seems you must disable systemd boot for Fedora in place upgrades."
    echo "      See /etc/wsl.conf"
    echo ""
    ;;

esac
