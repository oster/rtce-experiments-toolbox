#!/bin/bash

#
# Shell script to deploy scripts on multiple ssh hosts.
#
#

SSH_HOST=./SSH_HOSTS.cfg
SSH_USER=score

pscp -h ${SSH_HOST} -l ${SSH_USER} capture-*.sh /home/${SSH_USER}/
