#! /usr/bin/python -tt

import os
import re
import pprint
import json
import gzip
import datetime

from ranking import *

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
					revision['author'] = rev_partA['val']['meta']['author']
					revision['content'] = rev_partB['val']['atext']['text']

					revisions.append(revision)
			except StopIteration:
				break
		return revisions

last_uid = -1
user_ids = {}

def userId(str_uid):
	global last_uid
	global user_ids
	
	if str_uid in user_ids:
		return user_ids[str_uid]
	else:
		last_uid = last_uid + 1
		user_ids[str_uid] = last_uid
		return last_uid

def find_collisions(revs, standard_titles):
	collisions = {}
	
	for rev in revs:
		target_titles = rev['content']
		for title in standard_titles:
			count = target_titles.count(title)
	
			if not title in collisions:
				collisions[title] = {}
				collisions[title]['count'] = 0
				collisions[title]['history'] = []
	
			if count != collisions[title]['count']:				
				op = {}
				op['rev'] = rev['rev']
				timestamp = datetime.datetime.fromtimestamp(int(rev['timestamp']) / 1000)
				op['timestamp'] = timestamp.strftime('%Y-%m-%d %H:%M:%S') #datetime.datetime(2005, 7, 14, 12, 30)
				op['time-in-second'] = timestamp.hour * 3600 + timestamp.minute * 60 + timestamp.second
				op['user'] = userId(rev['author'])
				op['type'] = count - collisions[title]['count']				
				collisions[title]['history'].append(op)
				collisions[title]['count'] = count
	  
	# backup-ing history
	for title in collisions:
		collisions[title]['life'] = collisions[title]['history'][:]
	
	# removing initial insertion
	for title in collisions:
		for op in collisions[title]['history'][:]:
			if op['rev'] == 1 and op['type'] == 1:
				collisions[title]['history'].remove(op) # beware! dangerous!
				
	# removing cut-and-paste
	for title in collisions:
		prev_op = None
		for op in collisions[title]['history'][:]:
			if not prev_op is None:
				if prev_op['type'] == -1 and op['type'] == +1 and prev_op['user'] == op['user']:
					collisions[title]['history'].remove(prev_op)
					collisions[title]['history'].remove(op)				
					prev_op = None
				else:
					prev_op = op
			else:
				prev_op = op
	
	# removing copy-paste-cut
	for title in collisions:
		prev_op = None
		for op in collisions[title]['history'][:]:
			if not prev_op is None:
				if prev_op['type'] == 1 and op['type'] == -1 and prev_op['user'] == op['user']:
					collisions[title]['history'].remove(prev_op)
					collisions[title]['history'].remove(op)
					prev_op = None
				else:
					prev_op = op
			else:
				prev_op = op
	
	# cleaning - removing title with empty collision history
	cleaned_collisions = {}
	for title in collisions:
		if len(collisions[title]['history']) > 0:
			cleaned_collisions[title] = collisions[title]
	collisions = cleaned_collisions
	del cleaned_collisions
	
	return collisions



pp = pprint.PrettyPrinter(indent=4)

INPUT_DATA_PATH='../DATA-by-num/'
OUTPUT_DATA_PATH='./DATA-collisions/'
standard_titles = titles(read_movies('final.txt'))

for group in ('001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '012', '013', '014', '016', '017', '018', '019', '020', '021', '025'):
	if group == '014':
		num = '015'
	else:
		num = group
	
	revisions = load_pad_revisions(INPUT_DATA_PATH + group + '/dirty.db.gz', 'films' + num)
	collisions = find_collisions(revisions, standard_titles)

	f = open(OUTPUT_DATA_PATH + 'films' + num + '-collisions.txt', 'w')
	f.write(pp.pformat(collisions))
	f.close()









