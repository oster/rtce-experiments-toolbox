#! /usr/bin/python -tt

import os
import re
import json
import gzip
from datetime import datetime, timedelta 
import time
from collections import Counter

last_uid = -1
user_ids = {}

def reset_user_ids():
	global last_uid
	global user_ids
	last_uid = -1
	user_ids = {}
	
def generate_user_id(str_uid):
        global last_uid
        global user_ids
        
        if str_uid in user_ids:
                return user_ids[str_uid]
        else:
                last_uid = last_uid + 1
                user_ids[str_uid] = last_uid
                return last_uid

def load_pad_revisions(db_file, padid):
	with gzip.open(db_file, 'rb') as f:		
		revisions = []
		pattern_rev_metadata = re.compile('{"key":"pad:'+padid+':revs:([0-9]+)"')
		pattern_rev_data = re.compile('pad:'+padid)
		
		while True:
			try:
				line = f.next()
				match = pattern_rev_metadata.match(line)
				if match:
					rev = int(match.group(1)) #-> to int ?
					rev_partA = json.loads(line)
					rev_partB = json.loads(f.next())
					if not pattern_rev_data.match(rev_partB['key']):
						raise Exception('missing pad content for rev:%i' % (rev))
					if rev_partB['val']['head'] != rev:
						raise Exception( 'head (%i) does not match with current rev (%i)' % (rev_partB['val']['head'], rev))
					revision = {}			
					revision['rev'] = rev
					revision['timestamp'] = rev_partA['val']['meta']['timestamp']
					revision['datetime'] = datetime.fromtimestamp(int(revision['timestamp']) / 1000)
					revision['author'] = rev_partA['val']['meta']['author']
					revision['content'] = rev_partB['val']['atext']['text']

					revisions.append(revision)
										
			except StopIteration:
				break
		return revisions

def format_time(timestamp):
	return timestamp.strftime('%H:%M:%S')
	
def get_revision(revisions, revision_num):
	return [ rev for rev in revisions if rev['rev'] == revision_num ][0]

def get_revision_at_time(revisions, certain_time):
	return [ rev for rev in revisions if rev['datetime'] <= certain_time ][-1]
	
	
def write_revision_content(filename, rev):
	with open(filename, "w") as w:
		w.write(rev['content'].encode('utf8'))	
	
		
def extract_revisions(num, experiment_name):
	revisions = load_pad_revisions(INPUT_DATA_PATH + num + '/dirty.db.gz', experiment_name + num)

	initial_doc_rev = get_revision(revisions, initial_doc_rev_num)
	first_changes_rev = get_revision(revisions, first_changes_rev_num)
	end_of_audio_rev = get_revision(revisions, end_of_audio_rev_num)

	print "= Group: %s" % (num)	
	print "== first version - rev: %s (%s)" % (initial_doc_rev['rev'], format_time(initial_doc_rev['datetime']))
	print "== first change version - rev: %s (%s)" % (first_changes_rev['rev'], format_time(first_changes_rev['datetime']))
	print "== end of audio version - rev: %s (%s)" % (end_of_audio_rev['rev'], format_time(end_of_audio_rev['datetime']))

	selected_revs = [ get_revision_at_time(revisions, first_changes_rev['datetime'] + timedelta(minutes=x)) for x in xrange(0,20)]

	i = 0
	for rev in selected_revs:
		print "== %i min. after - rev: %s (%s)" % (i, rev['rev'], format_time(rev['datetime']))
		write_revision_content(OUTPUT_DATA_PATH + experiment_name + num + '-%s_mn.txt' % (i), rev)
		i = i + 1


INPUT_DATA_PATH='./DATA-by-num/'
INPUT_DATA_JSON_FILE='./chat-slicing-data-notes.json'
OUTPUT_DATA_PATH='./DATA-revisions/'

# data_json = '''{
#   "004": {
#     "notes": {
#          "init-rev": 3 ,
#          "first-change-rev": 8 ,
#          "end-of-audio-rev": 488 
#      }
#    }
# }'''
# data = json.loads(data_json)

with open(INPUT_DATA_JSON_FILE, "r") as json_data_file:
    data = json.loads(json_data_file.read())

for group in data.keys():
#for group in ['019']:
  for experiment in data[group].keys():
  	if group == '014' and (experiment == "corrections" or experiment == "films"):
  		num = '015'
  	else:
  		num = group
  
  	reset_user_ids()
  
  	initial_doc_rev_num = data[group][experiment]["init-rev"]
  	first_changes_rev_num = data[group][experiment]["first-change-rev"]
  	end_of_audio_rev_num = data[group][experiment]["end-of-audio-rev"]
  
  	extract_revisions(num, experiment)





