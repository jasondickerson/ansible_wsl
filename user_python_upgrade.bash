#!/bin/bash
python3 -m pip freeze --user | cut -d= -f1 | grep -v -e ansible-builder -e ansible-compat -e ansible-core -e ansible-lint -e ansible-navigator -e ansible-runner > /tmp/python_env_upgrade.txt
echo "ansible-builder==3.1.0" >> /tmp/python_env_upgrade.txt
echo "ansible-compat==25.8.1" >> /tmp/python_env_upgrade.txt
echo "ansible-core==2.16.14" >> /tmp/python_env_upgrade.txt
echo "ansible-lint==25.8.2" >> /tmp/python_env_upgrade.txt
echo "ansible-navigator==25.8.0" >> /tmp/python_env_upgrade.txt
echo "ansible-runner==2.4.1" >> /tmp/python_env_upgrade.txt
python3 -m pip install --upgrade --user --requirement /tmp/python_env_upgrade.txt
rm /tmp/python_env_upgrade.txt
