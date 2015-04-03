import requests

SK_APIKEY = "jgPHHuhmqGdnSzjE"
SK_URL = "http://api.songkick.com/api/3.0/"

def getDataFromURL(url):
    try:
        response = requests.get(url)
        return response.json()
    except:
        return None

def _searchForLocation(location_name, index=0):
    url = SK_URL + "search/locations.json?query="+ location_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        results = data["resultsPage"]["results"]["location"]
        location_id = results[index]["metroArea"]["id"]
        return location_id
    except:
        return None

def searchForEvent(location, user_latitude, user_longitude, index=0):
    if location is None:
        url = SK_URL + "events.json?location=geo:" + str(user_latitude) + "," + str(user_longitude) + "&apikey=" + SK_APIKEY
    else:
        id = _searchForLocation(location)
        if id is not None:
            url = SK_URL + "events.json?location=sk:" + str(id) + "&apikey=" + SK_APIKEY
        else:
            return None
    data = getDataFromURL(url)
    try:
        results = data["resultsPage"]["results"]["event"][index]
        artist = results["performance"][0]["artist"]["displayName"]
        venue = results["venue"]["displayName"]
        date = results["start"]["datetime"]
        return artist + " is playing at " + venue + " on " + date + "."
    except:
        return None

def searchForArtist(artist_name):
    url = SK_URL + "search/artists.json?query="+ artist_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

def searchForVenue(venue_name):
    url = SK_URL + "search/venues.json?query="+ venue_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

def searchByKeywords(dict, lat, long):
    location = dict["Location"]
    artist = dict["Artist"]
    venue = dict["Venue"]
    custom = dict["Custom"]
    date = dict["Date"]
    use_geo = dict["UseGeolocation"]

    if use_geo:
        return searchForEvent(None,lat,long, index=0)
    if custom is not None:
        return custom
    elif location is not None:
        return searchForEvent(location,lat,long, index=0)
    elif artist is not None:
        return "Artist search doesn't exist yet. Try again."
    else:
        return None

