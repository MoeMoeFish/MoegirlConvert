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
}

set -e
trap 'CleanExit; exit' INT TERM EXIT

src_frames=$(identify -format "%n" -- "${src}")

# TODO: Should be the format of the dest file
des_format=$(identify -format "%m" -- "${src}")

src_size=$(du -k -- "${src}" | cut -f1)

## resize
# Always use MIFF as ImageMagick intermediate file format
if ((src_frames == 1))
then
	convert -resize "${width}x${height}" -- "${src}" "miff:${des}"
elif ((src_frames <= 10))
then
	convert -coalesce -resize "${width}x${height}" -- "${src}" "miff:${des}"
else
	convert -resize "${width}x${height}" -- "${src}[0]" "miff:${des}"
	convert -background green -size 30x20 -gravity center -fill white -font helvetica -pointsize 12 label:GIF miff:- |
		composite -gravity NorthEast -- miff:- "miff:${des}" "miff:${des}"
	src_frames='1'
fi

## add watermark
if ((width > 300))
then
	if ((src_frames == 1))
	then
		composite -gravity SouthEast -dissolve 50 -- "${watermark}" "miff:${des}" "miff:${des}"
	else
		convert -gravity SouthEast -geometry +0+0 \
			-compose dissolve -define compose:args=50 \
			-layers composite \
			-- "miff:${des}" "null:" "${watermark}" "miff:${des}"
	fi
fi

## write output
# -interlace Plane and -interlace Line are exactly the same for JPEG/PNG
if [[ "${des_format}" == 'JPEG' || "${des_format}" == 'PNG' ]]
then
	if ((src_size > 10))
	then
		convert -quality 85 -interlace Plane -- "miff:${des}" "${des}"
	else
		convert -interlace Plane -- "miff:${des}" "${des}"
	fi
elif ((src_frames > 1))
then
	convert -layers optimize -- "miff:${des}" "${des}"
else
	convert -- "miff:${des}" "${des}"
fi

CleanExit
trap - INT TERM EXIT
