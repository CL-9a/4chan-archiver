board="$1"
apiEndpoint="$board/threads.json"
jqCommand='.[].threads | .[].no'

sh ./archiverSkeleton.sh "$board" "$apiEndpoint" "$jqCommand"