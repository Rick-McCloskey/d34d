#!/bin/bash
#__________________________________________________________
# Author:     RPM
# License:    XXXX
# Use:        Method Step 1: Read in target file for nmap QS+
# Released:   rmcclos@gmail.com
  version=0.4
# Dependencies:
#       nmap
#	sed

# ToDo:
#	Fix the MAKDIR if they do not exist. Works if the Client Setup script was run first.

# ChangeLog:
#	v0.4 - 2/15/13: Added SMS and email functions
#	v0.3 - 2/11/13: Places the scans in the common testing directory structure automatically
#	v0.2 - 2/11/13: Places the created scans in a file named after the client and IN or EN       
#	v0.1 - 2/10/13: First write - just do QS+ scans from an IP list and name accordingly

# Program: QS+.sh

f_setdefaults(){
	
	#Set this to your desired client base directory location.
	ROOT_DIRECTORY="/media/sf_VM-Share/AttackDrop/Clients"
	
	DATE="`date +%m`-`date +%y`"
	
	# SMS and Mail settings 
	

	cc_EMAIL=""
	SMS=""
	FROM=""
	MAILSERVER=""

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
	echo "What is the name of the client provided range file:"
	read target

	echo 
	echo "Are The scans Internal or External?"
	read SCOPE	
}

f_MAKEDIR(){	#Creates directories if not present

	BASEDIR=$ROOT_DIRECTORY"/"${CLIENT}"-"$INITIALS"+$DATE/scans-"${CLIENT}"-"$INITIALS"/" #$SCOPE"-"${CLIENT}"-"$INITIALS"/NMAP"

	echo
	echo -e "	[-] `echotime` Building directory structure for $CLIENT. "
	echo
	
        if [ -d $BASEDIR ] ; 
		then 
		echo
		echo -e "	[-] `echotime` Directory for \"$CLIENT\" scans already exists. "
		echo
		sleep 0 ; 

	else 	
		mkdir $BASEDIR


	echo
	echo -e "	[-] `echotime` Completed building directory structure for $CLIENT scans. "
	echo
	fi	
}

f_qsp(){ #Read the target file line by line and scan
	#while read line; do 
	
		#read a line from 	
		string=$line
	
		#fix the IP so it can be saved in a nice format
		a=$(echo $string|sed 's/\./-/g') # sets 192.168.1.0/24 to 192-168-1-0/24
		all=$(echo $a|sed 's/\//s/g')    # sets 192-168-1-0/24 to 192-168-1-0s24
	
		#String the variables to make a pretty named file
		scan_name=$SCOPE"-"${CLIENT}"-"$INITIALS"-"$all"-QS+.xml"
		full_name=$BASEDIR"/"$scan_name

		#Nmap switches for Quick Scan Plus with output in XML with custom name
		#nmap -p80 -PS80 -oG -iL <clint list> | awk '/open/{print $2}'
		nessus_scan="-sP -iL $target "
		nessus_awk="'/open/{print $2}'"

		#FIRE!
		# Mail and SMS Function: "Subject" "Message" "Attachment"
		f_SMS "`SMSechotime` NMAP SWEEP-START for $scan_name " "START"

		

		echo -e "	[-] `echotime` NMAP SWEEP-START for $scan_name "
		echo
		nmap $nessus_scan | awk $nessus_awk >> $CLIENT-$SCOPE-alive.txt 
		echo
		echo -e "	[-] `echotime` NMAP SWEEP-STOP for $scan_name "
		echo

		# Mail and SMS Function: "Subject" "Message" "Attachment"
		f_SMS "`SMSechotime` NMAP SWEEP-STOP for $scan_name " "STOP"

	#done < $target
}

f_exit(){ #this is called upon ESC/Cancel press
        rm /tmp/answer
        echo  "[+] Exiting.... see ya"
        exit 1
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

### MAIN ###
f_setdefaults #Keep this as first line 
f_getdescription
f_MAKEDIR
f_qsp

exit 0
