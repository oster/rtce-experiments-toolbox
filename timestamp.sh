#!/bin/bash

#
# Shell script to generate a timestamp.
# Timestamp looks like: "20120519-1517-bazinga-oster"
#

if [ $1 ]; then
 	STAMP="`date +%Y%m%d-%H%M`-${HOSTNAME}-${USER}-$1"
else
 	STAMP="`date +%Y%m%d-%H%M`-${HOSTNAME}-${USER}"
fi

echo ${STAMP}
