#! /bin/bash

#
# Shell script to clean experiments on multiple ssh hosts.
#
#

SSH_HOST="./SSH_HOSTS.cfg"
SSH_USER="score"
SSH_CMD="pssh -h ${SSH_HOST} -l ${SSH_USER}"

${SSH_CMD} "rm -rf ~/rtce"
