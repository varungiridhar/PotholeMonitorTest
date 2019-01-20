import requests
from math import radians, cos, sin, asin, sqrt
latArray = []
lngArray = []
potholeDepth = []
strokeColour = "#FF0000"

from flask import Flask, render_template

app = Flask(__name__)
app.debug = True

@app.route('/')
def hello_world():
    global strokeColour
    c = requests.get("https://oakridgepotholeapp.firebaseio.com/data.json")
    valuesList = c.json()
    for x in valuesList:
        lat = x["locationLatitude"]
        lng = x["locationLongitude"]
        pDepth = x["potholeDepth"]
        potholeDepth.append(pDepth)
        latArray.append(lat)
        lngArray.append(lng)
    distBetweenPoints = haversine(latArray[0],lngArray[0],latArray[7],lngArray[7])
    if distBetweenPoints < 100:
        strokeColour = "#FF0000"
    elif distBetweenPoints < 500:
        strokeColour = "#FFFF00"
    else :
        strokeColour = "#0000FF"
    return render_template("map_test.html", latArray=latArray, lngArray=lngArray, strokeColour=strokeColour, potholeDepth=potholeDepth)
@app.route('/someroute')
def someroute():
    return("No bugs here")

def haversine(lat1,lng1,lat2,lng2): #find distance between 2 GPS coordinates
    radius = 6372.8
    dLat = radians(lat2 - lat1)
    dLng = radians(lng2 - lng1)
    lat1 = radians(lat1)
    lat2 = radians(lat2)
    a = sin(dLat/2)**2+cos(lat1)*cos(lat2)*sin(dLng/2)**2
    c=2*asin(sqrt(a))
    return radius*c

