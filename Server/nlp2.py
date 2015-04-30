#!/usr/bin/env python2.7
import sys
import os
import csv
import pickle
import urllib2
from random import randint
#import requests
import json
import string
import globals as g

city_state_csv_filename = "city_state.csv"
city_state_pickle_filename = "city_state_picklefile"
echo_api_key = "NBXSOUGUPQXDHPCGX"
echo_api_request = "http://developer.echonest.com/api/v4/artist/search?api_key=%s&name=%s"


# ITERATION 2:
# TODO: remove stopwords adjacent to artist keywords
# TODO: remove punctuation from truncated user input string (without artist keyword)
# TODO: get custom responses working


# friendly messages to randomly include
# along with the link to tickets / preview / show suggestion
customresponses = {	"Tickets": ["Super! You can get tickets here: ",
								"Good choice. Here you go: ",
								"Get ready for some tasty jams: ",
								"Right on. You are going to have a time! ",
								"Awesome! Have fun, but not too much fun: "],
					"Preview": ["Check this out: ",
								"Take a listen: ",
								"For your listening enjoyment, my liege: ",
								"Get a load of these tasty jams: ",
								"Maybe this will win your ear over: "],
					"Show":	   ["Here's one I think you might like: ",
								"What about this show? ",
								"Called my friends and this is the hottest hit in town: ",
								"All the cool kids are going here: ",
								"Give this one a gander: " ]}

# Possible artist query inputs:
# 	"hey morgan, when's the next radiohead show?"
# 	"radiohead concert"
# 	"is there a radiohead show near me?"
# 	"hey, show me radiohead concerts"
# 	"do you know when radiohead is playing?"
#	"is radiohead playing?"
# 	"radiohead"
# 	"does radiohead have any upcoming shows?"
artist_keywords = ["show", "shows", "concert", "concerts", "playing"]

# Possible geolocation query inputs:
#	"what's going on near me"
#	"who can i go see tonight"
#   "is there a concert nearby tonight"
geolocation_phrases = ["nearby", "near me", "tonight"]


def parse_text(text, return_responses):

    my_dir = os.path.dirname(__file__)
    pickle_file_path = os.path.join(my_dir, city_state_pickle_filename)

	# if the city_state_data list has not been loaded, do so
	#if not os.path.exists(city_state_pickle_filename):
		# create the pickled data structure file if it hasn't been done
	#	loadCsvData()
    picklefile = open(pickle_file_path, 'rb')
    city_state_data = pickle.load(picklefile)
    picklefile.close()
	# for use in removing punctuation from strings
    punct_set = set(string.punctuation)
    # tokenize the string into words
    text = text.lower()
    text = text.split()
	# look for location using keyword "in"
    if 'in' in text:
    	i = text.index('in')
        # get the rest of the sentence after keyword into a single string
        location = text[i + 1: len(text)]
        location = ' '.join(location)
		# get the city name from the string (ignore state data)
        if ',' in location:
        	city = location[0 : location.index(',')]
        	city = city.strip()
        else:
        	city = location.strip()
        # strip punctuation from city
        city = ''.join(c for c in city if c not in punct_set)
        # search for city name in csv data
        city_exists = False
        for one_city in city_state_data:
        	# compare our city's name to this city
        	if city == one_city[0].strip():
        		city_exists = True
        		break

		if city_exists:
			# save this location in the data sent to server
			return_responses[g.CODE] = 2 # user's query = find shows by location
			return_responses[g.LOCATION] = city

		else:
			# ask the user for a well-formatted query
			print "parse_text: no location found in query containing keyword \'in\'"
			return_responses[g.CODE] = 0 # user's query = not understood
			return_responses[g.MESSAGE][g.M_OTHER] = \
				"I'm sorry! Couldn't understand that. Is %s a city in the US?" % city


    # TODO: look for venue using keyword "at"
    elif 'at' in text:
        pass

	# check the entire text for location, artist, or geolocation
    else:
        text = ' '.join(text).strip()
        text = ''.join(c for c in text if c not in punct_set) # remove punct
        # try to parse a city name
        city_exists = False
        city = None
        # search for city name in csv data
        for one_city in city_state_data:
        	# compare our city's name to this city
            if text == one_city[0].strip():
				city_exists = True
				city = text
				break

		# try to parse an artist name
        artist_exists = False
        artist = None
		# search for artist keyword, and only search string before keyword for artist
		search_text = text.split()
		for word in search_text:
			if word in artist_keywords:
				search_text = search_text[0: search_text.index(word)]

		# search prioritized permutations of truncated text
		n = len(search_text)
		for i in range(2):
			for j in range(0, n-i):
				# get permutation string to search api for
				current_text = ' '.join(search_text[j:n-i])
				current_text = current_text.strip().replace(" ", "_")
				# search api and set artist if exists
				artist_exists = searchForArtist(current_text)
				if artist_exists:
					artist_exists = True
					artist = current_text
					break
			if artist_exists:
				break


		# (1) check for location
		if city_exists:
			return_responses[g.CODE] = 2 # user's query = find shows by location
			return_responses[g.LOCATION] = city_text

		# (2) check for artist
		elif artist_exists:
			return_responses[g.CODE] = 3 # user's query = find shows by artist
			return_responses[g.ARTIST] = artist


		# (3) check for geolocation
		elif any(word in text for word in geolocation_phrases):
			return_responses[g.CODE] = 1 # user's query = shows near me query


		# (4) if nothing found, prompt user for new query
		else:
			return_responses[g.CODE] = 0 # user's query = not understood
			return_responses[g.MESSAGE][g.M_OTHER] = \
				"I'm sorry! I don't understand what you're asking. Hit me with something else!"


