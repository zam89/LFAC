#!/bin/bash
#
# Linux Forensic Artifacts Collector - LFAC Ver. 1.5
#
# Authors
# -------
# Fikri <FikriRamli@gmail.com>
# Azam <M.Khairulazam@gmail.com>
#
# Changelogs
# ----------
# Beta (9 Jul 2021): Beta version of the script by Fikri Ramli.
# 1.0 (13 Jul 2021): Improved logs copies arrangement & applied file compressing.
# 1.1 (21 Jul 2021): Improved logs copies arrangement. Tested on Ubuntu 20.04, Debian 10 & RedHat 8.4.
# 1.2 (22 Jul 2021): Improved .bash_history copy method for each user and better folder naming convention.
# 1.3 (02 Sep 2021): Collect user accounts context logs (passwd, shadow, group and sudoers); stored in accounts folder, timezone & btmp.
# 1.4 (21 Sep 2021): Adjusting file compression structure.
# 1.5 (05 Oct 2021): Distro checking for net-tools availability. Collect ifconfig/ip addr info. Added ASCII art; cause, why not? :)
#
# No Licence or warranty expressed or implied, use however you wish!
# Please email us for any suggestion and feedback.

echo -e "
 +-+-+-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+
 |L|i|n|u|x| |F|o|r|e|n|s|i|c| |A|r|t|i|f|a|c|t|s|
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |C|o|l|l|e|c|t|o|r| |-| |L|F|A|C|                
 +-+-+-+-+-+-+-+-+-+ +-+ +-+-+-+-+                
"

echo -e " Collecting necessary logs.. \n"

#Creating folder & files
mkdir /opt/lfac
mkdir /opt/lfac/varlogs
mkdir /opt/lfac/tmp_files
mkdir /opt/lfac/root_bashhistory
mkdir /opt/lfac/user_bashhistory
mkdir /opt/lfac/cron_copy
mkdir /opt/lfac/accounts
touch /opt/lfac/timezone
touch /opt/lfac/netstat_out
touch /opt/lfac/ipaddr
touch /opt/lfac/ifconfig
touch /opt/lfac/crontab_out
touch /opt/lfac/psaux_out
touch /opt/lfac/release
touch /opt/lfac/wtmp
touch /opt/lfac/btmp
touch /opt/lfac/accounts/passwd 
touch /opt/lfac/accounts/shadow
touch /opt/lfac/accounts/sudoers
touch /opt/lfac/accounts/group  

#Copying logs
cp -R /var/log/* /opt/lfac/varlogs
cp -R /tmp/* /opt/lfac/tmp_files
cp /root/.bash_history /opt/lfac/root_bashhistory

#Loop over each user and copy their bash_history.
for user in $(cut -f1 -d: /etc/passwd); do cp /home/$user/.bash_history /opt/lfac/user_bashhistory/$user &>/dev/null; done

cat /etc/*-release > /opt/lfac/release

#netstat checking mechanism
NETSTATINSTALLED=$(netstat | grep -cs 'Active Internet connections')
if [[ $NETSTATINSTALLED == 1 ]]
then
	echo -e " netstat installed!"
	#netstat -lnput > /opt/lfac/netstat_out
	netstat -antp > /opt/lfac/netstat_out
else
	echo -e " netstat not installed!"
	sudo apt-get install net-tools -y
	netstat -antp > /opt/lfac/netstat_out
fi

#grab host network interface configuration
DISTRO=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
if [[ $DISTRO == "debian" ]]
then
	IPAINSTALLED=$(ip a | grep -cs 'command not found')

	if [[ $IPAINSTALLED == 1 ]]
	then
		echo -e " ip a not installed!"
		sudo apt-get install net-tools -y
		ip a > /opt/lfac/ipaddr
	else
		echo -e " ip a installed!"
		ip a > /opt/lfac/ipaddr
	fi
elif [[ $DISTRO == "ubuntu" ]]
then
	IFCONFIGINSTALLED=$(ifconfig | grep -cs 'command not found')

	if [[ $IFCONFIGINSTALLED == 1 ]]
	then
		echo -e " ifconfig not installed!"
		sudo apt-get install net-tools -y
		ifconfig > /opt/lfac/ifconfig
	else
		echo -e " ifconfig installed!"
		ifconfig > /opt/lfac/ifconfig
	fi
elif [[ $DISTRO == '"rhel"' ]]
then
	IFCONFIGINSTALLED=$(ifconfig | grep -cs 'command not found')

	if [[ $IFCONFIGINSTALLED == 1 ]]
	then
		echo -e " ifconfig not installed!"
		sudo apt-get install net-tools -y
		ifconfig > /opt/lfac/ifconfig
	else
		echo -e " ifconfig installed!"
		ifconfig > /opt/lfac/ifconfig
	fi
else
	echo -e "\n Unknown distro! Collect host network info manually."
	uname -a
fi

ps aux > /opt/lfac/psaux_out
last -f /var/log/wtmp > /opt/lfac/wtmp
utmpdump /var/log/btmp > /opt/lfac/btmp &>/dev/null

cp -R /etc/cron* /opt/lfac/cron_copy
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l &>/dev/null > /opt/lfac/crontab_out; done
#Loop over each username and list out their crontab.

#Copying user accounts details
cat /etc/passwd > /opt/lfac/accounts/passwd
cat /etc/shadow > /opt/lfac/accounts/shadow
cat /etc/sudoers > /opt/lfac/accounts/sudoers
cat /etc/group > /opt/lfac/accounts/group

#Host time zone
timedatectl >  /opt/lfac/timezone

#List folder contents
find /opt/lfac/ -print > /opt/lfac/list_files

#Compressing folder
cd /opt/
tar -czf $(hostname).tar.gz lfac

#MD5sum tar file
echo -e "\n MD5 = ` md5sum $(hostname).tar.gz `\n"

#Removing files & folder after completion
rm -rf /opt/lfac

#Changing file owner
currentuser=$(who | awk '{print $1}')
sudo chown -R $currentuser:$currentuser /opt/$(hostname).tar.gz

echo -e " Done! File located at: /opt/$(hostname).tar.gz\n"

