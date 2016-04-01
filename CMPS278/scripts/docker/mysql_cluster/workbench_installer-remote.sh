#!/bin/bash -e

PACKAGE=#PACKAGE
DEST=#DEST

sudo dpkg -i ${DEST}/${PACKAGE}
sudo apt-get update

sudo apt-get install -y mysql-workbench-community

echo -e "\nDone!"
