import 'dart:convert';

import 'package:client/custom_color.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:location/location.dart' as Location;
import 'package:permission_handler/permission_handler.dart' as PHandler;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/view/start_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
    as location_picker;
import 'package:client/custom_color.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Polyline> polyline =
      {}; //set containing the polylines to be drawn on map
  GoogleMapController _controller; //controller for the map
  List routeList; //initial list to handle first objects being sent from server
  List<LatLng> routeCoordsList =
      new List<LatLng>(); //second list to handle the transformed nodes
  int distance; //distance of route
  String user; //user
  Location.Location location; //location wrapper
  Location.LocationData
      currentLocation; //save what is considered "current location"
  Set<Marker> _markers =
      Set<Marker>(); //set that holds all markers to be placed on map
  LocationResult _pickedLocation; //save result of chosen location
  String _mapStyle;

  @override
  void initState() {
    //called once in the beginning
    super.initState();

    location = new Location.Location();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    getData(); //get data needed for lines
  }

  void getData() async {
    var permissions = await PHandler.Permission.location
        .request(); //ask for permission to use location

    if (permissions == PHandler.PermissionStatus.granted) {
      //if its granted do this
      // Either the permission was already granted before or the user just granted it.

      location.onLocationChanged.listen((Location.LocationData cLoc) {
        //this func is called every time location updates
        currentLocation = cLoc; //update location
        updatePinOnMap(); //update marker
        print(currentLocation); //for debug purpose
      }); //TODO: remove listener when not on map page

      final response = await http.get(
          'https://group2-75.pvt.dsv.su.se/server-0.0.1-SNAPSHOT/route/demo'); //ask server for data

      if (response.statusCode == 200) {
        //if request succeeded
        // If the server did return a 200 OK response,
        // then parse the JSON.
        Map dataMap = json.decode(response
            .body); //turn response into a readable map      ---      could probably simplify this part slightly
        routeList = dataMap[
            'route']; //save the list from the map to a separate list                                            |
        distance = dataMap[
            'distance']; //save the distance                                                                        |
        user = dataMap[
            'user']; //save the user                                                                            |
        //                                                                                         |
        for (dynamic coords in routeList) {
          //iterate through the list of nodes, nodes are saved as map objects        |
          LatLng
              lineCoords = //save the lat and long values as a LatLng object                          |
              new LatLng(
                  coords['latitude'],
                  coords[
                      'longitude']); //                                                                         |
          routeCoordsList.add(
              lineCoords); //add the LatLng obj to a new list                                         |
        }

        //dataMap['route']
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load album');
      }
    }
  }

  void updatePinOnMap() {
    setState(() {
      _markers
          .removeWhere((m) => m.markerId.value == 'User'); //remove old marker
      _markers.add(Marker(
          //add new one with updated location
          markerId: MarkerId('User'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          onTap: () {
            //do stuff
          }));
    });
  }

  Widget _googleMap(BuildContext context) {
    //create the google map object
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition:
              CameraPosition(target: LatLng(59.3121417, 18.0911303), zoom: 18),
          onMapCreated: onMapCreated, //call onMapCreated func when created
          polylines:
              polyline, //add the swigglies put in the set polyline in func above to the map
          markers: _markers,
        ));
  }

  void onMapCreated(GoogleMapController controller) async {
    //called after the map is created
    currentLocation = await location.getLocation();

    setState(() {
      _controller = controller;
      _controller.setMapStyle(_mapStyle);
      polyline.add(Polyline(
        //add the blue swiggly lines to a set of <Polyline>
        polylineId: PolylineId('route1'),
        visible: true,
        points: routeCoordsList, //takes a list of <LatLng>
        width: 4,
        color: Colors.blue,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap,
      ));

      _markers.add(Marker(
          markerId: MarkerId('User'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          onTap: () {
            //do stuff
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          location_picker.S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[
          Locale('sv', ''),
          Locale('en', ''),
          Locale('ar', ''),
        ],
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: new IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Container(
                width: 250,
                height: 40,
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0)),
                    hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                    hintText: "Where to?",
                  ),
                )),
            /*
            actions: <Widget>[
              IconButton(
                  //this is the settings button in the top right
                  icon: Icon(Icons.settings),
                  tooltip: 'Fetch data',
                  onPressed: () {
                    getData(); //calls getData again(for testing purpose atm if user declines to share location)
                  })
            ],
            */
          ),
          drawer: Drawer(
              child: Container(
            color: new MaterialColor(0xFF191a1f, color),
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                    decoration: BoxDecoration(
                        color: new MaterialColor(0xFF191a1f, color)),
                    child: Text('User Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700))),
                ListTile(
                    title: Text('Saved routes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500))),
                ListTile(
                    title: Text('Messages',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500))),
                ListTile(
                    title: Text('Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                ListTile(
                    title: Text('Support',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500))),
                ListTile(
                    title: Text('Sign out',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return StartView();
                        }))),
              ],
            ),
          )),
          body: Center(
            child: Center(
                child: Stack(
              children: <Widget>[
                _googleMap(
                    context) //this is where we add our map object making it visible in the interface
              ],
            )),
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: new MaterialColor(0xFFE5305A, color),
              child: Icon(
                Icons.flag,
              ),
              onPressed: () async {
                _pickedLocation = await showLocationPicker(
                  context,
                  'AIzaSyAKXJqJ6wqHVs2x18yuoSpbA0iHj8v6_XE',
                  initialCenter: LatLng(31.1975844, 29.9598339),
                  myLocationButtonEnabled: true,
                  layersButtonEnabled: true,
                );
              }),
        ));
  }
}
