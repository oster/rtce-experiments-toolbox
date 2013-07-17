# A quick description of files contained in this directory

delays.md                  values of delay parameters used in experiments

corrections-initial.txt    initial content for the pad of experiment n.1
films-initial.txt          initial content for the pad of experiment n.2
notes-initial.txt          initial content for the pad of experiment n.3

MISC.txt

APIKEY.cfg
ETHERPAD_HOST.cfg
SSH_HOSTS.cfg

pad-create.sh
pad-delete.sh
pad-get-chat.sh
pad-get-ro.sh
pad-get-text.sh
pad-setdelay.sh


pstart.sh
pstop.sh
psl.sh
pclean.sh

capture-start.sh
capture-stop.sh
timestamp.sh

deploy.sh

pshutdown.sh
pfirefox.sh
pstop-firefox.sh
ptest.sh
start-single-capture-after-crash.sh
test.sh
rename-videos.sh



ChangeSet.rb
export_changesets_as_csv.rb

(compute_changerate.rb)
(stats2.rb)
(query2.rb)


convert-chat-as-srt.rb					
fetch-first-changes.rb
resynch-and-convert-chat-srt.rb
resynch-changes-to-get-revision.rb

use-resynch-info.sh
get-resynch-info.sh
resynch-changes-to-get-revision-LOOP.sh
resynch-changes-to-get-revision-LOOP-films.sh
resynch-changes-to-get-revision-LOOP-corrections.sh



----
./fetch-first-changes.rb films017 sorting-synching/etherpad.log.gz sorting-synching/dirtyCS.db.gz 
./resynch-changes-to-get-revision.rb films017 sorting-synching/etherpad.log.gz sorting-synching/dirtyCS.db.gz sorting-synching/dirty.db.gz a.GXaGD5oiTgPmEMN5 1369722157631







