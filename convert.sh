#!/bin/bash
src=$1
des=$2
width=$3
height=$4
watermark=$5

if [ `identify -format "%n" ${src}` -eq 1 ]
then
	convert ${src} -resize ${width}x${height} ${des}
elif [ `identify -format "%n" ${src}` -le 10 ]
then
	convert ${src} -coalesce gif:- | convert gif:- -resize ${width}x${height} ${des}
else
	convert ${src}[0] -resize ${width}x${height} ${des}
	convert -background green -size 30x20 -gravity center -fill white -font helvetica -pointsize 12 label:GIF gif:- | composite -gravity NorthEast gif:- ${des} ${des}
fi

if [ ${width} -le 100 ]
	then exit
fi


if [ `identify -format "%n" ${src}` -eq 1 ]
then
	composite -gravity SouthEast -dissolve 50 ${watermark} ${des} ${des}
elif [ `identify -format "%n" ${src}` -le 10 ]
then
	convert ${des} -gravity SouthEast -geometry +0+0  null: ${watermark} -compose dissolve -define compose:args=50 -layers composite -layers optimize ${des};
else
	composite -gravity SouthEast -dissolve 50 ${watermark} ${des} ${des}
fi
exit

