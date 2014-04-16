#! /usr/bin/python -tt

# sorting2.py -- same as sorting.py except that we are not only computing 
# swap count but also how many elements have to move

from ranking import *
import os
import re
import pprint
import math


DATA_PATH='./DATA-10mn/'
#DATA_PATH='./DATA/'
#files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-wo-actors\.txt', f)]
files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-10mn-wo-actors\.txt', f)]

#DATA_PATH='./DATA-7mn/'
#files = [ 'films013-7mn-wo-actors.txt' ]

#DATA_PATH='./'
#files = [ 'final-reversed-unique.txt' ]
#files = [ 'final-reversed.txt' ]

pp = pprint.PrettyPrinter(indent=4)


def sum_1_n(n):
	return (n * (n - 1)) / 2

for target_file in sorted(files):
	print '##', target_file 
	
	standard_movies = read_movies('final.txt')
	target_movies = read_movies(DATA_PATH + target_file)


	(duplicated_titles, missing_titles) = get_duplicated_and_missing_movie_titles(standard_movies, target_movies)
	print '- %s duplicated element(s):\n   %s' % (len(duplicated_titles.values()), pp.pformat(duplicated_titles))
	print '- %s missing element(s):\n   %s' % (len(missing_titles), pp.pformat(missing_titles))
	del duplicated_titles
	del missing_titles
	(standard_movies, target_movies) = remove_duplicated_and_missing_movie(standard_movies, target_movies)

	wrong_titles = get_wrong_titles(standard_movies, target_movies)
	print '- %s wrong title element(s):\n   %s' % (len(wrong_titles), pp.pformat(wrong_titles))
	del wrong_titles
	
	wrong_year_movie_titles = get_wrong_year_movie_titles(standard_movies, target_movies)	
	print '- %s wrong year element(s):\n   %s' % (len(wrong_year_movie_titles), pp.pformat(wrong_year_movie_titles))
	standard_movies = remove_movie_with_titles(standard_movies, wrong_year_movie_titles)
	target_movies = remove_movie_with_titles(target_movies, wrong_year_movie_titles)
	del wrong_year_movie_titles

	if len(standard_movies) != len(target_movies):
		msg = 'The two list to be compared must have the same size! (standard: %s, target: %s)' % ( len(standard_movies), len(target_movies) )
		print list(set(titles(target_movies)) - set(titles(standard_movies)))
		raise Exception(msg)
	
	clusters_by_year = {}
	for movie in target_movies:
		v = 0
		if movie['year'] in clusters_by_year:
			v = clusters_by_year[movie['year']]		
		clusters_by_year[movie['year']] = v + 1
		
	sum_movies_with_duplicated_year = sum(map(sum_1_n, clusters_by_year.values()))
	del clusters_by_year
		
	swap = 0
	jump = 0	
	jumped = False
	for i in range(1,len(target_movies)):
		j = i
		x = j
		while j > 0 and target_movies[j]['year'] < target_movies[j-1]['year']:
			jumped = True
			swap = swap + 1
			target_movies[j-1], target_movies[j] = target_movies[j], target_movies[j-1]
			j = j - 1
		if jumped:
			jumped = False
			jump = jump + 1
			
	worst_case_swap = sum_1_n(len(target_movies)) - sum_movies_with_duplicated_year	
	coef =  (1 - float(swap) / worst_case_swap) * len(target_movies)

	worst_case_jump = len(target_movies) - 1
	coef2 =  (1 - float(jump) / worst_case_jump) * len(target_movies)

	print '- correlation: %.6f - computed on %s element(s) - swap count = %s / %s' % (coef, len(target_movies), swap, worst_case_swap)
	print '- correlation: %.6f - computed on %s element(s) - jump count = %s / %s' % (coef2, len(target_movies), jump, worst_case_jump)
	print
	