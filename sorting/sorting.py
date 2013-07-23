#! /usr/bin/python -tt

from ranking import *
import os
import re
import pprint
import math


#DATA_PATH='./DATA-9mn/'
#files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-9mn-wo-actors\.txt', f)]

#DATA_PATH='./DATA-7mn/'
#files = [ 'films013-7mn-wo-actors.txt' ]

DATA_PATH='./'
#files = [ 'final-reversed-unique.txt' ]
files = [ 'final-reversed.txt' ]
#files = [ '3.txt']

pp = pprint.PrettyPrinter(indent=4)

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

	wrong_year_movie_titles = get_wrong_year_movie_titles(standard_movies, target_movies)	
	print '- %s wrong year element(s):\n   %s' % (len(wrong_year_movie_titles), pp.pformat(wrong_year_movie_titles))
	standard_movies = remove_movie_with_titles(standard_movies, wrong_year_movie_titles)
	target_movies = remove_movie_with_titles(target_movies, wrong_year_movie_titles)
	del wrong_year_movie_titles

	if len(standard_movies) != len(target_movies):
		msg = 'The two list to be compared must have the same size! (standard: %s, target: %s)' % ( len(standard_movies), len(target_movies) )
		print list(set(titles(target_movies)) - set(titles(standard_movies)))
		raise Exception(msg)
	
	swap = 0	
	for i in range(1,len(target_movies)):
		j = i
		x = j
		while j > 0 and target_movies[j]['year'] < target_movies[j-1]['year']:
			swap = swap + 1
			target_movies[j-1], target_movies[j] = target_movies[j], target_movies[j-1]
			j = j - 1
		#if x != j:
		#	swap = swap + 1 

	N = len(target_movies)
	sum = (N * (N - 1)) / 2
	
	coef =  1 - float(swap) / sum 

	print '- correlation: %.6f - computed on %s element(s) - swap count = %s / %s' % (coef, len(target_movies), swap, sum)
	print
	