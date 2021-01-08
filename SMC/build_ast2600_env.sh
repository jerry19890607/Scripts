#!/bin/bash

sudo apt-get install -y cifs-utils
sudo apt-get install -y default-jdk
sudo apt-get install -y git
sudo apt-get install -y openssh-server
sudo apt-get install -y vim
sudo apt-get install -y samba

sudo apt-get install -y python-requests
sudo apt-get install -y libgdk-pixbuf2.0-dev
sudo apt-get install -y device-tree-compiler
sudo apt-get install -y git build-essential libsdl1.2-dev texinfo gawk chrpath diffstat gcc g++ gett
sudo apt-get install -y libncurses5-dev flex bison                      #(make defconfig要使用的)
sudo apt-get install -y gcc-arm*
sudo apt-get install -y gcc-arm-linux-gnueabi u-boot-tools libssl-dev   #(Build Kernel要使用的)
sudo apt-get install -y lib32z1                                         #(AST2500 ToolChain要使用的)
sudo apt-get install -y lib32ncurses5                                   #(AST2500 ToolChain要使用的3
sudo apt-get install -y gcc-multilib

sudo apt-get install -y libssl-dev
sudo apt-get install -y libbison-dev
sudo apt-get install -y xutils-dev
sudo apt-get install -y autotools-dev
sudo apt-get install -y autoconf-archive
sudo apt-get install -y libtool
sudo apt-get install -y squashfs-tools

sudo apt-get install -y dos2unix
sudo apt-get install -y autoconf
sudo apt-get install -y tree
sudo apt-get install -y xinetd tftpd tftp
sudo apt-get install -y nfs-kernel-server nfs-common
sudo apt-get install -y cppcheck

sudo apt-get install -y meld
sudo apt-get install -y gitk
sudo apt-get install -y cola
sudo apt-get install -y terminator
sudo apt-get install -y python2.7

#x11
#P.S.: change LANG to utf-8
#sudo apt-get install -y libcurl4-gnutls-dev
#sudo apt-get install -y librtmp-dev

sudo apt-get install -y openjdk-8-jdk-headless
sudo update-alternatives --config java
sudo update-alternatives --config javac
sudo update-alternatives --config jar
sudo update-alternatives --config keytool
sudo update-alternatives --config jarsigner
sudo update-alternatives --config pack200

cd /bin
sudo rm sh
sudo ln -s bash sh

cd /usr/bin/
sudo ln -s python2.7 python

sudo mkdir -p /usr/local/oecore-x86_64/sysroots/
echo "Please copy x12 ToolChain/AST2600/x86_64-oesdk-linux to /usr/local/oecore-x86_64/sysroots/"
