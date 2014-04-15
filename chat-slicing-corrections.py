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

def load_pad_revisions_and_chat(db_file, padid):
	with gzip.open(db_file, 'rb') as f:		
		revisions = []
		pattern_rev_metadata = re.compile('{"key":"pad:'+padid+':revs:([0-9]+)"')
		pattern_rev_data = re.compile('pad:'+padid)
		
		chat_entries = []
		pattern_chat_data = re.compile('{"key":"pad:'+padid+':chat:([0-9]+)"')

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
					
				match = pattern_chat_data.match(line)
				if match:
					entry_num = int(match.group(1))
					content = json.loads(line)
					entry = {}
					entry['num'] = entry_num
					entry['timestamp'] = content['val']['time']
					entry['datetime'] = datetime.fromtimestamp(int(entry['timestamp']) / 1000)
					entry['message'] = content['val']['text']
					entry['userid'] = generate_user_id(content['val']['userId'])
					
					chat_entries.append(entry)
					
			except StopIteration:
				break
		return (revisions, chat_entries)

def format_time(timestamp):
	return timestamp.strftime('%H:%M:%S')
	
def get_revision(revisions, revision_num):
	return [ rev for rev in revisions if rev['rev'] == revision_num ][0]

def get_revision_at_time(revisions, one_min_after_end_of_audio):
	return [ rev for rev in revisions if rev['datetime'] <= one_min_after_end_of_audio ][-1]
	
	
def format_chat_entry(entry):
	return "[%s] user%s:> %s" % (format_time(entry['datetime']), entry['userid'], entry['message'].encode('utf8'))

def print_chat_entries(entries):
	for e in entries:
		print format_chat_entry(e)

def split_list(f_cond, list):
	selected_items = []
	unselected_items = []
	for item in list:
		if f_cond(item):
			selected_items.append(item)
		else:
			unselected_items.append(item)
	return (selected_items, unselected_items)

def chat_word_counts(entries):
	words_by_lines = [ entry['message'].split() for entry in entries ]
	words = [word.lower() for words_in_line in words_by_lines for word in words_in_line]
	word_counts = Counter(words) 
	return word_counts

def write_chat_word_counts_as_csv(filename, entries):
	with open(filename, "w") as csv_file:
		for (word, count) in chat_word_counts(entries).items():
			csv_file.write('"%s", %i\n' % (word.encode('utf8'), count))

def slice_chat(num, experiment_name):
	(revisions, chat_entries) = load_pad_revisions_and_chat(INPUT_DATA_PATH + group + '/dirty.db.gz', experiment_name + num)
	chat_entries.sort(key=lambda entry: entry['datetime']) # just to be sure ;)

	#initial_doc_rev = get_revision(revisions, initial_doc_rev_num)
	first_changes_rev = get_revision(revisions, first_changes_rev_num)
	#end_of_audio_rev = get_revision(revisions, end_of_audio_rev_num)

	print "= Group: %s" % (num)	
	#print "== first version - rev: %s (%s)" % (initial_doc_rev['rev'], format_time(initial_doc_rev['datetime']))
	print "== first change version - rev: %s (%s)" % (first_changes_rev['rev'], format_time(first_changes_rev['datetime']))
	#print "== end of audio version - rev: %s (%s)" % (end_of_audio_rev['rev'], format_time(end_of_audio_rev['datetime']))

	x_min_after_task_begun = [ get_revision_at_time(revisions, first_changes_rev['datetime'] + timedelta(minutes=x)) for x in xrange(1,11)]

	i = 0
	for rev in x_min_after_task_begun:
		i = i + 1
		print "== %i min. after task begun version - rev: %s (%s)" % (i, rev['rev'], format_time(rev['datetime']))

	entries = chat_entries
	print '\t-- chat --'
	#(selected, entries) = split_list(lambda entry: entry['datetime'] <= initial_doc_rev['datetime'], entries)	
	#print_chat_entries(selected)
	#write_chat_word_counts_as_csv(OUTPUT_DATA_PATH + experiment_name + num + '-before-init.csv', selected)

	#print '\t-- initial version --'
	(selected, entries) = split_list(lambda entry: entry['datetime'] <= first_changes_rev['datetime'], entries)	
	print_chat_entries(selected)
	write_chat_word_counts_as_csv(OUTPUT_DATA_PATH + experiment_name + num + '-before-first-change.csv', selected)

	print '\t-- first change version --'
	#(selected, entries) = split_list(lambda entry: entry['datetime'] <= end_of_audio_rev['datetime'], entries)
	#print_chat_entries(selected)
	#write_chat_word_counts_as_csv(OUTPUT_DATA_PATH + experiment_name + num + '-before-task-begun.csv', selected)

	#print '\t-- end of audio --'	
	i = 0
	for rev in x_min_after_task_begun:
		i = i + 1
		(selected, entries) = split_list(lambda entry: entry['datetime'] <= rev['datetime'], entries)
		print_chat_entries(selected)
		write_chat_word_counts_as_csv(OUTPUT_DATA_PATH + experiment_name + num + '-before-%imin-after-task-begun.csv' % i, selected)		
		print '\t-- %i min after task begun --' % (i)

	print_chat_entries(entries)
	write_chat_word_counts_as_csv(OUTPUT_DATA_PATH + experiment_name + num + '-after-10min-after-task-begun.csv', entries)		
	
	print '\t-- end of record --\n\n'


INPUT_DATA_PATH='./DATA-by-num/'
INPUT_DATA_JSON_FILE='./chat-slicing-data-corrections.json'
OUTPUT_DATA_PATH='./DATA-chat-word-counts/'

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

with open (INPUT_DATA_JSON_FILE, "r") as json_data_file:
    data = json.loads(json_data_file.read())

for group in data.keys():
#for group in ['014']:
  for experiment in data[group].keys():
  	if group == '014' and (experiment == "films"):
  		num = '015'
  	else:
  		num = group
  
  	reset_user_ids()
  
  	#initial_doc_rev_num = data[group][experiment]["init-rev"]
  	first_changes_rev_num = data[group][experiment]["first-change-rev"]
  	#end_of_audio_rev_num = data[group][experiment]["end-of-audio-rev"]
  
  	slice_chat(num, experiment)






