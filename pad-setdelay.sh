#!/bin/bash

#
# Shell script to setup delay on a Pad via API.
#
# usage: pad_setdelay pad_id [ delay in ms ]
#

API_KEY_FILE="./APIKEY.cfg"
ETHERPAD_HOST_FILE="./ETHERPAD_HOST.cfg"

if [ $1 ]; then
        PAD_ID="$1"      
else
        PAD_ID="DemoPad" 
        echo 'usage: pad_setdelay pad_id [ delay in ms ]'
        exit 1
fi

if [ $2 ]; then
        DELAY="$2"      
else
        DELAY="5000"
fi

if [ -e ${API_KEY_FILE} ]; then
	API_KEY="`cat ${API_KEY_FILE}`"	
else
	echo "${API_KEY_FILE} is missing."
	exit 1
fi

if [ -e ${ETHERPAD_HOST_FILE} ]; then
	ETHERPAD_HOST="`cat ${ETHERPAD_HOST_FILE}`"	
else
	echo "${ETHERPAD_HOST_FILE} is missing."
	exit 1
fi

RESULT=`curl -s -k -d apikey=${API_KEY} -d padID=${PAD_ID} -d delay=${DELAY} -L "http://${ETHERPAD_HOST_FILE}/api/1/setServerToClientsDelay"`

echo $RESULT
