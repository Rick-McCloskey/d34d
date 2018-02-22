#!/bin/bash
echo "Please enter IP network range to hunt:"
echo "192.168.1"

read range

	for ip in $(seq 1 254); do
		ping -c 1 $range.$ip | grep icmp_seq=1 >> $range.ping.txt &
done
