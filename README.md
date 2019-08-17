# Masspwn

Fastly scans open ports on large networks and bruteforce login mechanism of found services

<img src="https://i.imgur.com/RBHUq44.png?1"/>

## Description

Masspwn is a bash script that takes adventage of the power and efficiency of [masscan](https://github.com/robertdavidgraham/masscan) tool for finding open ports in large networks. Masscan is much faster than nmap for doing that work. Once masscan found specified open ports on specified hosts, pass this output to [nmap](https://github.com/nmap/nmap) for scan the services versions of open ports found by masscan. In this way nmap only scan versions of active ports on active hosts, avoiding wasting a lot of time finding active hosts and ports trought nmap. Then nmap pass this output to [brutespray](https://github.com/x90skysn3k/brutespray) tool, that automatically brute-forces services login mechanism with default credentials using [Medusa](https://github.com/jmk-foofus/medusa). Brutespray can bruteforce authentication mechanism of **ssh**, **ftp**, **telnet**, **vnc**, **mssql**, **mysql**, **postgresql**, **rsh**, **imap**, **nntp**, **pcanywhere**, **pop3**, **rexec**, **rlogin**, **smbnt**, **smtp**, **svn**, **vmauthd** and **snmp** protocols.

## Installation

The installation is quite simple. This script checks for dependences and download them if not present in your OS. Open a terminal in Kali Linux and type the following commands:

```sh
git clone https://github.com/JuanSchallibaum/masspwn
cd masspwn
chmod +x masspwn.sh
./masspwn.sh --help

```

## Usage

```sh
./masspwn.sh -h [CIDR | HOSTS LIST] -p[PORT RANGE] -o [OUTPUT DIRECTORY] <OPTIONS>
```

### Optional arguments:

<pre>
-u   | --users [USERS WORDLIST]           Specify custom wordlist for users bruteforce<br/>
-pw  | --passwords [PASSWORDS WORDLIST]   Specify custom wordlist for passwords bruteforce<br/>
--help                                    Show this help message and exit<br/>
-r   | --rate [PACKETS PER SECCOND] 	  Set packets per seccond send to find open ports<br/>
-t   | --threads [BRUTEFORCE THREADS]     Set the number of threads used for bruteforce with bruespray"<br/>
</pre>

## Examples
```sh
./masspwn.sh -h 172.217.0.0/16 -p1-65535 -r 10000 -o google
```
*The previous command scan all ports of Google hosts sending 10000 packets per seccond, bruteforce found services login with brutespray default credentials, and saves results in 'google' folder.*

```sh
./masspwn.sh -h host_list.txt -p1-1000 -u /usr/share/wordlists/users.txt -p /usr/share/wordlists/passwords.txt -o results
```
*The previous command scan port range of 1 to 1000 of hosts listed in host_list.txt sending 600 packets per seccond, bruteforce found services login with customs wordlists for users and passwords, and saves results in 'results' folder.*

## Credits

This bash script is quite simple, but very powerfull thanks to previously mentioned tools used by it:

[masscan](https://github.com/robertdavidgraham/masscan) made by Robert David Graham<br/>
[nmap](https://github.com/nmap/nmap) made by Gordon Lyon<br/>
[brutespray](https://github.com/x90skysn3k/brutespray) made by Shane Young<br/>
[Medusa](https://github.com/jmk-foofus/medusa) made by Joe Mondloch<br/>

and the workflow approached in this script is inspired by Jason Haddix in your [Bug Bounty Hunter Methodology v3](https://www.youtube.com/watch?v=Qw1nNPiH_Go&t=4254s) speaking.
