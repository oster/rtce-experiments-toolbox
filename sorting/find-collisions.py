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
					revision['content'] = rev_partB['val']['atext']['text']

					revisions.append(revision)
			except StopIteration:
				break
		return revisions
	
pp = pprint.PrettyPrinter(indent=4)


revs = load_pad_revisions('../DATA-by-num/010/dirty.db.gz', 'films006')

standard_titles = titles(read_movies('final.txt'))

#target_titles = revs[1]['content'] #.splitlines()

for rev in revs:
	target_titles = rev['content']
	missing = []
	duplicates = []
	for title in standard_titles:
		count = target_titles.count(title)
		if count == 0:
		#if not title in target_titles:
			missing.append(title)
		elif count > 1:
			duplicates.append(title)
			
	print 'Missing movies in rev %i:' % ( rev['rev'] )
	print pp.pformat(missing)
	print 'Duplicated movies in rev %i:' % ( rev['rev'] )
	print pp.pformat(duplicates)

