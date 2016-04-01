# VERSION 1.0
FROM ubuntu:latest

MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

RUN sudo apt-get install -y software-properties-common

# Install Oracle Java 8
# See http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN sudo apt-get install -y oracle-java8-set-default

# Install Python2
RUN sudo apt-get install -y python

# Install VIM
RUN sudo apt-get install -y vim

RUN mkdir /root/softwares
WORKDIR /root/softwares

# Install screen
RUN sudo apt-get install -y screen

# Install Git
RUN sudo apt-get install -y git
