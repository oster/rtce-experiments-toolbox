#! /usr/bin/python -tt

import os
import re
import json
import gzip
from datetime import datetime, timedelta 
import time
from collections import Counter

INPUT_DATA_PATH='./DATA-chat-word-counts/'

corrections_wordlist = []
notes_wordlist = []
films_wordlist = []

with open(INPUT_DATA_PATH + 'corrections-chat-wordlist.csv', 'rU') as f:
  corrections_wordlist = f.readlines()
corrections_wordlist = [ w.rstrip() for w in corrections_wordlist ]

with open(INPUT_DATA_PATH + 'films-chat-wordlist.csv', 'rU') as f:
  films_wordlist = f.readlines()
films_wordlist = [ w.rstrip() for w in films_wordlist ]

with open(INPUT_DATA_PATH + 'notes-chat-wordlist.csv', 'rU') as f:
  notes_wordlist = f.readlines()
notes_wordlist = [ w.rstrip() for w in notes_wordlist ]
 



#diff_wordlist = list(set(notes_wordlist) - set(corrections_wordlist))
diff_wordlist = list((set(corrections_wordlist) | set(notes_wordlist)) - set(films_wordlist))

# print '= length of corrections wordlist: ', len(corrections_wordlist)
# print '= length of notes wordlist: ', len(notes_wordlist)
# print '= length of differences:', len(diff_wordlist)

for w in sorted(diff_wordlist):
	print w #.encode('UTF-8')

