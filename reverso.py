#! /opt/local/bin/python2.7 -tt
# -*- coding: utf-8 -*-

import os
import re
import requests
import sys
import csv

#
# Exemple of reponse from reverso.net checker service
# =====
# <?xml version="1.0"?>
# <CheckSpellingResult>
# 	<document xmlns="">
# 		<sentences nb="2">
# 			<sentence id="0" start="0" length="28" language="Fr">
# 				<inputText>test de fotes d'orthographe.</inputText>
# 				<errors nb="1">
# 					<error id="0" type="spell" substitution="fautes" start="8" end="13" proba="100">
# 						<message>#!fotes#$ : mot inconnu de nos dictionnaires automatiquement remplac&#xE9; par #!fautes#$.</message>
# 						<alternatives nb="2">
# 							<alternative id="0">fotes</alternative>
# 							<alternative id="1">fautes</alternative>
# 						</alternatives>
# 					</error>
# 				</errors>
# 			</sentence>
# 			<sentence id="1" start="29" length="25" language="Fr">
# 				<inputText>Mais ou est le problemes?</inputText>
# 				<errors nb="2">
# 					<error id="0" type="grammar" substitution="o&#xF9;" start="34" end="36" proba="87">
# 						<message>Dans ce contexte, le mot #!ou#$ pourrait &#xEA;tre confondu avec son homophone #!o&#xF9;#$.</message>
# 					</error>
# 					<error id="1" type="grammar" substitution="le probl&#xE8;me" start="41" end="53" proba="95">
# 						<message>Le groupe nominal #!le problemes#$ est masculin singulier.</message>
# 					</error>
# 				</errors>
# 			</sentence>
# 		</sentences>
# 	</document>
# 	<newPassPhrase>CtBdPWUXrpqrvi+FlDrf1dwZCVjgmAG9SJ2Liz7AY5k=</newPassPhrase>
# 	<textreplaced>test de fotes d'orthographe.
# Mais ou est le problemes?</textreplaced>
# 	<noreplace>0</noreplace>
# </CheckSpellingResult>
# ====


def get_reverso_metric(text):
	payload = { 'passPhrase': 'CtBdPWUXrpqrvi+FlDrf1bLaSheTs2cAwDMRM/Yk7QA=',
	            #'inputstring': 'test de fotes d\'orthographe.\nMais ou est le problemes?', 
	            'inputstring': text,
	            'language': 'fr',
	            'interfLang': 'fr',
	            'dictionary': 'both',
	            'lang': 'fr'
	          }
	r = requests.post("http://www.reverso.net/orthographe/correcteur-francais/SpellerRequests.aspx", data=payload)
	pattern = re.compile('<errors nb="([0-9]+)">')
	data = pattern.findall(r.text)
	errors_count = sum(int(i) for i in data)
	return errors_count

def load_text_file(filename):
	with open(filename, "r") as text_file:
	    text = text_file.read()
	return text


SPLIT_MARKERS = [ '1. Cloud computing - concept innovateur \(Utilisateur 1 \+ Utilisateur 2\)',
                  '2. Différents types de clouds et de clients \(Utilisateur 3 \+ Utilisateur 4\)',
                  '3. Les avantages de cloud \(Utilisateur 1 \+ Utilisateur 2\)',
                  '4. Les inconvénients de cloud \(Utilisateur 3 \+ Utilisateur 4\)',
                  '5. Sujets de recherche en cloud computing \(Utilisateur 1 \+ Utilisateur 2\)' ]

def split_in_chunks(text):
	res = []
	text_to_split = text
	for marker in SPLIT_MARKERS:
		[a, m, b] = re.split('(' + marker + ')', text_to_split, maxsplit=1)
		res.append(a)
		res.append(m)
		text_to_split = b
	res.append(text_to_split)
	return res

def get_reverso_metric_with_chunking(text):
	# split text in section
	text_chunks = split_in_chunks(text)
	
	# removing markers
	text_chunks = list(set(text_chunks) - set([ m.replace('\\','') for m in SPLIT_MARKERS ]))
	
	# computing metrics for grammar and spell checking mistakes
	metrics = [ int(get_reverso_metric(chunk)) for chunk in text_chunks ]
	metrics.append(sum(metrics))

	return metrics


text = load_text_file(sys.argv[1])
metrics = get_reverso_metric_with_chunking(text)
#metrics = [0, 4, 7, 1, 3, 0, 15]
print '; #error in prelude, #error in section-1, #error in section-2, #error in section-3, #error in section-4, #error in section-5, total #errors'
print ', '.join(str(m) for m in metrics)



