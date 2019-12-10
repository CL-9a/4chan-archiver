#!/usr/bin/env bash

board="$1"
apiEndpoint="$board/archive.json"
jqCommand='.[]'

sh ./archiverSkeleton.sh "$board" "$apiEndpoint" "$jqCommand"