#!/usr/bin/env bash

board="$1"
page="$2"
apiEndpoint="$board/${page}.json"
jqCommand='.threads[].posts[] | select(.resto == 0).no'

sh ./archiverSkeleton.sh "$board" "$apiEndpoint" "$jqCommand"