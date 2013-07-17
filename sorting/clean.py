#! /usr/bin/python -tt

import os
import re

#DATA_PATH='./DATA/'
#DATA_PATH='./DATA-9mn/'
#files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-9mn\.txt', f)]
#files = ["films019.txt"]

DATA_PATH="/tmp/"
files = ["films005-6mn.txt"]

for target_file in sorted(files):
	#target_file = DATA_PATH + 'films006-9mn.txt'
	print '## cleaning', target_file 
	
	f = open(DATA_PATH + target_file, 'rU')
	lines = f.readlines()
	f.close()
	
	# removes trailing spaces and carriage returns
	lines = map(lambda line: line.rstrip('\r\n\t '), lines)
	
	# do some additionnal cleaning
	lines[0] = lines[0].lstrip('\xef\xbb\xbf')
	
	# capture and remove date
	#for line in lines:
	for i in range(len(lines)):		
		line = lines[i]
#		print '###', line
#		m = re.match("[1-2][0-9]{3}", line)
		m = re.match(".*([1-2][0-9]{3})", line)
		if m:
			year = m.group(1)
#			print year
			#match = re.match("(.*)[1-2][0-9]{3}(.*)", line)
			line = re.sub("[1-2][0-9]+", '', line)				
		# remove spaces at the beginning/end of lines
		line = line.lstrip('\r\n\t ')
		line = line.rstrip('\r\n\t ')
		if m:
			lines[i] = year + " " + line
			
		# remove actors
		lines[i] = re.sub("- +\(.*$", '', lines[i])	
		lines[i] = lines[i].replace(" - ", " ")
		lines[i] = lines[i].replace(" -", " ")
	
		lines[i] = lines[i].replace("(", "")
		lines[i] = re.sub("\) ?", " ", lines[i])
		lines[i] = lines[i].replace(" :", " ")
		
		
		# to fix, movie with year sticked to title
		m = re.match("^([0-9]+) *(.+)", lines[i])
		if m:
			lines[i] = m.group(1) + ' ' + m.group(2)		
	
	lines = filter(lambda x: not re.match(r'^\s*$', x), lines)
	
	output_file = target_file.replace('.txt', '-wo-actors.txt')
	
	f = open(DATA_PATH + output_file, 'w')
	for line in lines:
#		print line
		f.write(line+"\n")
	f.close()






