#! /bin/bash

#
# Shell script to run a test experiment on multiple ssh hosts.
#
#

TSTAMP=`./timestamp.sh`
SSH_HOST="./SSH_HOSTS.cfg"
SSH_USER="score"
SSH_CMD="pssh -h ${SSH_HOST} -l ${SSH_USER}"

${SSH_CMD} "mkdir ~/rtce"

echo "Starting screen capture..."
${SSH_CMD} "./rtce-experiments-toolbox/capture-start.sh ${TSTAMP} ~/rtce &" 
