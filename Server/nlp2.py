import sys
import nltk
import globals as g
import csv
from random import randint
import requests
import json
import string

city_state_filename = "city_state.csv"
state_abbrev_filename = "state_abbreviation.csv"
city_state_data = []
state_abbrev_data = []
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
		location = " ".join(location)

		# get the city name from the string (ignore state data)
		if "," in location:
			city = location[0 : location.index(',')]
			city = city.strip()
		else:
			city = location.strip()

		# strip punctuation from city
		#city = "".join(ch for ch in city if ch not in punct_set)

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
			return_responses[g.CODE] = 0 # user's query = not understood
			return_responses[g.MESSAGE][g.M_OTHER] = \
				"I'm sorry! Couldn't understand that. Is %s a city in the US?" % city


	# TODO: look for venue using keyword "at"
	elif 'at' in text:
		pass


	# check the entire text for location, artist, or geolocation
	else:
		# try to parse a city name
		city_exists = False
		city_text = " ".join(text).strip()
		#city_text = "".join(ch for ch in city_text if ch not in punct_set) # remove punct
		# search for city name in csv data
		for one_city in city_state_data:
			# compare our city's name to this city
			if city_text == one_city[0].strip():
				city_exists = True
				break

		# try to parse an artist name
		truncated_text = None
		artist_exists = False
		artist = None
		# search for artist keyword
		for word in text:
			if word in artist_keywords:
				# get all of the string before the artist keyword
				truncated_text = text[0: text.index(word)]

		if truncated_text:
			# search prioritized permutations of truncated text
			n = len(truncated_text)
			for i in range(2):
				for j in range(0, n-i):
					# get permutation string to search api for
					current_text = " ".join(truncated_text[j:n-i])
					#current_text = "".join(ch for ch in current_text if ch not in punct_set) # remove punct
					current_text = current_text.strip().replace(" ", "_")
					print(current_text)
					# search api and set artist if exists
					artist_exists = searchForArtist(current_text)
					if artist_exists:
						artist = current_text
						break
				if artist:
					break

		# search whole string
		else:
			artist_text = " ".join(text).strip()
			#artist_text = "".join(ch for ch in artist_text if ch not in punct_set) # remove punct

			# search for artist in API
			artist_exists = searchForArtist(artist_text)
			if artist_exists:
				artist = artist_text



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

	# initialize the csv data
	# TODO: have server code do this once and store
	loadCsvData()

	return_responses = { g.CODE: None,
						 g.LOCATION: None,
						 g.ARTIST: None,
						 g.VENUE: None,
						 g.DATE: None,
						 g.MESSAGE: {g.M_TICKET: None,
									 g.M_PREVIEW: None,
									 g.M_SHOW: None,
									 g.M_OTHER: None} }

	parse_text(text, return_responses)


	return_responses[g.MESSAGE][g.M_TICKET] = " "
		#customresponses["Tickets"][randint(0, len(customresponses["Tickets"]))]
	return_responses[g.MESSAGE][g.M_PREVIEW] = " "
		#customresponses["Preview"][randint(0, len(customresponses["Preview"]))]
	return_responses[g.MESSAGE][g.M_SHOW] = " "
		#customresponses["Show"][randint(0, len(customresponses["Show"]))]
	#for p in return_responses:	print p, ",", return_responses[p]
	return return_responses




def loadCsvData():
	# open the city state csv file
	f = open(city_state_filename, 'rt')
	try:
		# each row of the reader is a list
		# [city, state, latitude, longitude]
		reader = csv.reader(f)
	except:
		print("Error opening " + city_state_filename)
		exit(0)

	# build a list of the city, state, lat, lon lists
	for row in reader:
		city_state_data.append([x.lower() for x in row])
	f.close()

	# open the state abbreviation csv file
	f = open(state_abbrev_filename, 'rt')
	try:
		# each row of the reader is a list
		# [state, state abbreviation]
		reader = csv.reader(f)
	except:
		print("Error opening " + state_abbrev_filename)
		exit(0)

	# build a list of the state, state abbreviation lists
	for row in reader:
		state_abbrev_data.append([x.lower() for x in row])
	f.close()



def searchForArtist(potential_artist):

	url = echo_api_request%(echo_api_key, potential_artist)

	try: data = request.get(url)
	except e:
		sys.stderr.write('BAD REQUEST\n')
		return False
	try:
		response = json.loads(data.read())
	except ValueError:
		sys.stderr.write('JSON ERROR\n')
		return False

	if len(response['response']['artists']) > 0:
		return True
	else:
		return False




