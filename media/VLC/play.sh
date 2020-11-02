#!/bin/bash
#
# What this is:
#	Script to randomly play albums or songs through the VLC command line interface.
#	Tested on Windows with git-bash as shell. See below for options.
#   To skip an album/song being played, just close the VLC app and the script will
#	continue with the next.
#	To stop the script, type ctrl-c in the shell, and the next time that VLC is closed
#	the script will exit.
#
# Usage: run from the folder that contains artist subfolders, which each contain album
#	subfolders.
# play.sh
#   play albums (all the music files in a randomly selected album folder)
# play.sh songs
#   play songs (a randomly selected single music file)
# play.sh songs easy.txt
#   play randomly selected songs selected from album list in "easy.txt" (see below for more)
# play.sh albums '' 'Sheryl,Michelle Branch,Tom Petty'"
#	play randomly selected albums from artist folder names starting with one of these strings
# play.sh songs '' 'Sheryl,Michelle Branch,Tom Petty'"
#	play randomly selected songs from artist folder names starting with one of these strings
#
# creating and using album lists:
#   album lists are formatted as lines with "folder/subfolder" ala
# 		Adele/21
# 		Allison Crowe/Little Light (originals)
# 		Badfinger/Straight Up
#	You can create an album list using the command below, then edit to customize it.
#		find . -type d | sed 's~./~~' | grep '/'
#		or
#		ls -d -1 $(pwd)/*/* | sed "s~$(pwd)/~~" | grep '/$' | sed 's~/$~~'

play="${1:-album}"		# album|songs
list="${2:-albums.txt}"	# albums.txt|(filename of album list)
filter="${3:-}"			# comma-separated list of album name prefixes to select

IFS=','; read -ra filters <<< "$filter"
rm albums-temp.txt
if [[ "$list" == "" ]]; then
	for f in "${filters[@]}"; do
		ls -d -1 "$f*/*" | grep '/$' >>albums-temp.txt
	done
else
	if [[ "$filter" != "" ]]; then
		for f in "${filters[@]}"; do
			grep "^$f" $list >>albums-temp.txt
		done
	else
		cp $list albums-temp.txt
	fi
fi

if [[ "$play" == "album" ]]; then
	while true; do
		/c/Program\ Files/VideoLAN/VLC/vlc.exe --play-and-exit \
		"$(shuf -n 1 albums-temp.txt)"
	done
else
	while true; do
		album="$(shuf -n 1 albums-temp.txt)"
		find "$album/". -name "*.mp3" >songs-temp.txt
		find "$album/". -name "*.wma" >>songs-temp.txt
		find "$album/". -name "*.aac" >>songs-temp.txt
		/c/Program\ Files/VideoLAN/VLC/vlc.exe --play-and-exit \
		"$(shuf -n 1 songs-temp.txt)"
	done
	rm songs-temp.txt
fi
rm albums-temp.txt
