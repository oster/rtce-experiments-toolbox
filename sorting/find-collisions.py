#! /usr/bin/python -tt

import re
import pprint
import json
import gzip

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
	
pp = pprint.PrettyPrinter(indent=4)


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


revs = load_pad_revisions('../DATA-by-num/010/dirty.db.gz', 'films006')

standard_titles = titles(read_movies('final.txt'))

#target_titles = revs[1]['content'] #.splitlines()

collisions = {}

for rev in revs:
	target_titles = rev['content']
	missing = []
	duplicates = []
	for title in standard_titles:
		count = target_titles.count(title)

		if not title in collisions:
			collisions[title] = {}
			collisions[title]['count'] = 0
			collisions[title]['history'] = []

		if count != collisions[title]['count']:
			
			op = {}
			op['rev'] = rev['rev']
			op['timestamp'] = rev['timestamp']
			op['user'] = userId(rev['author'])
			op['type'] = count - collisions[title]['count']
			
			#collisions[title]['history'].append( (rev['rev'], rev['timestamp'], rev['author'], count - collisions[title]['count']) )
			collisions[title]['history'].append(op)
			collisions[title]['count'] = count
  
# backup-ing history
for title in collisions:
	collisions[title]['life'] = collisions[title]['history'][:]

# removing initial insertion
for title in collisions:
	for op in collisions[title]['history']:
		if op['rev'] == 1 and op['type'] == 1:
			collisions[title]['history'].remove(op) # beware! dangerous!
			
# removing cut-and-paste
for title in collisions:
	toberemoved = []
	prev_op = None
	for op in collisions[title]['history']:
		if not prev_op is None:
			if prev_op['type'] == -1 and op['type'] == +1 and prev_op['user'] == op['user']:
				#collisions[title]['history'].remove(prev_op)
				#collisions[title]['history'].remove(op)				
				toberemoved.append(prev_op)
				toberemoved.append(op)
				prev_op = None
			else:
				prev_op = op
		else:
			prev_op = op
	for dop in toberemoved: 
		collisions[title]['history'].remove(dop)

# removing copy-paste-cut
for title in collisions:
	toberemoved = []	
	prev_op = None
	for op in collisions[title]['history']:
		if not prev_op is None:
			if prev_op['type'] == 1 and op['type'] == -1 and prev_op['user'] == op['user']:
				#collisions[title]['history'].remove(prev_op)
				#collisions[title]['history'].remove(op)
				toberemoved.append(prev_op)
				toberemoved.append(op)
				prev_op = None
			else:
				prev_op = op
		else:
			prev_op = op
	for dop in toberemoved: 
		collisions[title]['history'].remove(dop)	

# cleaning - removing title with empty collision history
cleaned_collisions = {}
for title in collisions:
	if len(collisions[title]['history']) > 0:
		cleaned_collisions[title] = collisions[title]
collisions = cleaned_collisions
del cleaned_collisions

# 
# 
# #		if count == 0:
# #		#if not title in target_titles:
# #			missing.append(title)
# #		elif count > 1:
# #			duplicates.append(title)
# #			
# #			
# #	print 'Missing movies in rev %i:' % ( rev['rev'] )
# #	print pp.pformat(missing)
# #	print 'Duplicated movies in rev %i:' % ( rev['rev'] )
# #	print pp.pformat(duplicates)

print pp.pformat(collisions)


