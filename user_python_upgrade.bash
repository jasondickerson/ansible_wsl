#!/bin/bash
python3 -m pip freeze --user | cut -d= -f1 | grep -v -e ansible-navigator -e ansible-builder > /tmp/python_env_upgrade.txt
echo "ansible-navigator==24.2.0" >> /tmp/python_env_upgrade.txt
echo "ansible-builder==3.0.1" >> /tmp/python_env_upgrade.txt
python3 -m pip install --upgrade --requirement /tmp/python_env_upgrade.txt --user
rm /tmp/python_env_upgrade.txt
