#!/usr/bin/env bash

# curl apiEndpoint with If-Modified-Since if stored, parse returned json with jqCommand, call ./archive.sh
# usage: sh skeletonApiAccessor.sh po archive.json '.[]'

board="$1"
apiEndpoint="$2"
jqCommand="$3"
baseUrl="https://a.4cdn.org"
lastModifiedFolder="./_sharchiverLastModified/$board"
lastModifiedFile="./_sharchiverLastModified/${apiEndpoint}.txt"
tmpHeaders=$(mktemp)
tmpData=$(mktemp)

if [ ! -d "./archive/$board" ]; then
	mkdir --parents "./archive/$board"
fi
if [ ! -d ".$lastModifiedFolder" ]; then
	mkdir --parents "$lastModifiedFolder"
fi


if [ -f "$lastModifiedFile" ]; then
	lastCheck="$(<$lastModifiedFile)"
	curl "$baseUrl/$apiEndpoint" \
		--silent \
		--header "If-Modified-Since:$lastCheck" \
		--dump-header $tmpHeaders \
		--output $tmpData
else
	curl "$baseUrl/$apiEndpoint" \
		--silent \
		--dump-header $tmpHeaders \
		--output $tmpData
fi

threads="$(cat $tmpData | jq "$jqCommand")"

for thread in $threads; do
	sh ./archive.sh "$board" "$thread"
done

grep "last-modified:" $tmpHeaders | sed 's/^last-modified: //' > "$lastModifiedFile"

rm $tmpHeaders
rm $tmpData
