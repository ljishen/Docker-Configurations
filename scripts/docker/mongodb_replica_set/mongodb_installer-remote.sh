#!/bin/bash -e

# This Installer only can be used on Ubuntu 14.04

echo -e "\nImport the MongoDB public GPG Key"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

echo -e "\nCreate a list file for MongoDB"
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

echo -e "\nUpdate apt-get sources AND install MongoDB"
apt-get update && apt-get install -y mongodb-org

echo -e "\nCreate the MongoDB data directory"
mkdir -p /data/db

echo -e "\nStart mongodb using:
    /usr/bin/mongod &"
