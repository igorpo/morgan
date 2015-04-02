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
