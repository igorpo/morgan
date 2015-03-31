import sys
import nltk
from nltk import word_tokenize

autoresponses = ["I'm down! Show me tickets.",
				 "Not sure. Give me more info.",
				 "Fuck you morgan. Show me something else!"]


def parse_text(s):
	if s == autoresponses[0]:
		return "Sorry, can't find those tickets yet. Feast your eyes on Cher instead http://thenetworth.net/wp-content/uploads/2013/01/CHER-NET-WORTH1.jpg !"
	if s == autoresponses[1]:
		return "Soon we'll be able to link to some songs. For now, here's some Cher https://www.youtube.com/watch?v=BsKbwR7WXN4"
	if s == autoresponses[2]:
		return "Sorry, soon we'll show other options. For now, enter a new query"
	tokens = word_tokenize(s)
	for token in tokens:



if __name__ == '__main__':
	if not len(sys.argv) > 1:
		exit("NLP App called without text input")
	
	text = sys.argv[1:]
