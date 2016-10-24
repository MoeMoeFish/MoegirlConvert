#!/bin/bash
src=$1
des=$2
width=$3
height=$4
watermark=$5

##### Queue
# If convert is already running, i.e. file exsits, retry 15 times with 1 sec interval
lockfile -1 -r15 conv.lock
locked=$?
# Doesn't matter if it is locked
# Will commit to convert anyway
function CleanExit() {
    # If successfully locked, rm the file
    if [ $locked -eq 0 ]
    then
        rm -f conv.lock
    fi
}


if [ `identify -format "%n" ${src}` -eq 1 ]
then	
	# See if the file to be converted is formatted in JPEG
	if [ `identify -format "%m" ${src}` == "JPEG" ]
	then
		convert ${src} -interlace Plane -resize ${width}x${height} ${des}
	else
		convert ${src} -resize ${width}x${height} ${des}
	fi
elif [ `identify -format "%n" ${src}` -le 10 ]
then
	convert ${src} -coalesce gif:- | convert gif:- -resize ${width}x${height} ${des}
else
	convert ${src}[0] -resize ${width}x${height} ${des}
	convert -background green -size 30x20 -gravity center -fill white -font helvetica -pointsize 12 label:GIF gif:- | composite -gravity NorthEast gif:- ${des} ${des}
fi

if [ ${width} -le 300 ]
	then CleanExit
fi


if [ `identify -format "%n" ${src}` -eq 1 ]
then
	# See if the file to be converted is formatted in JPEG
	if [ `identify -format "%m" ${src}` == "JPEG" ]
	then
		composite -interlace Plane -gravity SouthEast -dissolve 50 ${watermark} ${des} ${des}
	else
		composite -gravity SouthEast -dissolve 50 ${watermark} ${des} ${des}
	fi
elif [ `identify -format "%n" ${src}` -le 10 ]
then
	convert ${des} -gravity SouthEast -geometry +0+0  null: ${watermark} -compose dissolve -define compose:args=50 -layers composite -layers optimize ${des};
else
	composite -gravity SouthEast -dissolve 50 ${watermark} ${des} ${des}
fi
CleanExit

