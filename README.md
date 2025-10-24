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
- Either the default OS, Ubuntu 22.04.4 LTS, or Fedora WSL, freely available from the Microsoft Store Application.

### Install WSL OS of your choice

#### Default Ubuntu installation

Simply open a Windows command prompt or PowerShell, and enter

    > wsl --install

Once the installation is complete, reboot to activate WSL.

#### Fedora WSL installation

If WSL is not already installed, open a Windows command prompt or PowerShell, and enter

    > wsl --install --no-distribution

Once the installation is complete, reboot to activate WSL then proceed.

##### Option 1: Microsoft Store

Go to the Microsoft Store Application and download Fedora WSL.

##### Option 2: Original Fedora WSL git repository

As of March 24, 2025 Fedora WSL is missing from the Microsoft Store.  However, the git repository project is still available.  There are manual instructions to install the latest version as of March 24, 2025 here:  [Fedora WSL Manual Installation Instructions](https://github.com/VSWSL/Fedora-WSL?tab=readme-ov-file#installation).

A github issue was opened for this:  [Fedora WSL no longer available from Microsoft Store](https://github.com/VSWSL/Fedora-WSL/issues/31).  

NOTE:  If installing manually, the ".cer" file must be imported into the Windows "Trusted Root Certificate Store" of the "local machine" in order to trust the msix package.

Alternatively, the myfedora.ps1 script may be used to install Fedora WSL from the git repository.  The script will install Fedora WSL and prompt the user to set a linux password.  

NOTE: If this method is used, you cannot start Fedora WSL using the command:

    > fedora.exe

You must instead start the WSL instance in your home directory using:

    > wsl.exe --cd ~ -d MyFedora

If Fedora WSL is your default WSL distribution you may run a shorter version of the command:
    > wsl.exe --cd ~

NOTE: The myfedora.ps1 script downloads the Fedora WSL rootfs.amd64.tar.gz file.  To ensure you are installing the latest version you may check the releases page here:  [Fedora WSL RootFS](https://github.com/VSWSL/Fedora-WSL-RootFS/releases).  If there is a newer version, simply replace the link in the myfedora.ps1 script.  

##### Option 3: Create your own Fedora WSL Filesystem

It is possible to create your own Fedora WSL distribution using this repository:  [fedora_wsl_fs](https://github.com/jasondickerson/fedora_wsl_fs).  The repository includes scripts to create the Fedora WSL distribution Filesystem and install it on Windows.  

### Prepare WSL for use

Run the Linux Distribution you installed, either the Fedora or Ubuntu application.

If you used Fedora WSL from the Microsoft Store, enter your user name for WSL into the prompt, and then enter your new password twice at the prompts.  

Your WSL Linux Distribution is now configured and ready for use.  

### Configure your Ansible Environment in WSL

ansible_wsl.bash is designed to detect whether it is running on Fedora or Ubuntu and perform the necessary steps to configure the following:

- Ensure / is a shared mount (required for podman)
- Password-less sudo
- OS update
- Ensure shadow-utils is functional (required for podman)
- Install required OS packages
- Install Community Ansible via Python3 pip module into user home directory
- Add Ansible executables to the PATH environment variable
- Suppress podman messages concerning the upcoming cgroups v1 deprecation.
- Configure WSL for systemd boot
- Create required Ansible directories and git repository directory.
- Configure Git
- Create Ansible Navigator User Configuration
- Generate User SSH Key Pair if one does not exist
- Create a Sample gitignore file for Projects
- Create a Sample Ansible Configuration to load an Ansible Vault Password file
- On Fedora WSL, prompt user to restart WSL to boot Fedora WSL using systemd (required by podman)

#### Update script Variables for use

ansible_wsl.bash uses several variables to configure your Ansible Development Environment:

##### Git Configuration

- FULL_NAME    - Your full name used for git commits
- EMAIL        - Your email address used for git commits
- GIT_USER     - Your git user name
- GIT_TOKEN    - Your git personal access token for https access
- GIT_HOST     - Your git host Fully Qualified Domain Name

NOTE: If your git repository supports Password Auth, you can use your git password for the GIT_TOKEN variable.

#### Run the script

1. Cache your sudo password

        # sudo -l

1. Enter your password

1. Ensure the script is executable

        # chmod u+x ./ansible_wsl.bash

1. Run the script

        # ./ansible_wsl.bash

Once completed, if you are on Ubuntu, everything should be working.  For Fedora, you must restart WSL to boot Fedora using systemd, a requirement of podman.  To do so exit all Fedora terminals and run "wsl --shutdown" inside a Windows Command prompt or PowerShell, then open the Fedora application.  

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
        # wsl --export Fedora fedora_<version>_<date>.tar

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
        # dnf -y system-upgrade download --releasever=42
        # dnf -y offline reboot
        # dnf -y offline _execute
        # exit

1. From the Windows Command prompt, run:

        # wsl --shutdown

1. If you wish to update your user space python environment use the provided user_python_upgrade.bash script:

        # ./user_python_upgrade_bash

Your developer environment should now be upgraded and ready to go.
