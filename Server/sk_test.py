#!/usr/bin/env python2.7
import sk
import imp

def run():
    imp.reload(sk)
    test_getDataFromURL()
    test_searchForLocationID()
    test_searchForArtistID()
    test_searchForEventByLocationName()
    test_searchForEventByLocationCoordinates()
    test_searchForEventByArtistName()
    test_getPreviewSong()
    test_getEventDataFromSearch_coordinates()
    test_getEventDataFromSearch_name()
    test_getEventDataFromSearch_artist()
    test_searchByKeywords()

def returnResult(name,result, passed):
    print(name)
    if passed:
        print("---PASSED---")
        print(result)
    else:
        print("*--FAILED--*")
        print("Error: " + str(result))
        print("-------------")

def test_getDataFromURL():
    results = sk.getDataFromURL("http://ip.jsontest.com/")
    returnResult("getDataFromURL",results, results is not None)

def test_searchForLocationID():
    results = sk.searchForLocationID("New York")
    returnResult("searchForLocationID", results, results is not None)

def test_searchForArtistID():
    results = sk.searchForLocationID("Guster")
    returnResult("searchForArtistID", results, results is not None)

def test_searchForEventByLocationName():
    data = sk.searchForEventByLocationName("New York")
    results = sk.getEventDataFromSearch(data)
    returnResult("searchForEventByLocationName", results , results is not None )

def test_searchForEventByLocationCoordinates():
    data = sk.searchForEventByLocationCoordinates(39.9500,-75.1667)
    results = sk.getEventDataFromSearch(data)
    returnResult("searchForEventByLocationCoordinates",results, results is not None)

def test_searchForEventByArtistName():
    results = sk.searchForEventByArtistName("Guster")
    returnResult("searchForEventByArtistName", results, results is not None)

def test_getPreviewSong():
    results = sk.getPreviewSong("Radiohead")
    returnResult("getPreviewSong",results, results is not None)

def test_getEventDataFromSearch_coordinates():
    data = sk.searchForEventByLocationCoordinates(39.9500,-75.1667)
    results = sk.getEventDataFromSearch(data)
    returnResult("getEventDataFromSearch_coordinates", results, results is not None)

def test_getEventDataFromSearch_name():
    data = sk.searchForEventByLocationName("New York")
    results = sk.getEventDataFromSearch(data)
    returnResult("getEventDataFromSearch_name", results, results is not None)

def test_getEventDataFromSearch_artist():
    data = sk.searchForEventByArtistName("Guster")
    results = sk.getEventDataFromSearch(data)
    returnResult("getEventDataFromSearch_artist", results, results is not None)

def test_searchByKeywords():
    returnResult("searchByKeywords",None,True)

run()