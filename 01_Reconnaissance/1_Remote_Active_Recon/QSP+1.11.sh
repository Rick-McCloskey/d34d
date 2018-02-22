#!/bin/bash
#__________________________________________________________
# Author:     RPM
# License:    XXXX
# Use:        Method Step 1: Read in target file for nmap QS+
# Released:   rmcclos@gmail.com
  version=0.1.11a
# Dependencies:
#       nmap
#		sed
#		perl and Nmap::Parser module (type  "cpan App::cpanminus" then "cpanm Nmap::Parser")
# 		put 2NmapXMLtoCSV.pl in /bin

# ToDo:
#	

# ChangeLog:
#   v0.1.11a - 12/13/17: Adjust for new OSCP
#	v0.1.10 - lost and not used for next update... (found and deprecated)
#	v0.1.9 - 6/25/13: Adjust for new laptop
#	v0.1.8 - 6/18/13: Adjust delimiters so tools can read as IP:Port
#	v0.1.7 - 2/25/13: Determine if list of IP or list of networks
#	v0.1.6 - 2/24/13: Added limited service sorting functionality
#	v0.1.5 - 2/24/13: Added xml to csv conversion and filing
#	v0.1.4 - 2/15/13: Added SMS and email functions
#	v0.1.3 - 2/11/13: Places the scans in the common testing directory structure automatically
#	v0.1.2 - 2/11/13: Places the created scans in a file named after the client and IN or EN       
#	v0.1.1 - 2/10/13: First write - just do QS+ scans from an IP list and name accordingly

# Program: OSCP-QS+1.9a.sh

f_setdefaults(){
	
	#Set this to your desired client base directory location.
	ROOT_DIRECTORY="/mnt/hgfs/OSCP_PWK-2017/exercises/LAB"
	GRUNT_DIR="/mnt/hgfs/OSCP_PWK-2017/tools/grunt"
	SCAN_DIR=$ROOT_DIRECTORY"/"${CLIENT}"-"$INITIALS"+$DATE/scans-"${CLIENT}"-"$INITIALS
	#QSP="-sV -T3 -O -F --version-light -oX "$full_name
	
	#xtarget=$SCANDIR"/"$target

	DATE="`date +%m`-`date +%y`"
	
	# SMS and Mail settings 
	#SUBJECT="SCAN TEST `SMSechotime`"

	#cc_EMAIL=""
	#SMS=""
	#FROM=""
	#MAILSERVER=""

	#mail_USER=""
	#mail_PASS=""

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
	echo "Is the target file a list of IP addresses (y/n):"
	read isList

	echo 
	echo "Are The scans Internal or External?"
	read SCOPE	
}

f_MAKEDIR(){	#Creates directories if not present

	BASEDIR=$ROOT_DIRECTORY"/"${CLIENT}"-"$INITIALS"+$DATE/scans-"${CLIENT}"-"$INITIALS"/"$SCOPE"-"${CLIENT}"-"$INITIALS"/NMAP"
	#SCANDIR=$ROOT_DIRECTORY"/"${CLIENT}"-"$INITIALS"+$DATE/scans-"${CLIENT}"-"$INITIALS"/"
	echo
	echo -e "	[-] `echotime` Building directory structure for $CLIENT. "
	echo
	
        if [ -d $BASEDIR ] ; 
		then 
		echo
		echo -e "	[-] `echotime` Directory for \"$CLIENT\" $SCOPE scans already exists. "
		echo
		sleep 0 ; 
	else 	
		mkdir $BASEDIR
	echo
	echo -e "	[-] `echotime` Completed building directory structure for $CLIENT $SCOPE scans. "
	echo
	fi	
}

f_qsp(){ #Read the target file line by line and scan
	while read line; do 
	
		#read a line from 	
		string=$line
	
		#fix the IP so it can be saved in a nice format
		a=$(echo $string|sed 's/\./-/g') # sets 192.168.1.0/24 to 192-168-1-0/24
		all=$(echo $a|sed 's/\//s/g')    # sets 192-168-1-0/24 to 192-168-1-0s24
	
		#String the variables to make a pretty named file
		scan_name=$SCOPE"-"${CLIENT}"-"$INITIALS"-"$all"-QS+.xml"
		csv_name=$SCOPE"-"${CLIENT}"-"$INITIALS"-"$all"-QS+.csv"
		sort_name=$SCOPE"-"${CLIENT}"-"$INITIALS
		full_name=$BASEDIR"/"$scan_name
		full_csv=$BASEDIR"/"$csv_name

		#create soreted services file names		
		ftp_sort=$BASEDIR"/"ftp.$sort_name.txt
		http_sort=$BASEDIR"/"http.$sort_name.txt
		dns_sort=$BASEDIR"/"dns.$sort_name.txt
		smtp_sort=$BASEDIR"/"smtp.$sort_name.txt
		snmp_sort=$BASEDIR"/"snmp.$sort_name.txt


				
		#Nmap switches for Quick Scan Plus with output in XML with custom name
		QSP="-sV -T3 -O -F --version-light -oX "$full_name

		#FIRE!
		# Mail and SMS Function: "Subject" "Message" "Attachment"
		#f_SMS "`SMSechotime` NMAP-START for $scan_name " "START"
		echo -e "	[-] `echotime` SET NMAP-STARls for $scan_name "
		echo
		nmap $QSP $line
		/bin/2NmapXMLtoCSV.pl $full_name $full_csv

		# Sort csv by key IP and ports
		cat $full_csv | grep 'tcp,open,ftp' >> $ftp_sort.tmp
		cat $ftp_sort.tmp| cut -d',' -f1,4 >> $ftp_sort
		rm $ftp_sort.tmp

		cat $full_csv |grep 'tcp,open,http' >> $http_sort.tmp
		cat $http_sort.tmp | cut -d',' -f1,5 >> $http_sort
		rm $http_sort.tmp

		cat $full_csv |grep 'tcp,open,dns' >> $dns_sort.tmp
		cat  $dns_sort.tmp  | cut -d',' -f1,4 >> $dns_sort
		rm $dns_sort.tmp

		cat $full_csv |grep 'tcp,open,smtp' >> $smtp_sort.tmp
		cat  $smtp_sort.tmp  | cut -d',' -f1,4 >> $smtp_sort
		rm $smtp_sort.tmp
		
		cat $full_csv |grep 'tcp,open,snmp' >> $snmp_sort.tmp
		cat  $snmp_sort.tmp  | cut -d',' -f1,4 >> $snmp_sort
		rm $snmp_sort.tmp

		echo
		echo -e "	[-] `echotime` SET NMAP-STOP for $scan_name "
		echo

		# Mail and SMS Function: "Subject" "Message" "Attachment"
		#f_SMS "`SMSechotime` NMAP-STOP for $scan_name " "STOP"

	done < $target
}

