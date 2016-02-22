# VERSION 1.1

FROM ubuntu

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

# Install Apache Maven 3.3.9
RUN wget http://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
RUN tar xzvf apache-maven-3.3.9-bin.tar.gz
RUN rm apache-maven-3.3.9-bin.tar.gz
ENV PATH /root/softwares/apache-maven-3.3.9/bin:$PATH

# Install Apache Ant 1.9.6
RUN wget http://apache.go-parts.com//ant/binaries/apache-ant-1.9.6-bin.tar.gz
RUN tar xzvf apache-ant-1.9.6-bin.tar.gz
RUN rm apache-ant-1.9.6-bin.tar.gz
ENV PATH /root/softwares/apache-ant-1.9.6/bin:$PATH

# Install screen
RUN sudo apt-get install -y screen
COPY .screenrc /root

COPY .vimrc /root

# Install Git
RUN sudo apt-get install -y git

# Install bgzip and tabix
# See http://manpages.ubuntu.com/manpages/raring/man1/bgzip.1.html
RUN sudo apt-get install -y tabix

EXPOSE 80 8000-8010

WORKDIR /root
