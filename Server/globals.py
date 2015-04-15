# Global Variables
# Morgan App: Server / NLP Code

# CODE = (Integer) type of query received
#	0  = unrecognized query
#	1  = shows near me query
#	2  = shows by an artist
#	3  = shows at a venue
CODE = "code"

# LOCATION = (String) zip code of the location of interest, geolocation of device by default
LOCATION = "location"

# ARTIST = (String) artist's name
ARTIST = "artist"

# PREVIEW = (String) link to itunes .m4a preview file
PREVIEW = "preview"

# VENUE = (String) venue name
VENUE = "venue"
VENUENUM = "venue_number"
VENUEWEB = "venue_website"
VENUELAT = "venue_lat"
VENUELNG = "venue_lng"

# DATE = (Datetime) date of interest, current date by default
DATE = "date"

# MESSAGE = (Dictionary) messages to include along with data received from SK API
#	Keys  = SHOW, TICKET, PREVIEW
#	Values = (String) personalized message
#	Example = { SHOW: "This show looks like an awesome time: "
#				TICKET: "Super! You can get tickets here: ",
#				PREVIEW: "Take a listen: " }
MESSAGE = "message"
# Dictionary Keys
TICKET = "ticket"
PREVIEW = "preview"


