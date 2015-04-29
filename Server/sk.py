import requests
import nlp2 as nlp
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
Use the songkick api to lookup the songkick id for a location name
'''
def searchForLocationID(location_name, index = 0):
    url = SK_URL + "search/locations.json?query="+ location_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        results = data["resultsPage"]["results"]["location"]
        location_id = results[index]["metroArea"]["id"]
        return location_id
    except Exception as e:
        return """Exception! searchForLocationID """ + str(e)

'''
Use the songkick api to lookup the songkick id of an artist
'''
def searchForArtistID(artist_name, index=0):
    artist_name = artist_name.replace(" ","+")
    url = SK_URL + "search/artists.json?query=" + artist_name + "&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        return data["resultsPage"]["results"]["artist"][index]["id"]
    except Exception as e:
        return """Exception! searchForArtistID """ + str(e)

'''
Use the songkick api to lookup venue data given a venue id
'''
def getVenueDataByID(id):
    url = SK_URL + "venues/" + str(id) + ".json?apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        return data["resultsPage"]["results"]["venue"]
    except Exception as e:
        return """Exception! searchForArtistID """ + str(e)

'''
'''
def searchForEventByVenueName(venue_name,index=0):
    url = SK_URL + "search/venues.json?query=" + venue_name + "&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        venue = data["resultsPage"]["results"]["venue"][0]
        id = venue["id"]
        url2 = SK_URL + "venues/" + id + "/calendar.json?apikey=" + SK_ID
        data2 = getDataFromURL(url2)
    except:
        return "None"

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

'''
Get event data by searching for an artist.
'''
def searchForEventByArtistName(artist_name):
    url = SK_URL + "artists/" + str(searchForArtistID(artist_name)) + "/calendar.json?apikey=" + SK_APIKEY
    return(getDataFromURL(url))

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
        print("""Exception getPreviewSong! """ + str(e))
        return "None"

def searchForVenue(venue_name):
    url = SK_URL + "search/venues.json?query="+ venue_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

def _get(dictionary,key):
    try:
        if dictionary[key] is not None:
            return dictionary[key]
        else:
            return "None"
    except:
        return "None"

'''
Process songkick api retrieval and build dictionary of relevent info.
'''
def getEventDataFromSearch(data, index):
    try:
        if index >= len(data["resultsPage"]["results"]["event"]):
            index = 0
        results = data["resultsPage"]["results"]["event"][index]
        # ARTIST NAME
        artist = results["performance"][0]["artist"]["displayName"]
        # PREVIEW LINK
        preview = getPreviewSong(artist)
        # VENUE NAME
        venue_id = results["venue"]["id"]
        venue_data = getVenueDataByID(venue_id)
        venue_name = _get(venue_data,"displayName")
        venue_phone = _get(venue_data,"phone")
        venue_website = _get(venue_data,"website")
        venue_lat = _get(venue_data,"lat")
        venue_lng = _get(venue_data,"lng")
        tickets = _get(venue_data,"uri")

        # DATE AND TIME
        try:
            if results["start"]["datetime"] is not None:
                dateOfEvent = results["start"]["datetime"]
            else:
                dateOfEvent = results["start"]["date"]
        except:
            dateOfEvent = "None"

        output = {
            g.ARTIST: artist,
            g.PREVIEW: preview,
            g.VENUE: venue_name,
            g.VENUENUM: venue_phone,
            g.VENUEWEB: venue_website,
            g.VENUELAT: venue_lat,
            g.VENUELNG: venue_lng,
            g.DATE: dateOfEvent,
            g.TICKETS: tickets
        }
        return output

    except Exception as e:
        return """Exception! getEventDataFromSearch """ + str(e)

def test():
    '''
    keywords = {
        g.CODE:1,
        g.LOCATION:"Philadelphia",
        g.LATITUDE:39.9500,
        g.LONGITUDE:-75.1667,
        g.ARTIST:"Clap Your Hands Say Yeah",
        g.VENUE:"Johnny Brendas",
        g.DATE:"Today",
        }
    print(searchByKeywords(keywords,39.9500,-75.1667,0))
    print(searchByKeywords(keywords,39.9500,-75.1667,1))
    print(searchByKeywords(keywords,39.9500,-75.1667,2))
    '''
    keywords = nlp.getKeywords("Shows near me")
    print(keywords)
    return_json = searchByKeywords(keywords, 39.9500,-75.1667, 0)
    print(return_json)


def searchByKeywords(keywords, latitude, longitude, index):
    code = keywords[g.CODE]
    location = keywords[g.LOCATION]
    artist = keywords[g.ARTIST]
    venue = keywords[g.VENUE]
    date = keywords[g.DATE]

    # Unrecognized query
    if code == 0:
        pass
    # Shows near me query
    elif code == 1:
        data = searchForEventByLocationCoordinates(latitude, longitude)
        return getEventDataFromSearch(data,index)
    # Show at location
    elif code == 2:
        data = searchForEventByLocationName(location)
        return getEventDataFromSearch(data,index)
    # Shows by an artist
    elif code == 3:
        data = searchForEventByArtistName(artist)
        return getEventDataFromSearch(data,index)
    # Shows at a venue
    elif code == 4:
        return {}
    else:
        return {}

