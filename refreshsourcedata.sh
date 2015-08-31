#!/bin/bash
set -e

if [[ -n $(find $1 -mtime -1 -size +0c) ]]; then
	echo $1 already downloaded/updated today
else
	if [[ -n $(find $1 -mtime -30 -size +10M) ]]; then
		echo "$1 exists and is worth patching (less than 30 days old and over 10MB)  - updating"
		./osmupdate $1 $1.updated --day --verbose 1
		mv $1.updated $1
	else
		echo "$1 doesn't exist, is under 10MB or is older than 30 days - redownloading"		
		curl "http://download.geofabrik.de/europe/$1">$1
	fi
fi
