#! /bin/bash

#
# Shell script to start the capture of one experiment.
# CAUTION: mainly use to start a single capture after a crash
#

TSTAMP=`./timestamp.sh`
SSH_HOST="193.50.40.90"
SSH_USER="score"
SSH_CMD="ssh ${SSH_USER}@${SSH_HOST}"

# ${SSH_CMD} "mkdir ~/rtce"

echo "Starting screen capture..."
${SSH_CMD} "./capture-start.sh ${TSTAMP} ~/rtce" &

#sleep 60

#echo "Stopping screen capture..."
#${SSH_CMD} "./capture-stop.sh"

#echo "Downloading screen capture..."
#scp -r ${SSH_USER}@${SSH_HOST}:~/rtce .
