#! /bin/bash

# run a loop over all experiments to extract the timestamp of the first changes

for f in DATA/201*/films[0-9][0-9][0-9].json;
do  
  dir=`dirname $f`
  file=`basename $f`
  expname="${file%.*}"

  if [ $expname == "films011" ] 
  then
	  continue
  else 
	 padname=$expname
	 if [ $expname == "films014" ]
	 then
	    padname="films015"
	 fi
	
	 # run the following command to extract the timestamp of the first interesting changes 
	 echo '*==*' ${padname}
	 ./fetch-first-changes.rb ${padname} ${dir}/etherpad.log.gz ${dir}/dirtyCS.db.gz 
  fi

# run the following command to extract the pad at the right time
# ./resynch-changes-to-get-revision.rb films017 sorting-synching/etherpad.log.gz sorting-synching/dirtyCS.db.gz sorting-synching/dirty.db.gz a.GXaGD5oiTgPmEMN5 1369722157631

done