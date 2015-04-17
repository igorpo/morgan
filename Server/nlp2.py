import sys
import nltk
import globals as g
import csv
from random import randint

city_state_filename = "city_state.csv"
state_abbrev_filename = "state_abbreviation.csv"
city_state_data = []
state_abbrev_data = []

# new nlp

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


#geolocation_phrases = ["nearby", "near me", "shows", "concerts", "tonight"]

def parse_text(text, return_responses):
	# TODO: must handle the case query code 1 (asking for shows in default location)

	# tokenize the string into words
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
			city = city.strip().lower()
		else:
			city = location.strip().lower()

		# initialize the csv data
		# TODO: have server code do this once and store
		loadCsvData()

		# search for city name in csv data
		city_exists = False
		for one_city in city_state_data:
			# compare our city's name to this city
			if city == one_city[0].strip().lower():
				city_exists = True
				break

		if city_exists:
			# save this location in the data sent to server
			return_responses[g.CODE] = 2 # user's query = find shows by location
			return_responses[g.LOCATION] = city 
			return_responses[g.MESSAGE][g.TICKET] = \
				customresponses["Tickets"][randint(0, len(customresponses["Tickets"]))]
			return_responses[g.MESSAGE][g.PREVIEW] = \
				customresponses["Preview"][randint(0, len(customresponses["Preview"]))]
			return_responses[g.MESSAGE][g.SHOW] = \
				customresponses["Show"][randint(0, len(customresponses["Show"]))]		
		else:
			# ask the user for a well-formatted query
			return_responses[g.CODE] = 0 # user's query = not understood
			return_responses[g.MESSAGE][g.OTHER] = \
				"I'm sorry! I don't understand what you're asking. Is %s a city in the US?" % city


	# look for venue using keyword "at"
	elif 'at' in text:
		pass

	# remove stop words and search for artist
	else:
		# ask the user for a well-formatted query
		return_responses[g.CODE] = 0 # user's query = not understood
		return_responses[g.MESSAGE][g.OTHER] = \
			"I'm sorry! I don't understand what you're asking."



def getKeywords(text):

	return_responses = { g.CODE: None,
						 g.LOCATION: None, 
						 g.ARTIST: None, 
				 		 g.VENUE: None, 
				 		 g.DATE: None,
				 		 g.MESSAGE: {g.TICKET: None,
				 		 			 g.PREVIEW: None,
				 		 			 g.SHOW: None,
				 		 			 g.OTHER: None} }
	
	parse_text(text, return_responses)

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





	
