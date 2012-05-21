#!/bin/bash

#
# Shell script to get text content from a Pad via API.
#
# usage: pad_get_text pad_id [ rev ]
#

API_KEY_FILE="./APIKEY.cfg"
ETHERPAD_HOST_FILE="./ETHERPAD_HOST.cfg"

if [ $1 ]; then
   PAD_ID="$1"      
else
   PAD_ID="DemoPad" 
   echo 'usage: pad_get_text pad_id [ rev ]'
   exit 1
fi

if [ $2 ]; then
   REV="$2"      
else
   REV=""
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

if [ -z $REV ]; then 
  RESULT=`curl -s -k -d apikey=${API_KEY} -d padID=${PAD_ID} -L "http://${ETHERPAD_HOST}/api/1/getText"`
else
  RESULT=`curl -s -k -d apikey=${API_KEY} -d padID=${PAD_ID} -d rev=${REV} -L "http://${ETHERPAD_HOST}/api/1/getText"`
fi	

echo $RESULT
