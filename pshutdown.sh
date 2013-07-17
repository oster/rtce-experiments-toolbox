#! /bin/bash

SSH_HOST="./SSH_HOSTS.cfg"
SSH_USER="score"
SSH_CMD="pssh -h ${SSH_HOST} -l ${SSH_USER}"

${SSH_CMD} "echo tagada | sudo -S shutdown -h now"