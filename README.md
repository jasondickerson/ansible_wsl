# Ansible Developer WSL configuration

## Description

This project is to make it easy for Windows Users to take advantage of the full features of the Red Hat Ansible plugin for VS Code.  The plugin provides:

- Syntax checking via either "ansible-playbook --syntax-check" or "ansible-navigator lint"
- Validation of module names for either ansible-playbook or via an Execution Environment
- Module documentation when hovering your mouse over a valid module
- Ability to run a playbook (Assuming the playbook can run from WSL/your Windows laptop)
- Ansible Lightspeed.  Writing Ansible via AI.  (requires a Watson Code Assistant subscription)

As a bonus, the WSL environment can build Execution Environment Container Images using ansible-builder.

## How to use the script

### Prerequisites

- Windows 10 or 11
- WSL 2
- Either Ubuntu or Fedora.

### Install WSL OS of your choice

#### Default Ubuntu installation

Open a Windows Terminal and enter:

    > wsl --install

Once the installation is complete, reboot to activate WSL.

#### RHEL installation

If WSL is not already installed, open a Windows command prompt or PowerShell, and run the following in a Windows Terminal:

    > wsl --install --no-distribution

Once the installation is complete, reboot to activate WSL then proceed.

Download the RHEL 9.7 WSL image from https://access.redhat.com/downloads/content/479/ver=/rhel---9/9.7/x86_64/product-software.  

Run the following in a Windows Terminal:

    > cd
    > wsl --import RHEL .\WSL\RHEL .\Downloads\rhel-9.7-x86_64-wsl2.wsl
    > wsl -s RHEL
    > wsl --manage RHEL --set-default-user cloud-user

To run RHEL WSL, run the following in a Windows Terminal:
    > wsl -d RHEL

If WSL is not already installed, open a Windows command prompt or PowerShell, and use the command for the OS you wish to install.

    > wsl --install --no-distribution

Once the installation is complete, reboot to activate WSL then proceed.

#### Fedora installation

Open a Windows Terminal and enter:

    > wsl --install FedoraLinux-43

You will be prompted to enter a username for your OS instance the first time you run FedoraLinux-43.  

### Configure your Ansible Environment in WSL

ansible_wsl.bash is designed to detect whether it is running on Fedora or Ubuntu and perform the necessary steps to configure the following:

- Ensure / is a shared mount (required for podman)
- OS update
- Install required OS packages
- Install Community Ansible via Python3 pip module into user home directory
- Add Ansible executables to the PATH environment variable
- Create required Ansible directories and git repository directory.
- Configure Git
- Create Ansible Navigator User Configuration
- Generate User SSH Key Pair if one does not exist
- Create a Sample gitignore file for Projects
- Create a Sample Ansible Configuration to load an Ansible Vault Password file

rhel/configure_rhel_wsl.bash is designed to configure the following:

- Configure ping as non-root user
- Register to Red Hat Online
- Enable the Ansible repository.
- Install required OS and Ansible packages
- OS update
- Ensure / is a shared mount (required for podman)
- Set WSL to start in the Linux home directory
- Configure Git
- Password-less sudo
- Configure Authentication for registry.redhat.io
- Configure ansible-galaxy
- Create Ansible Navigator User Configuration
- Generate User SSH Key Pair if one does not exist
- Check if reboot is necessary

#### Update script Variables for use

The scripts use several variables to configure your Ansible Development Environment:

##### Git Configuration

- FULL_NAME    - Your full name used for git commits
- EMAIL        - Your email address used for git commits
- GIT_USER     - Your git user name
- GIT_TOKEN    - Your git personal access token for https access
- GIT_HOST     - Your git host Fully Qualified Domain Name

NOTE: If your git repository supports Password Auth, you can use your git password for the GIT_TOKEN variable.

##### RHEL Variables

- RH_USER      - Your Red Hat User name
- RH_PASSWORD  - Your Red Hat Password
- RH_AH_TOKEN  - Your Red Hat Automation Hub token

#### Run the script (ansible_wsl.bash or configure_rhel_wsl.bash)

1. Cache your sudo password

        # sudo -l

1. Enter your password

1. Ensure the script is executable

        # chmod u+x ./ansible_wsl.bash

1. Run the script

        # ./ansible_wsl.bash

## How to use WSL within VS Code

1. Install VS Code.
1. In VS Code, install the WSL Extension.  
1. Close VS Code.
1. Open the WSL Application, either Fedora or Ubuntu.
1. In the WSL terminal switch to a project directory, for example ansible-wsl

        # cd git-repos/ansible-wsl

1. To open the current directory in VS Code run

        # code .

    - The first time you run this, VSCode server will be installed in your WSL home directory.

1. In VS Code, install the following plugins within the WSL environment:

    - Ansible
    - markdownlint
    - Code Spell Checker

1. Go to the Extension Settings for the Ansible Extension
1. Ensure Ansible Execution Environment Enabled is checked
1. Ensure Ansible Execution Environment Container Engine is podman
1. Ensure Ansible Execution Environment Image is set to your desired EE image
1. Ensure Ansible Execution Environment Pull Policy is missing

Your VS Code WSL development environment should now be configured.  

NOTE:  It is possible to use WSL with VS Codium as well.  The WSL extension is replaced by the "Open Remote - WSL" Extension, and VS Codium does not seem to be in the path by default, so I use the blue '><' button at the bottom left to connect to the WSL instance.  

## How to backup your WSL environment

This example workflow is for Fedora, but will work for any WSL distribution:

1. Open a Windows Command Prompt, cmd.exe
1. Run the following commands:

        # wsl --shutdown
        # wsl --export FedoraLinux-43 fedora_<version>_<date>.tar

## How to upgrade a Fedora Distribution to the latest major version

Fedora 40 just recently was released.  The following will upgrade a Fedora 39 WSL Distro to 40:

1. From Fedora WSL user, run:

        # sudo dnf -y upgrade --refresh
        # exit

1. From the Windows Command prompt, run:

        # wsl --shutdown

1. From Fedora WSL, run the following commands using sudo access as follows to upgrade up to Fedora 41:

        # sudo -i
        # export DNF_SYSTEM_UPGRADE_NO_REBOOT=1
        # dnf -y system-upgrade download --releasever=41
        # dnf -y system-upgrade reboot
        # dnf -y system-upgrade upgrade
        # exit

1. From Fedora WSL, run the following commands using sudo access as follows to upgrade up to Fedora 42 or higher:

        # sudo -i
        # export DNF_SYSTEM_UPGRADE_NO_REBOOT=1
        # dnf -y system-upgrade download --releasever=43
        # dnf -y offline reboot
        # dnf -y offline _execute
        # exit

1. From the Windows Command prompt, run:

        # wsl --shutdown

1. If you wish to update your user space python environment use the provided user_python_upgrade.bash script:

        # ./user_python_upgrade_bash

Your developer environment should now be upgraded and ready to go.
