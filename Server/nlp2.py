#!/usr/bin/env python2.7
import sys
import os
import csv
import pickle
import urllib2
import random
import math
import json
import string
import globals as g

city_state_csv_filename = "city_state.csv"
city_state_pickle_filename = "city_state_picklefile"
stopwords_txt_filename = "stopwords.txt"
stopwords_pickle_filename = "stopwords_picklefile"
echo_api_key = "NBXSOUGUPQXDHPCGX"
echo_api_request = "http://developer.echonest.com/api/v4/artist/search?api_key=%s&name=%s"
jam_api_key = "kyecf764dkf83ketkharyyrk"
jam_api_request = "http://api.jambase.com/venues?name=%s&page=0&api_key=%s"
sk_api_key = "jgPHHuhmqGdnSzjE"
sk_api_request = "http://api.songkick.com/api/3.0/search/venues.json?query=%s&apikey=%s"


# Possible artist query inputs:
#   "hey morgan, when's the next radiohead show?"
#   "radiohead concert"
#   "is there a radiohead show near me?"
#   "hey, show me radiohead concerts"
#   "do you know when radiohead is playing?"
#   "is radiohead playing?"
#   "radiohead"
#   "does radiohead have any upcoming shows?"
artist_keywords = ["show", "shows", "concert", "concerts", "playing"]

# Possible geolocation query inputs:
#   "what's going on near me"
#   "who can i go see tonight"
#   "is there a concert nearby tonight"
geolocation_phrases = ["nearby", "near me", "tonight"]

time_phrases = ["tonight", "tomorrow", "today"]

salutation_phrases = \
    ["hi", "hello", "hey", "whats up", "whattup", "waddup", "hows it going", "hows it goin",
    "whats cooking", "hey whats up", "hello beautiful", "i want to marry you", "i like you", "i love you",
    "love me", "yo", "yo whats up", "what are you up to", "how are you"]

salutation_responses = ["What's cookin good lookin?", "How's it hanging sugar daddy/mama?",
                        "How can I help you darlin?","Oh wow! You made my day by saying hey.", 
                        "I am here to SERVE YOU!","Only tell me something I want to hear.", 
                        "Did you watch the last Game of Thrones episode? Raunchy.",
                        "I wrote a song about you. You can't hear it.", "Let's Boogie.", 
                        "Let's get Funky.","Let's get it started in HEeeeeEeEEEERE."]

profane_phrases = ["fuck", "shit", "damn", "bitch", "ass", "motherfucking", "fucker", "slut"]

profane_responses = ["Oh my! Can you please ask something nicely?", 
                    "Keep it kosher. Try me again without the profanity.",
                    "Lose the attitude. Ask me something like I'm your Grandma."]

