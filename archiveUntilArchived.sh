#!/usr/bin/env bash

board=$1
thread=$2
waitTime=${3:-3800}

while sh ./archive.sh "$board" "$thread" ; [ $? -ne 2 ] ; do
	echo "waiting for $waitTime seconds"
	sleep $waitTime
done