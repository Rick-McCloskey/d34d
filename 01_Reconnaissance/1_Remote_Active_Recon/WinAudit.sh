#!/bin/sh


# Basic Information Gathering
currentmonth=`date "+%Y-%m-%d"`

rm lindows.log

echo "Hostname Identification Audit: " $currentmonth >> lindows.log
echo -e "------------------------------------------" >> lindows.log
echo -e >> lindows.log
for obj0 in $(grep -v "^#" all_linux_windows_ips.txt);
do


# Check if windows
check=`nmap -e bge0 -p 3389 $obj0 | grep open`

if [ "$?" -eq 0 ]
        then
        windowshost=`nbtscan -v -s , $obj0 | head -n 1 | awk -F"," '{printf "%s", $2}'`
        if [ -n "${windowshost:+x}" ]
                then
                echo -e "$windowshostt: $obj0t: WINDOWS" >> lindows.log
                else
                echo -e "NETBIOS UNKOWNt: $obj0t: WINDOWS" >> lindows.log
        fi
        else
        # Check if linux or freebsd
        ssh_get=`ssh -l ims $obj0 '(uname | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' && hostname | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/')'`
        if [ "$?" -eq 0 ]
                then
                uname=`echo $ssh_get | awk -F" " '{printf "%s", $1}'`
                hostname1=`echo $ssh_get | awk -F" " '{printf "%s", $2}'`
                hostname2=`echo $hostname1 | awk -F"." '{printf "%s", $1}'`
                echo -e "$hostname2t: $obj0t: $uname" >> lindows.log
                else
                echo -e "UNKNOWN ERRORt: $obj0t: PLEASE CHECK HOST" >> lindows.log
        fi
fi
done

cat lindows.log | mail -s 'Windows/FreeBSD/Linux Host Audit' your@email.com
