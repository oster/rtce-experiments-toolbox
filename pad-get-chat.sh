#!/bin/bash

#
# Shell script to get chat records from a Pad via API.
#
# usage: pad_get_chat pad_id 
#

API_KEY_FILE="./APIKEY.cfg"
ETHERPAD_HOST_FILE="./ETHERPAD_HOST.cfg"

if [ $1 ]; then
   PAD_ID="$1"      
else
   echo 'usage: pad_get_chat pad_id'
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

RESULT=`curl -s -k -d apikey=${API_KEY} -d padID=${PAD_ID} -L "http://${ETHERPAD_HOST}/api/1/getChat"`

echo $RESULT


