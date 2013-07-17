#! /usr/bin/python -tt

from ranking import *
import pprint

pp = pprint.PrettyPrinter(indent=4)


#standard_movies = read_movies('./TEST_FILES/final.txt')
#target_movies = read_movies('./TEST_FILES/20120626-EXP2-final.txt')
standard_movies = read_movies('final.txt')
#target_movies = read_movies('./DATA/films013-wo-actors.txt')
target_movies = read_movies('rev.txt');


(duplicated_titles, missing_titles) = get_duplicated_and_missing_movie_titles(standard_movies, target_movies)
print '- %s duplicated element(s):\n   %s' % (len(duplicated_titles.values()), pp.pformat(duplicated_titles))
print '- %s missing element(s):\n   %s' % (len(missing_titles), pp.pformat(missing_titles))
del duplicated_titles
del missing_titles
(standard_movies, target_movies) = remove_duplicated_and_missing_movie(standard_movies, target_movies)

wrong_year_movie_titles = get_wrong_year_movie_titles(standard_movies, target_movies)	
print '- %s wrong year element(s):\n   %s' % (len(wrong_year_movie_titles), pp.pformat(wrong_year_movie_titles))
standard_movies = remove_movie_with_titles(standard_movies, wrong_year_movie_titles)
target_movies = remove_movie_with_titles(target_movies, wrong_year_movie_titles)
del wrong_year_movie_titles

if len(standard_movies) != len(target_movies):
	msg = 'The two list to be compared must have the same size! (standard: %s, target: %s)' % ( len(standard_movies), len(target_movies) )
	print list(set(titles(target_movies)) - set(titles(standard_movies)))
	raise Exception(msg)

rank_movies(standard_movies)
rank_movies(target_movies)

print '- correlation: %.6f - computed on %s element(s)' % (compute_correlation_with_ranking(standard_movies, target_movies) * len(standard_movies), len(standard_movies))
print











