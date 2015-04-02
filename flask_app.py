
# A very simple Flask Hello World app for you to get started with...
from flask import Flask, request, url_for
import random
import requests

SK_APIKEY = "jgPHHuhmqGdnSzjE"
SK_URL = "http://api.songkick.com/api/3.0/"


app = Flask(__name__)

@app.route('/', methods=['POST'])
def queryMorgan():
    #if request.method == 'POST':
    #    return request.form['raw_user_data']
    # 1. Pass full string to NLP
    # 2. Get map of keywords back from NLP
    # 3. Seach SK based on keywords
    # 4. Get relevent data from SK and pass back to NLP
    # 5. Send synthesized string from NLP back to device
    data = request.form["user_raw_data"]
    lat = request.form["user_lat"]
    long = request.form["user_lon"]

    return str(data) + str(lat) + str(long)

'''
@app.route('/')
def hello_person():
    return """
        <p>Who do you want me to say "Hi" to?</p>
        <form method="POST" action="%s"><input name="person" /><input type="submit" value="Go!" /></form>
        """ % (url_for('greet'),)

@app.route('/greet', methods=['POST'])
def greet():
    greeting = random.choice(["Hiya", "Hallo", "Hola", "Ola", "Salut", "Privet", "Konnichiwa", "Ni hao"])
    return """
        <p>%s, %s!</p>
        <p><a href="%s">Back to start</a></p>
        """ % (greeting, request.form["person"], url_for('hello_person'))
'''

def getDataFromURL(url):
    try:
        response = requests.get(url)
        return response.json()
    except:
        return None

def searchForEvent(user_latitude= 40.7127, user_longitude= -74.0059, index=0):
    url = "http://api.songkick.com/api/3.0/events.json?location=geo:" + str(user_latitude) + "," + str(user_longitude) + "&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        results = data["resultsPage"]["results"]["event"][index]
        artist = results["performance"][0]["artist"]["displayName"]
        venue = results["venue"]["displayName"]
        date = results["start"]["datetime"]
        print(artist + " is playing at " + venue + " on " + date + ".")
    except:
        print("Hm no results.")

def searchForArtist(artist_name):
    url = "http://api.songkick.com/api/3.0/search/artists.json?query="+ artist_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

def searchForVenue(venue_name):
    url = "http://api.songkick.com/api/3.0/search/venues.json?query="+ venue_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

def searchForLocation(location_name, index=0):
    url = "http://api.songkick.com/api/3.0/search/locations.json?query="+ location_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        results = data["resultsPage"]["results"]["location"]
        location_id = results[index]["metroArea"]["id"]
        print(location_id)
        return location_id
    except:
        print("No location found.")
        return None