sub_services(){
	while read line; do
		x=$1

		cat $full_csv | grep 'tcp,open,ftp' >> $ftp_sort.tmp
		cat $ftp_sort.tmp| cut -d',' -f1,4 >> $ftp_sort
		rm $ftp_sort.tmp

		cat $full_csv |grep 'tcp,open,http' >> $http_sort.tmp
		cat $http_sort.tmp | cut -d',' -f1,4 >> $http_sort
		rm $http_sort.tmp

		cat $full_csv |grep 'tcp,open,dns' >> $dns_sort.tmp
		cat  $dns_sort.tmp  | cut -d',' -f1,4 >> $dns_sort
		rm $dns_sort.tmp

		cat $full_csv |grep 'tcp,open,smtp' >> $smtp_sort.tmp
		cat  $smtp_sort.tmp  | cut -d',' -f1,4 >> $smtp_sort
		rm $smtp_sort.tmp

	done < $full_csv
}
f_LIST(){
	
		#read a line from 	
		#string=$line
	
		#fix the IP so it can be saved in a nice format
		#a=$(echo $string|sed 's/\./-/g') # sets 192.168.1.0/24 to 192-168-1-0/24
		#all=$(echo $a|sed 's/\//s/g')    # sets 192-168-1-0/24 to 192-168-1-0s24
	
		#String the variables to make a pretty named file
		scan_name=$SCOPE"-"${CLIENT}"-"$INITIALS"-"$target"-QS+.xml"
		csv_name=$SCOPE"-"${CLIENT}"-"$INITIALS"-"$target"-QS+.csv"
		sort_name=$SCOPE"-"${CLIENT}"-"$INITIALS
		full_name=$BASEDIR"/"$scan_name
		full_csv=$BASEDIR"/"$csv_name

		#create soreted services file names		
		ftp_sort=$BASEDIR"/"ftp.$sort_name.txt
		http_sort=$BASEDIR"/"http.$sort_name.txt
		dns_sort=$BASEDIR"/"dns.$sort_name.txt
		smtp_sort=$BASEDIR"/"smtp.$sort_name.txt
		snmp_sort=$BASEDIR"/"snmp.$sort_name.txt


				
		#Nmap switches for Quick Scan Plus with output in XML with custom name
		QSP="-sV -T3 -O -F --version-light -iL "$target" -oX "$full_name

		#FIRE!
		# Mail and SMS Function: "Subject" "Message" "Attachment"
		#f_SMS "`SMSechotime` NMAP-START for $scan_name " "START"
		echo -e "	[-] `echotime` SET NMAP-START for $scan_name "
		echo
		nmap $QSP $line
		/bin/2NmapXMLtoCSV.pl $full_name $full_csv

		# Sort csv by key IP and ports
		cat $full_csv | grep 'tcp,open,ftp' >> $ftp_sort.tmp
		cat $ftp_sort.tmp| cut -d',' -f1,4 >> $ftp_sort
		rm $ftp_sort.tmp

		cat $full_csv |grep 'tcp,open,http' >> $http_sort.tmp
		cat $http_sort.tmp | cut -d',' -f1,4 >> $http_sort
		rm $http_sort.tmp

		cat $full_csv |grep 'tcp,open,dns' >> $dns_sort.tmp
		cat  $dns_sort.tmp  | cut -d',' -f1,4 >> $dns_sort
		rm $dns_sort.tmp

		cat $full_csv |grep 'tcp,open,smtp' >> $smtp_sort.tmp
		cat  $smtp_sort.tmp  | cut -d',' -f1,4 >> $smtp_sort
		rm $smtp_sort.tmp
		
		cat $full_csv |grep 'tcp,open,snmp' >> $snmp_sort.tmp
		cat  $snmp_sort.tmp  | cut -d',' -f1,4 >> $snmp_sort
		rm $snmp_sort.tmp

		echo
		echo -e "	[-] `echotime` SET NMAP-STOP for $scan_name "
		echo

		# Mail and SMS Function: "Subject" "Message" "Attachment"
		#f_SMS "`SMSechotime` NMAP-STOP for $scan_name " "STOP"

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
f_getdescription
f_setdefaults 
f_MAKEDIR
if [ "$isList" == n ]
then
  echo "FIRING f_QSP"
  f_qsp
else
  echo "FIREING IP List"
  f_LIST
fi
 
exit 0