def getKeywords(text):

	return_responses = {
		g.CODE: None,
		g.LOCATION: None,
		g.ARTIST: None,
		g.VENUE: None,
		g.DATE: None,
		g.MESSAGE: {
			g.M_TICKET: None,
			g.M_PREVIEW: None,
			g.M_SHOW: None,
			g.M_OTHER: None}}

	parse_text(text, return_responses)

	return_responses[g.MESSAGE][g.M_TICKET] = \
		customresponses["Tickets"][randint(0, len(customresponses["Tickets"])-1)]
	return_responses[g.MESSAGE][g.M_PREVIEW] = \
		customresponses["Preview"][randint(0, len(customresponses["Preview"])-1)]
	return_responses[g.MESSAGE][g.M_SHOW] = \
		customresponses["Show"][randint(0, len(customresponses["Show"])-1)]
	#for p in return_responses:	print p, ",", return_responses[p]
	return return_responses



def loadCsvData():
	# open the city state csv file
	f = open(city_state_csv_filename, 'rt')
	try:
		# each row of the reader is a list
		# [city, state, latitude, longitude]
		reader = csv.reader(f)
	except:
		print("Error opening " + city_state_csv_filename)
		exit(0)

	# build a list of the city, state, lat, lon lists
	city_state_data = []
	for row in reader:
		city_state_data.append([x.lower() for x in row])
	f.close()

	# save city_state_data in list format for quick reading
	picklefile = open(city_state_pickle_filename, 'wb')
	pickle.dump(city_state_data, picklefile)
	picklefile.close()


def searchForArtist(potential_artist):

	print('searchForArtist called with text \'%s\'' % potential_artist)
	url = echo_api_request%(echo_api_key, potential_artist)
	try:
		data = urllib2.urlopen(url)
	except urllib2.HTTPError:
		print('searchForArtist: bad request to echonest api with \'%s\'' % potential_artist)
		sys.stderr.write('BAD REQUEST\n')
		return False
	try:
		response = json.loads(data.read())
	except ValueError:
		print('searchForArtist: error reading json from api response')
		sys.stderr.write('JSON ERROR\n')
		return False

	if len(response['response']['artists']) > 0:
		return True
	else:
		return False