def parse_text(text, return_responses):

    # load necessary city state and stopwords data
    my_dir = os.path.dirname(__file__)

    cs_pickle_file_path = os.path.join(my_dir, city_state_pickle_filename)
    picklefile = open(cs_pickle_file_path, 'rb') # open city state list
    city_state_data = pickle.load(picklefile)
    picklefile.close()

    sw_pickle_file_path = os.path.join(my_dir, stopwords_pickle_filename)
    picklefile = open(sw_pickle_file_path, 'rb') # open stopwords list
    stopwords_data = pickle.load(picklefile)
    picklefile.close()

    # set for use in removing punctuation from strings
    punct_set = set(string.punctuation)

    # see if the user input is a salutation
    search_text = ''.join(c for c in text if c not in punct_set)
    search_text = search_text.lower().strip()
    if search_text in salutation_phrases:
        return_responses[g.CODE] = 0 # code 0 = not a query
        return_responses[g.MESSAGE] = \
            salutation_responses[int(random.random()*len(salutation_responses))] + " Ask me anything!"
        return return_responses

    for word in profane_phrases:
        if word in text:
            return_responses[g.CODE] = 0 # code 0 = not a query
            return_responses[g.MESSAGE] = \
                profane_responses[int(random.random()*len(profane_responses))]
            return return_responses

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
            return_responses[g.MESSAGE] = \
                "I'm sorry! I couldn't understand that. Is %s a city in the US?" % city

    # look for a venue using the keyword 'at'
    elif 'at' in text:
        i = text.index('at')
        # get the rest of the sentence after keyword into a single string
        text = text[i + 1: len(text)]
        # remove time phrases if they are present
        found_time_phrase = None
        for word in time_phrases:
            if word in text:
                found_time_phrase = word
        if found_time_phrase:
            text.remove(found_time_phrase)

        venue = ' '.join(text)
        venue = ''.join(c for c in venue if c not in punct_set) # remove punctuation
        # check if the venue exists
        if search_for_venue(venue):
            # save this venue in the data sent to server
            return_responses[g.CODE] = 4 # user's query = find shows by venue
            return_responses[g.VENUE] = venue
        else:
            return_responses[g.CODE] = 0 # user's query = not understood
            return_responses[g.MESSAGE] = \
                "I'm sorry! I don't recognize that venue. Can you ask me something else?"


    # check the entire text for location, artist, or geolocation
    else:
        text = ' '.join(text).strip()
        text = ''.join(c for c in text if c not in punct_set) # remove punctuation

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

        # (1) check for location
        if city_exists:
            return_responses[g.CODE] = 2 # user's query = find shows by location
            return_responses[g.LOCATION] = city
            return return_responses

        # try to parse an artist name
        artist_exists = False
        artist = None
        found = False
        # search for artist keyword, and only search string before keyword for artist
        search_text = text.split()
        for word in search_text:
            if word in artist_keywords:
                found = True
                search_text = search_text[0: search_text.index(word)]
        if found:
            # search prioritized permutations of truncated text
            n = len(search_text)
            for i in range(2):
                for j in range(0, n-i):
                    # get permutation string to search api for
                    current_text = search_text[j:n-i]
                    if len(current_text) == 1:
                        if current_text[0] in stopwords_data:
                            continue
                    current_text = ' '.join(current_text)
                    current_text = current_text.strip()
                    # search api and set artist if exists
                    artist_exists = search_for_artist(current_text)
                    if artist_exists:
                        artist_exists = True
                        artist = current_text
                        break
                if artist_exists:
                    break
        else:
            if search_for_artist(text):
                artist_exists = True
                artist = text

        # (2) check for artist
        if artist_exists:
            return_responses[g.CODE] = 3 # user's query = find shows by artist
            return_responses[g.ARTIST] = artist
            return return_responses

        # try to parse a venue name
        venue_exists = False
        venue = None
        # remove time phrases if they are present
        text = text.split()
        found_time_phrase = None
        for word in time_phrases:
            if word in text:
                found_time_phrase = word
        if found_time_phrase:
            text.remove(found_time_phrase)
        text = ' '.join(text).strip()
        # search for venue name using song kick api
        if search_for_venue(text):
            venue_exists = True
            venue = text

        # (3) check for venue
        if venue_exists:
            return_responses[g.CODE] = 4 # user's query = find shows by venue
            return_responses[g.VENUE] = venue

        # (4) check for geolocation
        elif any(word in text for word in geolocation_phrases):
            return_responses[g.CODE] = 1 # user's query = shows near me query

        # (5) if nothing found, prompt user for new query
        else:
            return_responses[g.CODE] = 0 # user's query = not understood
            return_responses[g.MESSAGE] = \
                "I'm sorry! I don't understand what you're asking. Hit me with something else!"


def get_keywords(text):

    return_responses = {
        g.CODE: None,
        g.LOCATION: None,
        g.ARTIST: None,
        g.VENUE: None,
        g.DATE: None,
        g.MESSAGE: None }

    parse_text(text, return_responses)
    return return_responses

def search_for_artist(potential_artist):
    potential_artist = potential_artist.replace(' ', '_')
    #print('search_for_artist called with text \'%s\'' % potential_artist)
    url = echo_api_request%(echo_api_key, potential_artist)
    try:
        data = urllib2.urlopen(url)
    except urllib2.HTTPError:
        print("search_for_artist: bad request to echonest api with \'%s\'" % potential_artist)
        sys.stderr.write("BAD REQUEST\n")
        return False
    try:
        response = json.loads(data.read())
    except ValueError:
        print("search_for_artist: error reading json from api response")
        sys.stderr.write("JSON ERROR\n")
        return False

    if len(response["response"]["artists"]) > 0:
        return True
    else:
        return False

def search_for_venue(potential_venue):
    potential_venue = potential_venue.replace(' ','+')
    url = sk_api_request%(potential_venue, sk_api_key)
    #print(url)
    try:
        data = urllib2.urlopen(url)
    except urllib2.HTTPError:
        print("search_for_venue: bad request to songkick api with \'%s\'" % potential_venue)
        sys.stderr.write('BAD REQUEST\n')
        return False
    try:
        response = json.loads(data.read())
    except ValueError:
        print('search_for_venue: error reading json from api response')
        sys.stderr.write('JSON ERROR\n')
        return False

    if "venue" in response["resultsPage"]["results"]:
        return True
    else:
        return False

# helper functions for storing raw city data and 
# stopwords data as pickled data structures
def load_csv_data():
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

def load_stopwords():
    # open the stopwords txt file
    f = open(stopwords_txt_filename, 'rt')
    stopwords_data = []
    try:
        # load each word as a list item
        stopwords_data = f.read().splitlines()
    except:
        print("Error opening " + stopwords_txt_filename)
        exit(0)
    f.close()

    # save stopwords_data as a pickle file
    picklefile = open(stopwords_pickle_filename, 'wb')
    pickle.dump(stopwords_data, picklefile)
    picklefile.close()




