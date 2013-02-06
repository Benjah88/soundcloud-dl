#!/bin/bash
#soundcloud music downloader by http://360percents.com
#hosted on https://github.com/lukapusic/soundcloud-dl/
#Author: Luka Pusic <luka@pusic.si>

output=${2:-$('pwd')} 

echo "[i] soundcloud.com music downloader by http://360percents.com (wget version)";   

if [ -z "$1" ]; then
	echo "";echo "[i] Usage: `basename $0` http://soundcloud.com/link_with_tracks_on_page";echo "";exit
fi

if [ -z "$2" ]; then
	
	echo "No output path specified. Files will be downloaded to:" "$output"; exit
fi

pages=`wget "$1" -q --user-agent 'Mozilla/5.0' -O - | tr '"' "\n" | grep "tracks?" | grep "page=" | awk -F= '{print $NF}' | sort -nu | tail -n 1`

if [ -z "$pages" ]; then
	pages=1
fi

echo "[i] Found $pages pages of songs!"
for (( page=1; page <= $pages; page++ ))
do
if [ "$pages" = "1" ]; then
	this=`wget -q --user-agent='Mozilla/5.0' $1 -O -`;
else
	this=`wget -q --user-agent='Mozilla/5.0' $1?page=$page -O -`;
fi
songs=`echo "$this" | grep 'streamUrl' | tr '"' "\n" | sed 's/\\u0026amp;/\&/' | grep 'http://media.soundcloud.com/stream/' | sed 's/\\\\//'`;
songcount=`echo "$songs" | wc -l`
titles=`echo "$this" | grep 'title":"' | tr ',' "\n" | grep 'title' | cut -d '"' -f 4`

if [ -z "$songs" ]; then
	echo "[!] No songs found at $1." && exit
fi

echo "[+] Downloading $songcount songs from page $page..."

if [ ! -d "$output" ]; then
    echo "Folder created at: $output";
    mkdir -p $output;
fi


for (( songid=1; songid <= $songcount; songid++ ))
do
	title=`echo "$titles" | sed -n "$songid"p`
	echo "[-] Downloading $title..."
	url=`echo "$songs" | sed -n "$songid"p`;
	wget -c -q --user-agent='Mozilla/5.0' -O "$output/$title.mp3" $url;
done
done
