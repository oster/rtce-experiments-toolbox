#! /bin/bash

#
# Shell script to run a test experiment on multiple ssh hosts.
#
#

TSTAMP=`./timestamp.sh`
SSH_HOST="./SSH_HOSTS.cfg"
SSH_USER="score"
SSH_CMD="pssh -h ${SSH_HOST} -l ${SSH_USER}"

#${SSH_CMD} "mkdir ~/rtce"

#echo "Starting screen capture..."
#${SSH_CMD} "./capture-start.sh ${TSTAMP} ~/rtce" &

#sleep 60

echo "Stopping screen capture..."
${SSH_CMD} "./capture-stop.sh"

sleep 10

echo "Downloading screen capture..."
pslurp -h ${SSH_HOST} -r -l ${SSH_USER} /home/${SSH_USER}/rtce .
