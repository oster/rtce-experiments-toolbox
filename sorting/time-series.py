#! /usr/bin/python -tt

from ranking import *
import os
import re
import pprint
import math

#DATA_PATH='./DATA/'
#files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-wo-actors\.txt', f)]

DATA_PATH='./DATA-6mn/'
files = [f for f in os.listdir(DATA_PATH) if re.match(r'films[0-9]{3}-6mn-wo-actors\.txt', f)]

#DATA_PATH='./'
#files = [ 'final-missing-year.txt' ]

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

	# remove movies without year
	movies_without_year = [ movie for movie in target_movies if movie['year'] == -1]
	target_movies = [ movie for movie in target_movies if movie not in movies_without_year ]


	x = years(target_movies)	
	y = x[1:]
	x = x[:-1]
	
	xavg = sum(x) / len(x)
	yavg = sum(y) / len(y)
		
	sum1 = 0.
	suma = 0.
	sumb = 0.
	for i in range(len(x)):
		a = x[i] - xavg
		b = y[i] - yavg		
		sum1 = sum1 + a*b
		suma = suma + a**2
		sumb = sumb + b**2
	
	coef =  sum1 / math.sqrt(suma * sumb)
	
	print '- correlation: %.6f - computed on %s element(s) - coeff. = %.6f' % (coef*len(target_movies), len(target_movies), coef)
	print
