#!/bin/bash
################################################
# NAME: nc4dns.sh
# Relys on: Netcat
# Function: rehash to hunt DNS in an unknown environment
#
# By: 
#
################################################
echo "Please enter IP network range to hunt:"
echo "eg: 194.29.32"

read range
	for ip in `seq 1 254`;do
		echo $range.$ip >> target.list
done

