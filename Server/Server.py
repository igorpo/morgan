
from flask import Flask, request, url_for
import sk
import nlp

app = Flask(__name__)

@app.route('/test')
def test():
    return "ASDASDASDAS"

@app.route('/', methods=['POST'])
def queryMorgan():
    try:
        # Get map of keywords back from NLP
        data = request.form["user_raw_data"]
        lat = request.form["user_lat"]
        long = request.form["user_lon"]
        keywords = nlp.getKeywords(data)

        '''
        dictionary
        {
            "Location":
            "Artist":
            "Venue":
            "Custom":
            "UseGeolocation":
            "Date":
        }
        '''

        # Seach SK based on keywords
        return_string = sk.searchByKeywords(keywords, lat, long)

        # Send synthesized string from NLP back to device
        return return_string

    except:
        return "Hmm. Looks like something went wrong."
    '''
    data = request.form["user_raw_data"]
    lat = request.form["user_lat"]
    long = request.form["user_lon"]
    return "Lat is " + str(lat) + " and Lon " + str(long)
    '''

