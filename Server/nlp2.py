import sys
import nltk
import globals
from random import randint


# new nlp
# changes:
# return_responses["Message"] --field to hold mesage that goes along with the data returned 
#								from the server, should be default response if all other fields
#								are None
# return_responses["Custom"] -- contains the keyword "Ticket", "Preview", or "Next" if the user
#								selects one of the autoresponses
#								"Ticket" = Return link to purchase tix
#								"Preview" = Return .m4a clip of Artist's music
#								"Next" = Return the next show that might be of interest to user
# 


# autoresponses = ["I'm down! Show me tickets.",
# 				 "Not sure. Give me more info.",
# 				 "Fuck you morgan. Show me something else!"]

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
					"Show": ["Here's one I think you might like: ",
							 "What about this show? ",
							 "Called my friends and this is the hottest hit in town: ",
							 "All the cool kids are going here: ",
							 "Give this one a gander: " ]}


#geolocation_phrases = ["nearby", "near me", "shows", "concerts", "tonight"]



def parse_text(text, return_responses):

	# tokenize sentences, tokenize words, tag words, chunk words using nltk
	#sentences = nltk.sent_tokenize(text)
	# add the chunks to a list called chunks
	#chunks = []
	#for sent in sentences:
    #	for chunk in nltk.ne_chunk(nltk.pos_tag(nltk.word_tokenize(sent))):
    #		chunks.append(chunk)

	# loop through the chunks and check for keywords
	#for chunk in chunks:
		# look for location using keyword "in"

		# look for venu using keyword "at"



	# tokenize the string into words
	text = text.split()


	# look for location using keyword "in"
	if "in" in text:
		i = text.index("in")
		
		# get the rest of the sentence after keyword into a single string
		location = text[i + 1, len(text)]
		" ".join(location)

		# search location string for comma
		if "," in location:
			city = location[0 : location.index(",")]
			state = location[location.index(",") + 1 : len(location)] 







	# look for venu using keyword "at"


	# remove stop words / common words / found locations or venues 

	# search for artist






	if text == autoresponses[0]:
		return_responses["Message"] = customresponses["Tickets"][randit(0, len(customresponses["Tickets"]))]
		return_responses["Custom"] = "Tickets"
		return return_responses
	if text == autoresponses[1]:
		return_responses["Message"] = customresponses["Preview"][randit(0, len(customresponses["Preview"]))]
		return_responses["Custom"] = "Preview"
		return return_responses
	if text == autoresponses[2]:
		return_responses["Custom"] = "Next"
		return return_responses


	sentences = nltk.sent_tokenize(text)
	for sent in sentences:
         for chunk in nltk.ne_chunk(nltk.pos_tag(nltk.word_tokenize(sent))):
             if hasattr(chunk, 'label'):
             	if chunk.label() == 'GSP' or chunk.label() == 'GPE':
                	return_responses["Location"] = ' '.join(c[0] for c in chunk.leaves())
                	return return_responses

             	if chunk.label() == 'PERSON':
             		return_responses["Artist"] = ' '.join(c[0] for c in chunk.leaves())
             		return return_responses


	for phrase in geolocation_phrases:
		if phrase in text.lower():
			return_responses["UseGeolocation"] = True
			return return_responses


	return_responses["Message"] = "Sorry, didn't recognize that. Enter a new query!"            	
	return return_responses



def getKeywords(text):

	return_responses = {"Location": None, 
						"Artist": None, 
				 		"Venue": None, 
				 		"Date": None,
				 		"Custom": None, 
				 		"UseGeolocation": None,
				 		"Message": None}
	
	parse_text(text, return_responses)

	#for p in return_responses:	print p, ",", return_responses[p]
	return return_responses
