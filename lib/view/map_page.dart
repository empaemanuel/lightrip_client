import 'dart:async';
import 'dart:convert';

import 'package:client/custom_color.dart';
import 'package:client/services/map_services.dart';
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
import 'package:search_map_place/search_map_place.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = Set();
  MapServices mapServices = MapServices();

  LatLng _vitabergCenter = LatLng(59.3121417,18.0911303);
  LatLng _stockholmCenter = LatLng(59.329428,18.068803);

  @override
  void initState() {
    super.initState();
  }

  LatLng _from, _to;
  void _addPinToMap(LatLng location, String id) {
    if (id == 'from') _from = location;
    if (id == 'to') _to = location;

    _markers.clear();

    Marker mFrom, mTo;

    if (_from != null) {
      mFrom = Marker(
        position: _from,
        markerId: MarkerId('fromPin'),
      );
    }

    if (_to != null) {
      mTo = Marker(
        position: _to,
        markerId: MarkerId('toPin'),
      );
    }

    setState(() {
      if(mFrom != null)_markers.add(mFrom);
      if(mTo != null)_markers.add(mTo);
    });

  }

  Widget _googleMap(){
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: _markers,
      initialCameraPosition: CameraPosition(
        target: _stockholmCenter,
        zoom: 11.0,
      ),
    );
  }

  void _generateRoute() async{
    final GoogleMapController controller = await _mapController.future;
    LatLng midPoint = mapServices.midPoint(_markers.elementAt(0).position, _markers.elementAt(1).position);
    LatLngBounds bounds = mapServices.getBounds(_markers.elementAt(0).position, _markers.elementAt(1).position);

    controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: midPoint, zoom: 16.0)));
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  Widget _googleSearchField(String placeholder, String id) {
    return SearchMapPlaceWidget(
      darkMode: true,
      placeholder: placeholder,
      apiKey: 'AIzaSyAKXJqJ6wqHVs2x18yuoSpbA0iHj8v6_XE',
      language: 'sv',
      location: _vitabergCenter,
      radius: 1000,
      onSelected: (Place place) async {
        final geolocation = await place.geolocation;
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: geolocation.coordinates,
                    zoom: 16.0)));
        _addPinToMap(geolocation.coordinates, id);
      },
    );
  }

  // Needed as reference for opening drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//        localizationsDelegates: const [
//          location_picker.S.delegate,
//          GlobalMaterialLocalizations.delegate,
//          GlobalWidgetsLocalizations.delegate,
//          GlobalCupertinoLocalizations.delegate,
//        ],
//        supportedLocales: const <Locale>[
//          Locale('sv', ''),
//          Locale('en', ''),
//          Locale('ar', ''),
//        ],
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
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
          body: Stack(
            children: <Widget>[
              _googleMap(),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Drawer button
                      Container(
                        width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Colors.black54,
                            ),
                            onPressed: () => _scaffoldKey.currentState.openDrawer(),
                          ),
                      ),
                      //Search Boxes
                      Container(
                        width: 300,
                        height: 250,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: <Widget>[
                            _googleSearchField('Search From', 'from'),
                            SizedBox(height: 5),
                            _googleSearchField('Search To', 'to'),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        child: IconButton(
                          icon: Icon(Icons.call_split),
                          onPressed: _generateRoute,
                        )
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}
