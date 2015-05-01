# Global Variables
# Morgan App: Server / NLP Code

# CODE = (Integer) type of query received
#	0  = unrecognized query
#	1  = shows near me query
#   2  = shows by non-default location
#	3  = shows by an artist
#	4  = shows at a venue
CODE = "code"

# LOCATION = (String) city name of the location of interest,
#            geolocation of device by default (if LOCATION field is nil)
LOCATION = "location"
LATITUDE = "latitude"
LONGITUDE = "longitude"

# ARTIST = (String) artist's name
ARTIST = "artist"

# PICTURE
PICTURE = "artist_picture"

# PREVIEW = (String) link to itunes .m4a preview file
PREVIEW = "preview"

# VENUE = (String) venue name
VENUE = "venue"
VENUENUM = "venue_number"
VENUEWEB = "venue_website"
VENUELAT = "venue_lat"
VENUELNG = "venue_lng"

TICKETS = "buyLink"

# DATE = (Datetime) date of interest, current date by default
DATE = "date"

# MESSAGE = (Dictionary) messages to include along with data received from SK API
#	Keys  = SHOW, TICKET, PREVIEW
#	Values = (String) personalized message
#	Example = { SHOW: "This show looks like an awesome time: "
#				TICKET: "Super! You can get tickets here: ",
#				PREVIEW: "Take a listen: "
#				OTHER: "I'm sorry, I don't understand what you're asking"}
MESSAGE = "message"
# Dictionary Keys
M_TICKET = "ticket"
M_PREVIEW = "preview"
M_SHOW = "show"
M_OTHER = "other"

SUCCESS = "success"

