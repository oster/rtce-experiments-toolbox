#!/bin/bash

#
# Shell script to get the read-only link of Pad via API.
#
# usage: pad_get_ro pad_id
#

API_KEY_FILE="./APIKEY.cfg"
ETHERPAD_HOST_FILE="./ETHERPAD_HOST.cfg"

if [ $1 ]; then
        PAD_ID="$1"      
else
        PAD_ID="DemoPad" 
        echo 'usage: pad_get_ro pad_id'
        exit 1
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


RESULT=`curl -s -k -d apikey=${API_KEY} -d padID=${PAD_ID} -L "http://${ETHERPAD_HOST}/api/1/getReadOnlyID"`

READONLY_ID=`echo ${RESULT} | sed 's/.*readOnlyID\":\"//'`
READONLY_ID=`echo ${READONLY_ID} | sed 's/\"}}//'`

echo "http://${ETHERPAD_HOST}/ro/${READONLY_ID}"

