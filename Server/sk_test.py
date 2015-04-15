import sk
import imp

def run():
    imp.reload(sk)
    test_getDataFromURL()
    test_searchForEventByLocationName()
    test_searchForEventByLocationCoordinates()
    test_getEventDataFromSearch()

def returnResult(name,result, passed):
    print(name)
    if passed:
        print("---PASSED---")
    else:
        print("*--FAILED--*")
        print("Error: " + str(result))
        print("-------------")

def test_getDataFromURL():
    result = sk.getDataFromURL("http://ip.jsontest.com/")
    returnResult("getDataFromURL",result, result is not None)

def test_searchForEventByLocationName():
    data = sk.searchForEventByLocationName("New York")
    results = sk.getEventDataFromSearch(data)
    returnResult("searchForEventByLocationName", results , results is not None )

def test_searchForEventByLocationCoordinates():
    data = sk.searchForEventByLocationCoordinates(39.9500,-75.1667)
    results = sk.getEventDataFromSearch(data)
    returnResult("searchForEventByLocationCoordinates",results, results is not None)

def test_getEventDataFromSearch():
    data = sk.searchForEventByLocationName("New York")
    data2 = sk.searchForEventByLocationCoordinates(39.9500,-75.1667)
    result = sk.getEventDataFromSearch(data)
    boolean = result is not None
    boolean = boolean and sk.getEventDataFromSearch(data2) is not None
    returnResult("getEventDataFromSearch", result, boolean)

run()