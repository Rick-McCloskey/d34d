#!/bin/bash


f_setdefaults(){
	
	#Set this to your desired client base directory location.
	ROOT_DIRECTORY="/media/sf_VM-Share/AttackDrop/Clients"
	
	DATE="`date +%m`-`date +%y`"
	
	# SMS and Mail settings 
	#SUBJECT="SCAN TEST `SMSechotime`"

	cc_EMAIL=""
	SMS=""
	FROM=""
	MAILSERVER="smtp.gmail.com"

	mail_USER=""
	mail_PASS=""

	
}

f_SMS(){ # Mail and SMS Function: "Subject" "Message" "Attachment"
 	SUBJECT=$1
	MAILMESSAGE=$2
	#ATTACHMENT=$3 # -a $ATTACHMENT

	mailstring="-o tls=auto -xu $mail_USER -xp $mail_PASS -f $FROM -t $SMS -cc $cc_EMAIL -u $SUBJECT -s $MAILSERVER -m $MAILMESSAGE"
	# mailstring="-o tls=auto -xu $USER -xp $PASS -f $EMAIL -t $EMAIL -u $SUBJECT -s $MAILSERVER -m $MAILMESSAGE -a $ATTACHMENT"
	
	sendemail $mailstring
}

f_getdescription(){ #Ask for user input  
	echo "This script reads in a file of IP and intended file names [IPrange FileName]."
	echo "It then executes 1 nmap 'Quick Scan Plus' scan per entry and writes results"
	echo "to an xml file in a directory named after the client."
	echo 
	echo "Please input the name of the client being scanned:"
	echo "e.g. Otter"
	read CLIENT

	echo 
	echo "Please input your initials so we can tell scans apart:"
	echo "e.g. RPM"
	read INITIALS

	echo 
	echo "What is the name of the input target file:"
	read target

	echo 
	echo "Are The scans Internal or External?"
	read SCOPE	
}

DNS_ENUM(){ #Read the target file line by line and scan
	while read line; do 
	
		#read a line from 	
		string=$line
		
		#String the variables to make a pretty named file
		scan_name=$SCOPE"-"${CLIENT}"-"$INITIALS"-"$SCOPE"-DNS.txt"
		full_name=$BASEDIR"/"$scan_name

		#FIRE!
		
		echo -n $string "," 
		whois  $string  | grep -e "Rackspace Hosting RSCP" -e "Rackspace Hosting RACKS" -e "Rackspace Hosting"
		echo -n "," 
		host $string| grep name
		echo -n ","  
		echo 
		#echo -e $string >> $scan_name
		#whois  $string  | grep "Rackspace Hosting RSCP" >> $scan_name

	done < $target
}

echotime(){ #simply displays the time to the screen
        echo -e "\e[00;30m`date +"%T"`\e[00m"
}

SMSechotime(){ #simply displays the time to the screen
        echo -e "`date +"%T"`"
}

f_date(){
	echo -e $DATE 
}

#main
f_setdefaults
f_getdescription
#f_SMS "`SMSechotime` DNS-START for $scan_name " "START"
echo -e "	[-] `echotime` DNS-START for $scan_name "
DNS_ENUM
#f_SMS "`SMSechotime` DNS-STOP for $scan_name " "STOP"
echo -e "	[-] `echotime` DNS-STOP for $scan_name "
