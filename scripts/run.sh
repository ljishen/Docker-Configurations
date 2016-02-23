#!/bin/bash

tag=$1

docker run -P -t -i ljishen/dev:${tag}
