#!/usr/bin/env bash

###########################################
# set the fresh Ubuntu16
###########################################

set_bash_env()
{
	# select NO to use bash
	dpkg-reconfigure dash
}

set_root_login()
{
	echo "greeter-show-manual-login=true" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
	sed -i 's/mesg\ n/tty\ -s\ \&\&\ mesg\ n/g' /root/.profile
}

install_common_tools()
{
	apt-get install vim cscope exuberant-ctags tmux screen tree minicom ipmitool -y

	# nodejs install
	apt-get install nodejs -y
	ln -s /usr/bin/nodejs /usr/local/bin/node

	# npm install
	apt-get install npm -y

	# grunt install by npm
	npm install -g grunt-cli

	# php install
	apt-get install php7.0-cli -y

	# libpcre install
	apt-get install libpcre3 libpcre3-dev -y

	# lua install
	apt-get install luajit -y

	# git install
	apt-get install git -y
}

install_MDS_prerequisites()
{
	apt-get install gcc-multilib -y
	apt-get install mtd-utils:i386 -y
	apt-get install subversion -y
	apt-get install patch -y
	apt-get install patchutils -y
	apt-get install bison -y
	apt-get install libc6-dev -y
	apt-get install libxml-dom-perl -y
	apt-get install zlib1g -y
	apt-get install zlib1g-dev -y
	apt-get install libcurl4-openssl-dev -y
	apt-get install libncurses5:i386 -y
	apt-get install python-numpy -y
	apt-get install doxygen -y
	apt-get install python-apt -y
	apt-get install dmsetup -y
	apt-get install php5-cli -y
	apt-get install openssl -y
	apt-get install g++ -y
	apt-get install libpcre3-dev -y
	apt-get install flex -y
	apt-get install sqlite3 -y
}

install_ssh()
{
	local ssh_server_file="/etc/ssh/sshd_config"

	# install ssh
	apt-get install ssh openssh-server -y

	# add ssh root login
	sed -i 's/PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/g' $ssh_server_file
}

install_tftp()
{
	local tftp_server_file="/etc/xinetd.d/tftp"
	local tftp_upload_dir="/tftpboot"

	# insatll tftp
	apt-get install xinetd tftpd tftp -y

	# set tftp server
	touch $tftp_server_file
	echo -e "service tftp" >> $tftp_server_file
	echo -e "{" >> $tftp_server_file
	echo -e "\tprotocol = udp" >> $tftp_server_file
	echo -e "\tport = 69" >> $tftp_server_file
	echo -e "\tsocket_type = dgram" >> $tftp_server_file
	echo -e "\twait = yes" >> $tftp_server_file
	echo -e "\tuser = nobody" >> $tftp_server_file
	echo -e "\tserver = /usr/sbin/in.tftpd" >> $tftp_server_file
	echo -e "\tserver_args = $tftp_upload_dir" >> $tftp_server_file
	echo -e "\tdisable = no" >> $tftp_server_file
	echo -e "}" >> $tftp_server_file

	# create tftp directory
	mkdir -p $tftp_upload_dir
	chmod -R 777 $tftp_upload_dir
	chown -R nobody $tftp_upload_dir

	# tftp service restart
	service xinetd restart
}

install_nfs()
{
	local nfs_export_path="/"

	# install nfs
	apt-get install nfs-kernel-server nfs-common -y

	# set nfs export path
	echo "$nfs_export_path    *(rw,sync,no_root_squash)" >> /etc/exports

	# nfs service restart
	/etc/init.d/nfs-kernel-server restart
}

install_zlib()
{
	local zlib_dir="/opt/zlib"
	local zlib_ver="zlib-1.2.11"
	local libz_file_ext="tar.gz"

	# download tarball and install
	mkdir -p $zlib_dir; cd $zlib_dir;
	wget "http://zlib.net/${zlib_ver}.${libz_file_ext}"
	tar zxvf "${zlib_ver}.${libz_file_ext}"; cd $zlib_ver
	./configure && make && make install
}

# need to input ENTER
install_java()
{
	# java8 or java9
	local java_version="java8"

	apt-get install python-software-properties -y
	apt-get install software-properties-common -y

	# add ppa
	add-apt-repository ppa:webupd8team/java
	apt-get update

	# install
	apt-get install oracle-${java_version}-installer -y
	apt-get install oracle-${java_version}-set-default -y
}

# need to input ENTER twice
install_mailutils()
{
	apt-get install mailutils -y
}

install_wireshark()
{
	# add ppa
	add-apt-repository ppa:wireshark-dev/stable
	apt-get update

	# insatll wireshark
	apt-get install wireshark
}

# need to input AD account twice
install_AMI_SVN_tools()
{
	# svn install
	apt-get install subversion -y

	# python install
	apt-get install python-numpy python-svn python-dev -y

	# pip install
	apt-get install python-pip -y
	pip install --upgrade pip

	# svnspxex install
	sudo -H pip install -U  --extra-index-url https://megaracsvn.ami.com/pip svnspxex

	# rbspxex install
	sudo -H pip install -U  --extra-index-url https://megaracsvn.ami.com/pip rbspxex

	# add x permission in python files
	chmod +x /usr/local/lib/python2.7/dist-packages/*.py

	# RBtools install by pip
	pip install RBtools

	# add PATH to profile
	local profile="/etc/profile"
	echo -e '' >> $profile 
	echo -e '#added by user' >> $profile
	echo -e 'PATH=$PATH:/usr/local/lib/python2.7/dist-packages/' >> $profile
}

main()
{
	# upgrade all existed tools
	apt-get update
	apt-get upgrade -y

	# select NO to use bash
#	set_bash_env

	# don't need to input
#	set_root_login
#	install_common_tools
#	install_MDS_prerequisites
#	install_ssh
#	install_tftp
#	install_nfs
#	install_zlib

	# need to input ENTER several times
#	install_java

	# need to input ENTER twice
#	install_mailutils

	# need to input ENTER once
#	install_wireshark

	# need to input AD account twice
#	install_AMI_SVN_tools

}

main

