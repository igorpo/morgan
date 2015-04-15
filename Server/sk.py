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
        # ARTIST NAME
        artist = results["performance"][0]["artist"]["displayName"]
        # PREVIEW LINK
        preview = getPreviewSong(artist)
        # VENUE NAME
        venue = results["venue"]["displayName"]
        # VENUE LOCATION
        try:
            venue_lat = results["venue"]["zip"]["lat"]
            venue_lng = results["venue"]["zip"]["lng"]
        except:
            venue_lat = None
            venue_lng = None
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
            g.PREVIEW: preview,
            g.VENUE: venue,
            g.VENUENUM: venue_phone,
            g.VENUEWEB: venue_website,
            g.VENUELAT: venue_lat,
            g.VENUELNG: venue_lng,
            g.DATE: dateOfEvent,
        }

        return output

    except Exception as e:
        return """Exception! searchForEvent """ + str(e)

def test():
    a = searchForEventByArtistName("Guster")
    b = getEventDataFromSearch(a)
    print(b)

def searchByKeywords(keywords, index):
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
        return getEventDataFromSearch(data)
    # Shows by an artist
    elif code == 2:
        data = searchForEventByArtistName(artist)
        return getEventDataFromSearch(data)
    # Shows at a venue
    elif code == 3:
        pass
    else:
        return None
    '''
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
    '''

