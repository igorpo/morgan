#!/usr/bin/env python2.7
import sys
import nltk


autoresponses = ["I'm down! Show me tickets.",
				 "Not sure. Give me more info.",
				 "Fuck you morgan. Show me something else!"]

geolocation_phrases = ["nearby", "near me", "shows", "concerts", "tonight"]

def parse_text(text, return_responses):
	if text == autoresponses[0]:
		return_responses["Custom"] = "Sorry, can't find those tickets yet. Enter a new query!"
		return return_responses
	if text == autoresponses[1]:
		return_responses["Custom"] = "link"
		return return_responses
	if text == autoresponses[2]:
		return_responses["Custom"] = "Sorry, soon we'll show other options. For now, enter a new query."
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


	return_responses["Custom"] = "Sorry, didn't recognize that. Enter a new query!"
	return return_responses



def getKeywords(text):
    # return text
	return_responses = {"Location": None,
						"Artist": None,
				 		"Venue": None,
				 		"Date": None,
				 		"Custom": None,
				 		"UseGeolocation": None}

	return parse_text(text, return_responses)

# 	for p in return_responses:	print p, ",", return_responses[p]
# 	return return_responses


