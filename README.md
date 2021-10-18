Linux Forensic Artifacts Collector - LFAC
===
<kbd>![LFAC Logo](/screenshot/LFAC-repo-card.png)</kbd>

Script to automate Linux logs & artifacts collection. It uses built-in tools to automate the collection of systems artifacts. It was created to facilitate data collection, and depend less on remote tools/agents during incident response engagements.

Features
===
- Collecting logs from: 
  - user & root .bash_history
  - user & root cron/crontab
  - ifconfig/ip addr
  - netstat
  - ps aux
  - `/var/log`
  - `/tmp`
- Checking mechanism - to see if `net-tools` is installed. if not, script will install it. <b>hopefully..</b> \*sigh\*
- Tested on Ubuntu 20.04, Debian 10 & RedHat 8.4.

Dependencies
===
<li>net-tools - networking utilities for Linux</li>

How to Run
===
 - Copy LFAC.sh your host machine
 - Give execution permission by running `chmod +x LFAC.sh`
 - Then run the script as below:
```
  $ sudo ./LFAC.sh
```
- Wait until it finished collecting the logs
- The compressed logs should located at `/opt/` dir named as <'hostname'>.tar.gz

Screenshot
===
![Ubuntu 20.04](/screenshot/LFAC_Ubuntu20.04.png)
![Debian 10](/screenshot/LFAC_Debian10.png)
![RHEL 8.4](/screenshot/LFAC_RHEL8.4.png)

Changelogs
===
- Beta  (09 Jul 2021): Beta version of the script by Fikri Ramli.
- 1.0   (13 Jul 2021): Improved logs copies arrangement & applied file compressing.
- 1.1   (21 Jul 2021): Improved logs copies arrangement. Tested on Ubuntu 20.04, Debian 10 & RedHat 8.4.
- 1.2   (22 Jul 2021): Improved .bash_history copy method for each user and better folder naming convention.
- 1.3   (02 Sep 2021): Collect user accounts context logs (passwd, shadow,group and sudoers); stored in accounts folder, timezone & btmp.
- 1.4   (21 Sep 2021): Adjusting file compression structure.
- 1.5   (05 Oct 2021): Distro checking for net-tools availability. Collect ifconfig/ip addr info. Added ASCII art; cause, why not? :)
- 1.5.1 (15 Oct 2021): Disable wtmp & btmp dump logs; it only read first log when tried to * filename. Correcting net-tools installing method for RHEL.
- 1.5.2 (17 Oct 2021): Added lastlog, search deleted binaries which still running, search hidden dirs & files, search hidden & non-hidden executables on system. Removed btmp (as it only records failed login attempts.) Added utmp log. More refined utmpdump method.

To-Do-List (In Future)
===
- [ ] Changing from ifconfig to ip addr - since ifconfig going to deprecated
- [ ] Probably add more artifacts to be collected in future

Credit
===
- This script was developed together with Fikri Ramli - <a href="https://www.linkedin.com/in/fikri-ramli-aba94881/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" /></a> / <a href="https://github.com/frmoncheh/"><img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" /></a>
