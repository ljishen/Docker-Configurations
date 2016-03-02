#!/bin/bash -e

# This Installer only can be used on Ubuntu 14.04

echo -e "\nImport the MongoDB public GPG Key"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

echo -e "\nCreate a list file for MongoDB"
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

echo -e "\nUpdate apt-get sources AND install MongoDB"
apt-get update && apt-get install -y mongodb-org

# Create the necessary data directories for each member
mkdir -p /srv/mongodb/rs0

echo -e "\nDone!\n"

echo "
(1) Start mongodb instance by issuing the following command on each member node:
    mongod --port 27017 --dbpath /srv/mongodb/rs0 --replSet rs0 --smallfiles --oplogSize 128 &"
echo "
(2) Connect to one of your mongod instances:
    mongo --port 27017"
echo "
(3) Use the following command on one and only one member of the replica set
    rs.initiate()"
echo "
(4) Add the remaining members with the rs.add() method. You must be connected to the primary to add members to a replica set.

rs.add() can, in some cases, trigger an election. If the mongod you are connected to becomes a secondary, you need to connect the mongo shell to the new primary to continue adding new replica set members. Use rs.status() to identify the primary in the replica set.
    rs.add("mongodb1.example.net")"
echo "
(5) Check the status of the replica set
    rs.status()"
