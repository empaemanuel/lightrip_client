import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

class MapServices{

  /// Takes two geo points and returns midpoint.
  /// https://www.movable-type.co.uk/scripts/latlong.html
  LatLng midPoint(LatLng from, LatLng to){
    //convert to radians
    num dLon = _degreesToRads(from.longitude - to.longitude);
    num fromLat = _degreesToRads(from.latitude);
    num toLat = _degreesToRads(to.latitude);
    num toLon = _degreesToRads(to.longitude);

    num bx = cos(fromLat) * cos(dLon);
    num by = cos(fromLat) * sin(dLon);
    num midLat = atan2(sin(fromLat) + sin(toLat), sqrt((cos(toLat) + bx) * (cos(toLat) + bx) + by * bx));
    num midLon = toLon + atan2(by, cos(toLat) + bx);

    LatLng midPoint = LatLng(midLat, midLon);

    //stora latitude går norr
    //stora longitude går öst
    num northBound = max(from.latitude, to.latitude);
    num eastBound = max(from.longitude, to.longitude);
    num westBound = min(from.longitude, to.longitude);
    num southBound = min(from.latitude, to.latitude);

    LatLng southWestBound = LatLng(southBound, westBound);
    LatLng northEastBound = LatLng(northBound, eastBound);
    LatLngBounds midBounds = LatLngBounds(southwest: southWestBound, northeast: northEastBound);

    return midPoint;
  }

  LatLngBounds getBounds(LatLng from, LatLng to){
    //stora latitude går norr
    //stora longitude går öst
    num northBound = max(from.latitude, to.latitude);
    num eastBound = max(from.longitude, to.longitude);
    num westBound = min(from.longitude, to.longitude);
    num southBound = min(from.latitude, to.latitude);

    LatLng southWestBound = LatLng(southBound, westBound);
    LatLng northEastBound = LatLng(northBound, eastBound);
    LatLngBounds midBounds = LatLngBounds(southwest: southWestBound, northeast: northEastBound);

    return midBounds;
  }

  num _degreesToRads(num deg){
    return (deg * pi) / 180.0;
  }

}