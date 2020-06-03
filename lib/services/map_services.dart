import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:http/http.dart' as http;

class MapServices{
  LatLng _from, _to;

  /// Takes two geo points and returns midpoint.
  /// https://www.movable-type.co.uk/scripts/latlong.html
  LatLng _getMidPoint(LatLng from, LatLng to){
    //convert to radians
    num dLon = _degreesToRads(from.longitude - to.longitude);
    num fromLat = _degreesToRads(from.latitude);
    num toLat = _degreesToRads(to.latitude);
    num toLon = _degreesToRads(to.longitude);

    num bx = cos(fromLat) * cos(dLon);
    num by = cos(fromLat) * sin(dLon);
    num midLat = atan2(sin(fromLat) + sin(toLat),
        sqrt((cos(toLat) + bx) * (cos(toLat) + bx) + by * bx));
    num midLon = toLon + atan2(by, cos(toLat) + bx);

    LatLng midPoint = LatLng(midLat, midLon);

    return midPoint;
  }

  LatLng getMidPoint(){
    return _getMidPoint(_from, _to);
  }

  LatLngBounds getMidPointBounds(){
    return _getMidPointBounds(_from, _to);
  }
  ///Takes two geo positions and returns the bounds of the square that can
  ///be expanded by those two positions.
  LatLngBounds _getMidPointBounds(LatLng from, LatLng to){
    //stora latitude går norr
    //stora longitude går öst
    num northBound = max(from.latitude, to.latitude);
    num eastBound = max(from.longitude, to.longitude);
    num westBound = min(from.longitude, to.longitude);
    num southBound = min(from.latitude, to.latitude);

    LatLng southWestBound = LatLng(southBound, westBound);
    LatLng northEastBound = LatLng(northBound, eastBound);
    LatLngBounds midBounds =
        LatLngBounds(southwest: southWestBound, northeast: northEastBound);

    return midBounds;
  }

  num _degreesToRads(num deg) {
    return (deg * pi) / 180.0;
  }

  LatLng getFrom(){
    return _from;
  }

  LatLng getTo(){
    return _to;
  }

  ///Creates a set of markers from saved positions _from and _to.
  Set<Marker> getMarkers(){
    Set<Marker> tmp = Set();
    if(_from != null ) tmp.add(_getMarker(_from, 'from'));
    if(_to != null ) tmp.add(_getMarker(_to, 'to'));
    return tmp;
  }

  void setLocation_From(LatLng location){
    print('Setting location from: $location');
    _from = location;
  }

  void setLocation_To(LatLng location){
    print('Setting destination to: $location');
    _to = location;
  }

  ///Wraps a LatLng obj with a Marker.
  Marker _getMarker(LatLng location, String id){
    Marker marker = Marker(
      position: location,
      markerId: MarkerId(id),
    );
    return marker;
  }

  ///Driver method that fetches a route from server, creates
  ///polylines for each edge and returns a set of those polylines
  ///as a future.
  Future<Set<Polyline>> getPolylines(int lightLevel) async {
    List<LatLng> result = await _fetchRoute(lightLevel);
    Polyline p = _createPolyLine(result, 'route', Colors.teal);
    Set<Polyline> s = Set();
    s.add(p);
    print('set of polylines $s');
    return s;
  }

  ///Fetch route from server based on _from and _to
  Future<List<LatLng>> _fetchRoute(int lightLevel) async {
    print("loading...");
    final startLat = _from.latitude;
    final startLng = _from.longitude;
    final endLat = _to.latitude;
    final endLng = _to.longitude;

    print('fetching route from $startLat, $startLng to $endLat, $endLng');
    final server = 'https://lightrip-server.herokuapp.com';
    //final server = 'http://192.168.31.153:8080'; //localhost
    final api = 'get_route/get_route';

    final request = '$server/$api?startLat=$startLat&startLong=$startLng&endLat=$endLat&endLong=$endLng&lightLevel=$lightLevel';
    print(request);
    final response = await http.get(request);

    print("inc data!");
    if (response.statusCode == 200) {
      print('Status 200: OK');
      Map dataMap = json.decode(response.body);

      List<LatLng> points = List();

      print(dataMap);
      for (dynamic point in dataMap['route']) {
        print('Adding ${point['latitude']}, ${point['longitude']} to set');
        points.add(LatLng(point['latitude'], point['longitude']));
      }
      return points;
    }
    else {
      print('FAILED, status: ${response.statusCode}');
    }
  }

  ///creates a single polyline from a list of LatLng points.
  Polyline _createPolyLine(List<LatLng> points, var id, Color color){
    Polyline polyline = Polyline(
      polylineId: PolylineId(id),
      color: Color.fromARGB(255, 40, 122, 198),
      //color: color,
      width: 4,
      points: points,
      startCap: Cap.roundCap,
      endCap: Cap.buttCap,
    );
    return polyline;
  }

  ///Method used during development to print all edges in test area to map.
  Future<Set<Polyline>> _getMockAll() async {
    print('loading...');
    final request = 'https://lightrip-server.herokuapp.com/edge/getByLight?lightWeight=10';
    final response = await http.get(request);
    print('done!');
    Set<Polyline> polylines = Set();
    if (response.statusCode == 200) {
      Map map = json.decode(response.body);
      List data = map['Edges: '];

      num count = 0;

      for (Map edge in data) {
        double latFrom = edge['node1']['latitude'];
        double lngFrom = edge['node1']['longitude'];
        double latTo = edge['node2']['latitude'];
        double lngTo = edge['node2']['longitude'];
        print(latFrom);
        print(lngFrom);
        print(latTo);
        print(lngTo);
        List<LatLng> singleEdge = List();
        singleEdge.add(LatLng(latFrom, lngFrom));
        singleEdge.add(LatLng(latTo, lngTo));
        Polyline polyline = _createPolyLine(singleEdge, count.toString(), Colors.deepPurpleAccent);
        polylines.add(polyline);
        count++;
      }
    }
    return polylines;
  }
}