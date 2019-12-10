#!/usr/bin/env bash

#makes an archive of a 4chan thread, based on https://basc-archiver.readthedocs.io/en/stable/documents/chan.zip-standard/
#overwrite previous archives, I'm too lazy to do any fancy diff to spot deleted posts (and wouldn't do it in bash probably)
#exit codes:
#1: unhandled http return code
#2: on-disk thread was archived and cannot have changed 
#3: thread didn't change since last stored modified time

board="$1"
thread="$2"
archiveFolder="./archive"

baseUrl="https://a.4cdn.org"

mkdir -p "$archiveFolder/$board/$thread"
mkdir -p "$archiveFolder/$board/$thread/thumbs"
mkdir -p "$archiveFolder/$board/$thread/images"


if [ -f "$archiveFolder/$board/$thread/$thread.json" ]; then
	cat "$archiveFolder/$board/$thread/$thread.json" | jq -e '.[][0] | select(.archived == 1)' >/dev/null

	if [ $? -ne 4 ]; then
		echo "thread is archived, pointless to re-check (ret: 2)"
		exit 2
	fi
fi
#todo remove that and fix your filenames
if [ -f "$archiveFolder/$board/$thread/thread.json" ]; then
	cat "$archiveFolder/$board/$thread/thread.json" | jq -e '.[][0] | select(.archived == 1)' >/dev/null

	if [ $? -ne 4 ]; then
		echo "thread is archived, pointless to re-check (ret: 2)"
		exit 2
	fi
fi

if [ -f "$archiveFolder/$board/$thread/curlheaders.txt" ]; then
	lastModified="$(grep "last-modified:" "$archiveFolder/$board/$thread/curlheaders.txt" | sed 's/^last-modified: //')"
	echo "downloading json for thread $thread with If-Modified-Since:$lastModified"

	tmpHeaders=$(mktemp)
	tmpOutput=$(mktemp)
	httpCode=$(curl "$baseUrl/$board/thread/$thread.json" --silent \
		--write-out '%{http_code}' \
		--header "If-Modified-Since:$lastModified" \
		--dump-header $tmpHeaders \
		--output $tmpOutput)
	sleep 1

	if [ $httpCode == 200 ]; then
		echo "got new data"
		mv $tmpHeaders "$archiveFolder/$board/$thread/curlheaders.txt"
		mv $tmpOutput "$archiveFolder/$board/$thread/$thread.json"
	elif [ $httpCode == 304 ]; then
		echo "thread unchanged since last download (ret: 3)"
		rm $tmpHeaders
		rm $tmpOutput
		exit 3
	else
		echo "unhandled status code $statusCode ($tmpHeaders $tmpOutput) (ret: 1)" 
		exit 1
	fi
else
	echo "downloading json for thread $thread"
	curl "$baseUrl/$board/thread/$thread.json" --silent \
		--dump-header $archiveFolder/$board/$thread/curlheaders.txt \
		--output $archiveFolder/$board/$thread/$thread.json
fi
sleep 1



files="$(cat $archiveFolder/$board/$thread/$thread.json | jq '.[] | .[].tim | select(. != null)')"

echo "downloading thumbnails for thread $thread"
for file in $files; do
	#todo check md5 hash?
	if [ -f "$archiveFolder/$board/$thread/thumbs/${file}s.jpg" ]; then
		echo "skipping thumbnail for file $file"
	else
		echo "downloading thumbnail for file $file in thread $thread"
		curl "https://i.4cdn.org/$board/${file}s.jpg" --output "$archiveFolder/$board/$thread/thumbs/${file}s.jpg" --silent
		sleep 1
	fi
done
echo "done downloading thumbnails for thread $thread"



filesWithExt="$(cat $archiveFolder/$board/$thread/$thread.json | jq '.[] | .[] | select(. | has("tim")) | (.tim | tostring) + .ext')"

echo "downloading files for thread $thread"
for file in $filesWithExt; do
	file="$(echo $file | tr -d '"')"
	#todo check md5 hash?
	if [ -f "$archiveFolder/$board/$thread/images/${file}" ]; then
		echo "skipping file $file as it already exist"
	else
		echo "downloading file $file in thread $thread"
		curl "https://i.4cdn.org/$board/$file" --output "$archiveFolder/$board/$thread/images/${file}" --silent
		sleep 1
	fi
done
echo "done downloading files for thread $thread"
