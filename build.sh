#!/bin/bash

tag=$1

docker build -t ljishen/dev:${tag} Dockerfiles
