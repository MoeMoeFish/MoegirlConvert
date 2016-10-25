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
CleanExit() {
    # If successfully locked, rm the file
    if ((locked == 0))
    then
        rm -f conv.lock
    fi
    # exit # <- should I?
}

src_frames=$(identify -format "%n" "${src}")
src_format=$(identify -format "%m" "${src}")

if ((src_frames == 1))
then
	# See if the file to be converted is formatted in JPEG
	if [[ $src_format == "JPEG" ]]
	then
		convert -resize "${width}x${height}"__resize -interlace Plane -- "${src}" "${des}"
	else
		convert -resize "${width}x${height}" -- "${src}" "${des}"
	fi
elif ((src_frames <= 10))
then
	convert -coalesce -- "${src}" gif:- | __resize -- gif:- "${des}"
else
	convert -resize "${width}x${height}" -- "${src}"'[0]' "${des}"
	convert -background green -size 30x20 -gravity center -fill white -font helvetica -pointsize 12 label:GIF gif:- |
		composite -gravity NorthEast -- gif:- "${des}" "${des}"
fi

if ((width <= 300))
then
	CleanExit
fi

## watermark
if ((src_frames == 1))
then
	# See if the file to be converted is formatted in JPEG
	if [[ $src_format == "JPEG" ]]
	then
		composite -interlace Plane -gravity SouthEast -dissolve 50 -- "${watermark}" "${des}" "${des}"
	else
		composite -gravity SouthEast -dissolve 50 -- "${watermark}" "${des}" "${des}"
	fi
elif ((src_frames <= 10))
then
	convert -gravity SouthEast -geometry +0+0 \
		-compose dissolve -define compose:args=50 \
		-layers composite \
		-layers optimize \
		-- "${des}" "null:" "${watermark}" "${des}"
else
	composite -gravity SouthEast -dissolve 50 -- "${watermark}" "${des}" "${des}"
fi
CleanExit

