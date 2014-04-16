#/bin/bash

# This script is used to create a clean etherpad db containing only relevant revisions history from all experiments

cd "./DATA-by-num/"
for NUM in `ls`;
do
	gzcat "${NUM}/dirty.db.gz" | grep "\(corrections\|notes\|films\)${NUM}\|token2author:\|globalAuthor:";
done

