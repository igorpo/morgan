import requests
import globals as g

SK_APIKEY = "jgPHHuhmqGdnSzjE"
SK_URL = "http://api.songkick.com/api/3.0/"

'''
Process url request and return result.
'''
def getDataFromURL(url):
    try:
        response = requests.get(url)
        return response.json()
    except Exception as e:
        return """Exception! getDataFromURL """ + str(e)

'''
Use the songkick api to lookup an idea for a location name
'''
def searchForLocationID(location_name, index = 0):
    url = SK_URL + "search/locations.json?query="+ location_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        results = data["resultsPage"]["results"]["location"]
        location_id = results[index]["metroArea"]["id"]
        return location_id
    except Exception as e:
        return """Exception! searchForLocation """ + str(e)

'''
Get event data from searching by location name.
'''
def searchForEventByLocationName(location_name):
    id = searchForLocationID(location_name)
    if id is not None:
        url = SK_URL + "events.json?location=sk:" + str(id) + "&apikey=" + SK_APIKEY
        return(getDataFromURL(url))
    else:
        return(None)

'''
Get event data from searching by lat lon values.
'''
def searchForEventByLocationCoordinates(latitude, longitude):
    url = SK_URL + "events.json?location=geo:" + str(latitude) + "," + str(longitude) + "&apikey=" + SK_APIKEY
    return(getDataFromURL(url))

def retrievePreview(artist_name, index):
    url = SK_URL + "search/artists.json?query="+ artist_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        result = data["resultsPage"]["results"]["artist"][index]["displayName"]
        return result
    except Exception as e:
        return """Exception! retrievePreview """ + str(e)

'''
Get .m4a link for artist preview through itunes api call.
'''
def getPreviewSong(artistName):
    try:
        artistName.replace(" ","+")
        itunes_data = getDataFromURL('https://itunes.apple.com/search?term='+ artistName +'&limit=1')
        previewURL = itunes_data["results"][0]["previewUrl"]
        return previewURL
    except Exception as e:
        return """Exception getPreviewSong! """ + str(e)

def searchForVenue(venue_name):
    url = SK_URL + "search/venues.json?query="+ venue_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

'''
Process songkick api retrieval and build dictionary of relevent info.
'''
def getEventDataFromSearch(data, index=0):
    try:
        results = data["resultsPage"]["results"]["event"][index]
        artist = results["performance"][0]["artist"]["displayName"]
        # VENUE NAME
        venue = results["venue"]["displayName"]
        # VENUE LOCATION
        try:
            venue_lat = results["venue"]["zip"]["lat"]
            venue_lng = results["venue"]["zip"]["lng"]
        except:
            venue_location = None
        # VENUE PHONE
        try:
            venue_phone = results["venue"]["phone"]
        except:
            venue_phone = None
        # VENUE WEBSITE
        try:
            venue_website = results["venue"]["website"]
        except:
            venue_website = None
        # DATE AND TIME
        try:
            if results["start"]["datetime"] is not None:
                dateOfEvent = results["start"]["datetime"]
            else:
                dateOfEvent = results["start"]["date"]
        except:
            dateOfEvent = None

        output = {
            g.ARTIST: artist,
            g.VENUE: venue,
            g.VENUENUM: venue_number,
            g.VENUEWEB: venue_website,
            g.VENUELAT: venue_lat,
            g.VENUELNG: venue_lng,
            g.DATE: dateOfEvent,
        }

        return output
        #return str(artist) + " is playing at " + str(venue) + " on " + str(dateOfEvent) + "."

    except Exception as e:
        return """Exception! searchForEvent """ + str(e)

def searchByKeywords(keywords, lat, lon, index):
    location = keywords["Location"]
    artist = keywords["Artist"]
    venue = keywords["Venue"]
    custom = keywords["Custom"]
    date = keywords["Date"]
    use_geo = keywords["UseGeolocation"]

    if use_geo:
        return searchForEvent(None,lat,lon, index)
    if custom is not None:
        return custom
    elif location is not None:
        return searchForEvent(location,lat,lon, index)
    elif artist is not None:
        return searchForArtist(artist)
    else:
        return None

