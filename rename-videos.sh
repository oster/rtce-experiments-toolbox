#!/bin/bash


# dummy script to automate renaming of video recording files

GROUP=G10
EXPERIMENT=EXP3

SRC_DIR=./${GROUP}-${EXPERIMENT}
OUT_DIR=./VIDEOS_PROCESSING
OUT_SUFFIX=


U1_NAME=USER1
U1_IP=193.50.40.90

U2_NAME=USER2
U2_IP=193.50.40.97

U3_NAME=USER3
U3_IP=193.50.40.93

U4_NAME=USER4
U4_IP=193.50.40.89

RECORD_TIME=`ls ${SRC_DIR}/${U2_IP}/rtce/*-screencast.webm | sed 's/.*rtce\/\(2012[0-9]\{4\}-[0-9]\{4\}\).*/\1/'`

#RECORD_TIME=20120524-1502
#echo ${SRC_DIR}/${U1_IP}/rtce/${RECORD_TIME}-Bazinga.local-oster-screencast.webm

cp ${SRC_DIR}/${U1_IP}/rtce/${RECORD_TIME}-oster-screencast.webm ${OUT_DIR}/${RECORD_TIME}-${GROUP}-${EXPERIMENT}-${U1_NAME}-screencast${OUT_SUFFIX}.webm
cp ${SRC_DIR}/${U2_IP}/rtce/${RECORD_TIME}-oster-screencast.webm ${OUT_DIR}/${RECORD_TIME}-${GROUP}-${EXPERIMENT}-${U2_NAME}-screencast${OUT_SUFFIX}.webm
cp ${SRC_DIR}/${U3_IP}/rtce/${RECORD_TIME}-oster-screencast.webm ${OUT_DIR}/${RECORD_TIME}-${GROUP}-${EXPERIMENT}-${U3_NAME}-screencast${OUT_SUFFIX}.webm
cp ${SRC_DIR}/${U4_IP}/rtce/${RECORD_TIME}-oster-screencast.webm ${OUT_DIR}/${RECORD_TIME}-${GROUP}-${EXPERIMENT}-${U4_NAME}-screencast${OUT_SUFFIX}.webm

