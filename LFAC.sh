#!/bin/bash
#
# Linux Forensic Artifacts Collector - LFAC Ver. 1.5.2
#
# Authors
# -------
# Fikri <FikriRamli@gmail.com>
# Azam <M.Khairulazam@gmail.com>
#
# Changelogs
# ----------
# Beta  (09 Jul 2021): Beta version of the script by Fikri Ramli.
# 1.0   (13 Jul 2021): Improved logs copies arrangement & applied file compressing.
# 1.1   (21 Jul 2021): Improved logs copies arrangement. Tested on Ubuntu 20.04, Debian 10 & RedHat 8.4.
# 1.2   (22 Jul 2021): Improved .bash_history copy method for each user and better folder naming convention.
# 1.3   (02 Sep 2021): Collect user accounts context logs (passwd, shadow, group and sudoers); stored in accounts folder, timezone & btmp.
# 1.4   (21 Sep 2021): Adjusting file compression structure.
# 1.5   (05 Oct 2021): Distro checking for net-tools availability. Collect ifconfig/ip addr info. Added ASCII art; cause, why not? :)
# 1.5.1 (15 Oct 2021): Disable wtmp & btmp dump logs; it only read first log when tried to * filename. Correcting net-tools installing method for RHEL.
# 1.5.2 (17 Oct 2021): Added lastlog, search deleted binaries which still running, search hidden dirs & files, search hidden & non-hidden executables on system.
#                      Removed btmp (as it only records failed login attempts.) Added utmp log.
#
# No Licence or warranty expressed or implied, use however you wish!
# Please email us for any suggestion and feedback.

echo -e "
 +-+-+-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+
 |L|i|n|u|x| |F|o|r|e|n|s|i|c| |A|r|t|i|f|a|c|t|s|
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |C|o|l|l|e|c|t|o|r| |-| |L|F|A|C|_|v|1|.|5|.|2|  
 +-+-+-+-+-+-+-+-+-+ +-+ +-+-+-+-+-+-+-+-+-+-+-+  
"

echo -e " Collecting necessary logs.. \n"

#Creating folder & files
mkdir /opt/lfac
mkdir /opt/lfac/var_logs
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
touch /opt/lfac/ps_out
touch /opt/lfac/release
touch /opt/lfac/wtmp
touch /opt/lfac/utmp
touch /opt/lfac/lastlog
touch /opt/lfac/accounts/passwd 
touch /opt/lfac/accounts/shadow
touch /opt/lfac/accounts/sudoers
touch /opt/lfac/accounts/group  

#Copying logs
cp -R /var/log/* /opt/lfac/var_logs
cp -R /tmp/* /opt/lfac/tmp_files
cp /root/.bash_history /opt/lfac/root_bashhistory

#Loop over each user and copy their bash_history.
for user in $(cut -f1 -d: /etc/passwd); do cp /home/$user/.bash_history /opt/lfac/user_bashhistory/$user &> /dev/null; done

cat /etc/*-release > /opt/lfac/release

#Network Connections/Socket Stats
#netstat checking mechanism
NETSTATINSTALLED=$(netstat | grep -cs 'Active Internet connections')
if [[ $NETSTATINSTALLED == 1 ]]
then
	echo -e " netstat installed!"
	netstat -antp > /opt/lfac/netstat_out
else
	echo -e " netstat not installed!"
	sudo apt-get install net-tools -y #for debian-based os
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
		sudo yum -y install net-tools
		ifconfig > /opt/lfac/ifconfig
	else
		echo -e " ifconfig installed!"
		ifconfig > /opt/lfac/ifconfig
	fi
else
	echo -e "\n Unknown distro! Collect host network info manually."
	uname -a
fi

#List process tree
ps -auxwf > /opt/lfac/ps_out

#Dumping utmp & wtmp
for f in $(ls /var/log/wtmp*); do utmpdump $f >> /opt/lfac/wtmpdump_output.txt; done
for f in $(ls /var/run/utmp*); do utmpdump $f >> /opt/lfac/utmpdump_output.txt; done
cp /var/run/utmp* /opt/lfac/var_logs

#Deleted binaries which are still running
ls -alr /proc/*/exe 2> /dev/null | grep deleted

#Hidden Directories and Files
find / -type d -name ".*"

#Executables on file system
find / -type f -exec file -p '{}' \; |  grep ELF

#Hidden Executables on file system
find / -name ".*" -exec file -p '{}' \; | grep ELF

cp -R /etc/cron* /opt/lfac/cron_copy
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l &> /dev/null > /opt/lfac/crontab_out; done
#Loop over each username and list out their crontab.

#Copying user accounts details
cat /etc/passwd > /opt/lfac/accounts/passwd
cat /etc/shadow > /opt/lfac/accounts/shadow
cat /etc/sudoers > /opt/lfac/accounts/sudoers
cat /etc/group > /opt/lfac/accounts/group

#Host time zone
timedatectl > /opt/lfac/timezone

#Lastlog
lastlog > /opt/lfac/lastlog

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
