#! /bin/bash

#
# Shell script to stop a test experiment on multiple ssh hosts.
#
#

SSH_HOST="./SSH_HOSTS.cfg"
SSH_USER="score"
SSH_CMD="pssh -h ${SSH_HOST} -l ${SSH_USER}"

echo "Stopping screen capture..."
${SSH_CMD} "./rtce-experiments-toolbox/capture-stop.sh"

sleep 10

echo "Downloading screen capture..."
pslurp -h ${SSH_HOST} -r -l ${SSH_USER} /home/${SSH_USER}/rtce .
