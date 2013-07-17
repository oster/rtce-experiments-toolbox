#! /bin/bash

SSH_HOST="./SSH_HOSTS.cfg"
SSH_USER="score"
SSH_CMD="pssh -h ${SSH_HOST} -l ${SSH_USER}"
ETHERPAD_HOST=`cat ETHERPAD_HOST.cfg`


${SSH_CMD} 'env DISPLAY=:0 firefox http://www.loria.fr/~charoy/index.php?n=Main.RTECExperiment &'
#${SSH_CMD} "env DISPLAY=:0 firefox http://ec2-184-72-75-76.compute-1.amazonaws.com/p/corrections013 &"