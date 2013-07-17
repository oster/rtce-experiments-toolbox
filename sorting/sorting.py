#! /usr/bin/python -tt

from ranking import *
import os
import re
import pprint
import math


#DATA_PATH='./DATA-9mn/'
#files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-9mn-wo-actors\.txt', f)]

DATA_PATH='./'
files = [ 'final.txt' ]

pp = pprint.PrettyPrinter(indent=4)

for target_file in sorted(files):
	print '##', target_file 
	
	standard_movies = read_movies('final.txt')
	target_movies = read_movies(DATA_PATH + target_file)
	
	(duplicated_titles, missing_titles) = get_duplicated_and_missing_movie_titles(standard_movies, target_movies)
	print '- %s duplicated element(s):\n   %s' % (len(duplicated_titles.values()), pp.pformat(duplicated_titles))
	print '- %s missing element(s):\n   %s' % (len(missing_titles), pp.pformat(missing_titles))
#	del duplicated_titles
#	del missing_titles
#
#	(standard_movies, target_movies) = remove_duplicated_and_missing_movie(standard_movies, target_movies)
#
#	if len(standard_movies) != len(target_movies):
#		msg = 'The two list to be compared must have the same size! (standard: %s, target: %s)' % ( len(standard_movies), len(target_movies) )
#		print list(set(titles(target_movies)) - set(titles(standard_movies)))
#		raise Exception(msg)

	t = [ movie for movie in targets if not movie['title'] in duplicated_titles ]

def remove_duplicated_and_missing_movie(standards, targets):
	target_titles = titles(targets)
	duplicated_titles = [ movie['title'] for movie in targets if target_titles.count(movie['title']) > 1 ]
	duplicated_titles = list(set(duplicated_titles))
	
	# remove duplicated movies
	s = [ movie for movie in standards if not movie['title'] in duplicated_titles ]
	t = [ movie for movie in targets if not movie['title'] in duplicated_titles ]
	
	missing_titles = [ movie['title'] for movie in standards if movie['title'] not in target_titles ]

	# remove missing movies
	s = [ movie for movie in s if not movie['title'] in missing_titles ]	

	return (s, t)
 


#	x = years(target_movies)
#	y = x[1:]
#	x = x[:-1]
#	
#	xavg = sum(x) / len(x)
#	yavg = sum(y) / len(y)
#		
#	sum1 = 0.
#	suma = 0.
#	sumb = 0.
#	for i in range(len(x)):
#		a = x[i] - xavg
#		b = y[i] - yavg		
#		sum1 = sum1 + a*b
#		suma = suma + a**2
#		sumb = sumb + b**2
#	
#	coef =  sum1 / math.sqrt(suma * sumb)
#	
#	print '- correlation: %.6f - computed on %s element(s)' % (coef, len(target_movies))
#	print
