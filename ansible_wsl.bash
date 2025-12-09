#!/bin/bash

## Tested with Windows 10 and 11 WSL2 with following OS's:
## (Default WSL2) Ubuntu 22.04.4 LTS
## Fedora WSL by Vineel Sai, available for Free on the Microsoft Store.  Versions 39 and 40.

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
    USER_PROFILE=".bash_profile"
    OS_PKGS="python3-pip tree glibc-all-langpacks gettext-envsubst git-core"
    ## interactive: possible prompt for sudo password
    sudo mount --make-rshared /
    ${PKG_MGR} install gettext-envsubst
    ;;

  ubuntu)
    PKG_MGR="sudo apt-get -y"
    USER_PROFILE=".profile"
    OS_PKGS="python3-pip tree glibc-all-langpacks"
    ;;

  *)
    echo "Unknown OS"
    exit 1
    ;;

esac

## Upgrade OS
case ${ID} in

  fedora)
    ${PKG_MGR} update
    ;;

  ubuntu)
    ${PKG_MGR} update
    ${PKG_MGR} upgrade
    ;;

esac

#### Possible pkgs for Ubuntu
# sudo apt-get install curl wget gnupg2

## Install required os packages
${PKG_MGR} install ${OS_PKGS}

## Install Community Ansible Navigator
## Match Versions to AAP 2.6
python3 -m pip install --user ansible-builder==3.1.0 ansible-compat==25.8.1 ansible-core==2.16.14 ansible-lint==25.8.2 ansible-navigator==25.8.0 ansible-runner==2.4.2

## Add Ansible commands to the PATH
grep 'export PATH=$HOME/.local/bin:$PATH' ~/${USER_PROFILE} &> /dev/null
if [ ${?} -ne 0 ] ; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/${USER_PROFILE}
fi

grep 'export PODMAN_IGNORE_CGROUPSV1_WARNING=1' ~/${USER_PROFILE} &> /dev/null
if [ ${?} -ne 0 ] ; then
  echo 'export PODMAN_IGNORE_CGROUPSV1_WARNING=1' >> ~/${USER_PROFILE}
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

    if [ "$(grep -v ^$ .bashrc | tail -n1)" != "cd" ] ; then
      echo 'cd' >> ${HOME}/.bashrc
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
