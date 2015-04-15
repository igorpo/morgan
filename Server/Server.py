from datetime import timedelta
from functools import update_wrapper
from flask import Flask, request, url_for, make_response, current_app
import sk
import nlp

try:
    unicode = unicode
except NameError:
    # 'unicode' is undefined, must be Python 3
    str = str
    unicode = str
    bytes = bytes
    basestring = (str,bytes)
else:
    # 'unicode' exists, must be Python 2
    str = str
    unicode = unicode
    bytes = str
    basestring = basestring

app = Flask(__name__)
app.debug = True

def crossdomain(origin=None, methods=None, headers=None,
                max_age=21600, attach_to_all=True,
                automatic_options=True):
    if methods is not None:
        methods = ', '.join(sorted(x.upper() for x in methods))
    if headers is not None and not isinstance(headers, basestring):
        headers = ', '.join(x.upper() for x in headers)
    if not isinstance(origin, basestring):
        origin = ', '.join(origin)
    if isinstance(max_age, timedelta):
        max_age = max_age.total_seconds()

    def get_methods():
        if methods is not None:
            return methods

        options_resp = current_app.make_default_options_response()
        return options_resp.headers['allow']

    def decorator(f):
        def wrapped_function(*args, **kwargs):
            if automatic_options and request.method == 'OPTIONS':
                resp = current_app.make_default_options_response()
            else:
                resp = make_response(f(*args, **kwargs))
            if not attach_to_all and request.method != 'OPTIONS':
                return resp

            h = resp.headers

            h['Access-Control-Allow-Origin'] = origin
            h['Access-Control-Allow-Methods'] = get_methods()
            h['Access-Control-Max-Age'] = str(max_age)
            if headers is not None:
                h['Access-Control-Allow-Headers'] = headers
            return resp

        f.provide_automatic_options = False
        return update_wrapper(wrapped_function, f)
    return decorator


@app.route('/', methods=['POST'])
@crossdomain(origin='*')
def queryMorgan():
    try:
        data = str(request.form["user_raw_data"])
        lat = float(request.form["user_lat"])
        lon = float(request.form["user_lon"])
        index = int(request.form["user_index"])
        keywords = nlp.getKeywords(data)

        return_string = sk.searchByKeywords(keywords, lat, lon, index)
        # return """Keywords """ + str(keywords) + """ lat: """ + str(lat) + """ lon: """ + str(lon)
        return str(return_string)

    except Exception as e:
        return """Exception! queryMorgan """ + str(e)

        # Send synthesized string from NLP back to device
'''
def createReturnData():
    text =
    {
        "response":"Blah blah",
        "audio":".m4a",
        "tickets":"http:songkick...",
        "search_index":0
    }
'''
@app.route('/<artist_name>/preview', methods=['POST'])
@crossdomain(origin='*')
def getPreviewSong(artist_name):
    try:
        return sk.getPreviewSong(artist_name)
    except Exception as e:
        return """Exception! getPreviewSong """ + str(e)
    # except:
        # return_string = None

    # if return_string is None:
        # return_string = "Hmm. Looks like something went wrong. Let me call my IT person."

    #return return_string

# def test(mystring):
#     # Get map of keywords back from NLP
#     data = mystring
#     lat = 39.9500
#     long = -75.1667

#     keywords = nlp.getKeywords(data)

#     # Seach SK based on keywords
#     return_string = sk.searchByKeywords(keywords, lat, long)

#     if return_string is None:
#         return_string = "Hmm. Looks like something went wrong. Let me call my IT fucker."

#     return return_string


# #app.secret_key = 'This is really unique and secret'

@app.route('/test', methods=['POST'])
@crossdomain(origin='*')
def hello_person():
    return """testReturn"""
    # return """
    #     <p>Input sample code.</p>
    #     <form method="POST" action="%s">
    #     <input name="user_raw_data" />
    #     <input name="user_lat" />
    #     <input name="user_lon" />
    #     <input type="submit" value="Go!" />
    #     </form>
    #     """ % (url_for('queryMorgan'),)
