#!/bin/bash
echo "Please enter IP network range to hunt:"
echo "192.168.1"

read range

	for ip in $(seq 1 254); do
		echo -e $range.$ip >> $range.txt &
done

