#!/bin/sh
#Matt Reid matthew@servepath.com / themattreid@gmail.com
#10/10/05
#simple script to interface with Ping and Nmap to support ping of subnets
#$1 is the IP or Subnet, $2 is the ping -c amount

helpMe() {
	echo "Replacement for the Ping command. Uses NMap to support subnet ping scanning."
	echo "Usage: ping [ip/subnet] [ping count]"
	echo "location of Nmap: `which nmap`"
	echo "location of Ping: `which ping`"
}

#check if second arg for ping count was given
pingIp() {
IP=$1
#set COUNT=4 if $2 is not given
COUNT=${2:-4}
$PINGC -c $COUNT $IP
}

checkArg() {
if [ -z "$1" ]; then #no IP/subnet given
    helpMe
else
    if echo $1 | grep -q -v / ; then 
	echo "#### SINGLE IP - NOT A SUBNET - USING PING ####"
	pingIp $1 $2
    else
	echo "#### SUBNET - USING NMAP ####"
        $NMAPC -sP $1
    fi
fi
}

#find locations of necessary commands
PINGC=`which ping`
NMAPC=`which nmap`
#run the functions
checkArg $1 $2
