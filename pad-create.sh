#!/bin/bash

#
# Shell script to create a Pad via API.
#
# usage: pad_create pad_id [ text ]
#

API_KEY_FILE="./APIKEY.cfg"
ETHERPAD_HOST_FILE="./ETHERPAD_HOST.cfg"

if [ $1 ]; then
        PAD_ID="$1"      
else
        PAD_ID="DemoPad" 
        echo 'usage: pad_create pad_id [ text ]'
        exit 1
fi

if [ $2 ]; then
        TEXT="$2"      
else
        TEXT=""
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


RESULT=`curl -s -k -d apikey=${API_KEY} -d padID=${PAD_ID} -d text=${TEXT} -L "http://${ETHERPAD_HOST}/api/1/createPad"`

echo $RESULT
