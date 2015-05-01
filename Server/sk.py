#!/usr/bin/env python2.7
import requests
import globals as g
import datetime

SK_APIKEY = "jgPHHuhmqGdnSzjE"
EN_APIKEY = "NBXSOUGUPQXDHPCGX"
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
Find artist id using songkick and then find image using echonest
'''
def searchForArtistImage(artist_name):
    artist_name.replace(" ","+")
    try:
        id = searchForArtistID(artist_name)
        url = "http://developer.echonest.com/api/v4/artist/images?api_key=NBXSOUGUPQXDHPCGX&id=songkick:artist:" + str(id) + "&format=json"
        data = getDataFromURL(url)
        return data["response"]["images"][0]["url"]
    except:
        return "http://static.giantbomb.com/uploads/original/0/6087/2435649-0965498946-rockb.jpg"

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
Get the event data given a venue name.
'''
def searchForEventByVenueName(venue_name,index=0):
    venue_name.replace(" ","+")
    url = SK_URL + "search/venues.json?query=" + venue_name + "&apikey=" + SK_APIKEY
    data = getDataFromURL(url)
    try:
        venue = data["resultsPage"]["results"]["venue"][0]
        id = venue["id"]
        url2 = SK_URL + "venues/" + str(id) + "/calendar.json?apikey=" + SK_APIKEY
        data2 = getDataFromURL(url2)
        return(data2)
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
        itunes_data = getDataFromURL('https://itunes.apple.com/search?term='+ artistName +'&entity=song&sort=recent&limit=1') #
        previewURL = itunes_data["results"][0]["previewUrl"]
        return previewURL
    except Exception as e:
        print("""Exception getPreviewSong! """ + str(e))
        return "None"

def searchForVenue(venue_name):
    url = SK_URL + "search/venues.json?query="+ venue_name +"&apikey=" + SK_APIKEY
    data = getDataFromURL(url)

'''
Create a string given the YYYY-MM-DDTHH:MM:SS format
'''


def getStringFromDate(input):
    try:
        try:
            d_t = input.split("T")
            d = d_t[0].split("-")
            t = d_t[1].split(":")
            year = int(d[0])
            month = int(d[1])
            day = int(d[2])
            dt = datetime.date(year,month,day)
            day_s = dt.strftime("%A %B %d %Y")

            tm = datetime.datetime.strptime(d_t[1],"%H:%M:%S")
            tm2 = tm.strftime("%I:%M %p")

            return day_s + " at " + tm2
        except:
            d = input.split("-")
            year = int(d[0])
            month = int(d[1])
            day = int(d[2])
            dt = datetime.date(year,month,day)
            day_s = dt.strftime("%A %B %d %Y")
            return day_s
    except:
        return "None"

'''
Helper method for looking up dictionary keys. Returns a string of None rather
than a None object. This is easier for the device code to handle.
'''
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
This is the universal function for constructing the map that is returned to the
user. This function is designed to handle the different formats that the song
kick api will return.
'''
def getEventDataFromSearch(data, index=0):
    try:
        try:
            if index >= len(data["resultsPage"]["results"]["event"]):
                index = 0
            results = data["resultsPage"]["results"]["event"][index]
        except:
            # In the case that there are no shows for the artist
            # Return an empty dict
            output = {
                g.ARTIST: "None",
                g.PREVIEW: "None",
                g.VENUE: "None",
                g.VENUENUM: "None",
                g.VENUEWEB: "None",
                g.VENUELAT: "None",
                g.VENUELNG: "None",
                g.DATE: "None",
                g.TICKETS: "None",
                g.PICTURE: "None"
            }
            return output
        #ARTIST NAME
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

        picture = searchForArtistImage(artist)

        output = {
            g.ARTIST: artist,
            g.PREVIEW: preview,
            g.VENUE: venue_name,
            g.VENUENUM: venue_phone,
            g.VENUEWEB: venue_website,
            g.VENUELAT: venue_lat,
            g.VENUELNG: venue_lng,
            g.DATE: getStringFromDate(dateOfEvent),
            g.TICKETS: tickets,
            g.PICTURE: picture,
            g.MESSAGE: "None"
        }
        return output

    except Exception as e:
        return """Exception! getEventDataFromSearch """ + str(e)

'''
Main function for getting all of the necessary data back to the user.
Takes keyword input from the nlp library, the lat / long data from the device,
and the index of the search. Returns a dict with all of the data that could be
found.
'''
def searchByKeywords(keywords, latitude, longitude, index):
    code = keywords[g.CODE]
    location = keywords[g.LOCATION]
    artist = keywords[g.ARTIST]
    venue = keywords[g.VENUE]
    message = keywords[g.MESSAGE]
    date = keywords[g.DATE]


    # Unrecognized query
    if code == 0:
        output = {
                g.ARTIST: "None",
                g.PREVIEW: "None",
                g.VENUE: "None",
                g.VENUENUM: "None",
                g.VENUEWEB: "None",
                g.VENUELAT: "None",
                g.VENUELNG: "None",
                g.DATE: "None",
                g.TICKETS: "None",
                g.PICTURE: "None",
                g.MESSAGE: message
            }
        return output
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
        data = searchForEventByVenueName(venue)
        return getEventDataFromSearch(data,index)
    else:
        return {}

def test():
    keywords = {
        g.CODE:2,
        g.LOCATION:"Philadelphia",
        g.LATITUDE:39.9500,
        g.LONGITUDE:-75.1667,
        g.ARTIST:"Clap Your Hands Say Yeah",
        g.VENUE:"Johnny Brendas",
        g.DATE:"Today",
        }
    #print(searchByKeywords(keywords,39.9500,-75.1667,0))
    #print(searchByKeywords(keywords,39.9500,-75.1667,1))
    #print(searchByKeywords(keywords,39.9500,-75.1667,2))

    data1 = searchForEventByVenueName("Johnny Brendas")
    print(getEventDataFromSearch(data1))

    print(getEventDataFromSearch(data1,1))

    print(getEventDataFromSearch(data1,2))

    '''
    data1 = searchForEventByArtistName("Radiohead")
    print(getEventDataFromSearch(data1))

    data2 = searchForEventByLocationCoordinates(39.9500, -75.1667)
    print(getEventDataFromSearch(data2))

    data3 = searchForEventByLocationName("Philadelphia")
    print(getEventDataFromSearch(data3))
    '''

