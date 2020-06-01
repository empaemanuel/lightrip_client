import 'dart:async';
import 'package:client/custom_color.dart';
import 'package:client/services/map_services.dart';
import 'package:permission_handler/permission_handler.dart' as PHandler;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/view/start_view.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:flutter/services.dart' show rootBundle;


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _mapController = Completer();
  MapServices mapServices = MapServices();

  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();

  //Used to seperate the two widgets.
  final fromID = 'from';
  final toID = 'to';

  //Start position when opening the map
  final LatLng _stockholmCenter = LatLng(59.329428,18.068803);

  String _mapStyle;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  Widget _googleMap(){
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(_mapStyle);
        _mapController.complete(controller);},
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: _markers,
      polylines: _polylines,
      initialCameraPosition: CameraPosition(
        target: _stockholmCenter,
        zoom: 11.0,
      ),
    );
  }
  ///generates route and draws it onto the map
  void _generateRoute() async{
      Future<Polyline> polylineFuture = mapServices.getPolyline();
      //_moveCameraToMidPoint();
      Polyline polyline = await polylineFuture;
      setState(() {
        _polylines.add(polyline);
      });
  }

  ///Adds a marker/pin to the map at the given location.
  void _addPinToMap(LatLng location, String id) {
    if(id == fromID){
      mapServices.setLocation_From(location);
    } else if( id == toID){
      mapServices.setLocation_To(location);
    } else {
      throw Exception('Id not found!');
    }
    setState(() {
      _markers = mapServices.getMarkers();
    });
  }

// FAKE FOR TESTS ONLY
//  void _generateRoute() async{
//    Future<List<Polyline>> futurePoints = mapServices.getMockAll();
//    List<Polyline> polylines = await futurePoints;
//    setState(() {
//      _polylines.addAll(polylines);
//    });
//  }

  void _moveCameraToMidPoint() async{
    final GoogleMapController controller = await _mapController.future;
    LatLng midPoint = mapServices.getMidPoint();
    LatLngBounds bounds = mapServices.getMidPointBounds();

    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: midPoint, zoom: 16.0)));
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }


//    setState(() {
//      _controller = controller;
//      _controller.setMapStyle(_mapStyle);
//      polyline.add(Polyline(
//        //add the blue swiggly lines to a set of <Polyline>
//        polylineId: PolylineId('route1'),
//        visible: true,
//        points: routeCoordsList, //takes a list of <LatLng>
//        width: 4,
//        color: Colors.blue,
//        startCap: Cap.roundCap,
//        endCap: Cap.buttCap,
//      ));


  ///Definition of the search text-field widget.
  Widget _googleSearchField(String placeholder, String id) {
    return SearchMapPlaceWidget(
      darkMode: true,
      placeholder: placeholder,
      apiKey: 'AIzaSyAKXJqJ6wqHVs2x18yuoSpbA0iHj8v6_XE',
      language: 'sv',
      location: _stockholmCenter,
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
                              color: Colors.white,
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
                            _googleSearchField('Search From', fromID),
                            SizedBox(height: 5),
                            _googleSearchField('Search To', toID),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        child: IconButton(
                          icon: Icon(Icons.call_split, color: Colors.white,),
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
