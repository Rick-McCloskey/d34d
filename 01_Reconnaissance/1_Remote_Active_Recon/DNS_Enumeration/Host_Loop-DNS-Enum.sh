#!/bin/bash
echo "Please enter IP network range to hunt:"
echo "192.168.1"

read range

	for ip in $(seq 160 191); do
		host $range.$ip | grep name >> $range.DNS.txt &
done

