import re

def read_movies(filename):
	f = open(filename, 'rU')
	lines = f.readlines()
	f.close()
	
	# removes trailing spaces and carriage returns
	lines = map(lambda line: line.rstrip('\r\n\t '), lines)
	
	# do some additionnal cleaning
	lines[0] = lines[0].lstrip('\xef\xbb\xbf')
	
	# split each line into an associative array {'year':, 'title': }
	nlines = []
	for line in lines:		
		if re.match("^[1-2][0-9]{3} ", line):
			(year, title) = line.split(' ', 1) # split the line at the first space		
			line = { 'year': int(year),
			         'title': title
			       }
		else:
			line = { 'year': -1, 
			         'title': line 
			       }
		nlines.append(line)
	return nlines

def rank_movies(movies):
	start = 0
	while start < len(movies):
		count = 1
		year = movies[start]['year']
		end = start
		# looking for consecutive movies from the same date
		while start+count < len(movies) and year == movies[start+count]['year']:
			end = start + count
			count = count + 1
			
		# computing ranking
		rank = start + 1 + (count - 1) / 2.
		
		# set ranking to all movie of the 'group'
		for i in range(start, end+1):
			movies[i]['rank'] = rank
	
		start = start + count
	
def titles(movies):
	return map(lambda movie: movie['title'], movies)

def years(movies):
	return map(lambda movie: movie['year'], movies)



def get_duplicated_and_missing_movie_titles(standards, targets):
	target_titles = titles(targets)
	duplicated_titles = [ movie['title'] for movie in targets if target_titles.count(movie['title']) > 1 ]
	duplicated_titles = { e: (duplicated_titles.count(e) - 1) for e in set(duplicated_titles) }

	missing_titles = [ movie['title'] for movie in standards if movie['title'] not in target_titles ]
	return (duplicated_titles, missing_titles)


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
	

def get_movies_with_title(movies, title):
	return [ movie for movie in movies if movie['title'] == title ]


def get_wrong_titles(standards, targets):
	return [ movie['title'] for movie in targets if len(get_movies_with_title(standards, movie['title'])) == 0 ]		

def get_wrong_year_movie_titles(standards, targets):
	titles = [ movie['title'] for movie in targets if movie['year'] != get_movies_with_title(standards, movie['title'])[0]['year'] ]		
	return titles

def remove_movie_with_titles(movies, titles_to_remove):
	remaining_movies = [ movie for movie in movies if not movie['title'] in titles_to_remove ]	
	return remaining_movies

def compute_correlation_with_ranking(standards, targets):
	sum = 0
	for movie in standards:
		ranks = [ m['rank'] for m in targets if m['title'] == movie['title'] ]
		if len(ranks) == 1:
			sum = sum + (movie['rank'] - ranks[0]) ** 2

	N = len(standards)
	
	correlation = 1 - ((6 * sum) / (N * (N ** 2 - 1)))
	return correlation


if __name__ == "__main__":
	print 'This module provides utility functions do deal with ranking of movies list.'






