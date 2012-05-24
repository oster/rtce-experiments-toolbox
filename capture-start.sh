#!/bin/bash

#
# Shell script to capture the X11 local screen.
#
# usage: capture-start [ TIMESTAMP ] [ OUTPUT_DIR ]
#

if [ $1 ]; then
	STAMP="$1"	
else
	STAMP="`date +%Y%m%d-%H%M`-${HOSTNAME}"	
fi

if [ $2 ]; then
 	OUTPUT_DIR=$2
else
	OUTPUT_DIR=./
fi

export DISPLAY=localhost:0.0
OUTPUT_FILE=${OUTPUT_DIR}/${STAMP}-screencast.webm

gst-launch-0.10 -e ximagesrc,use-damage=0,show-pointer=1 \
                   ! video/x-raw-rgb,framerate=15/1 \
                   ! ffmpegcolorspace \
                   ! vp8enc,speed=6,quality=8,threads=2 \
                   ! webmmux \
                   ! filesink location=${OUTPUT_FILE}

