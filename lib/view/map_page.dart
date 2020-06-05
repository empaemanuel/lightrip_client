import 'dart:async';
import 'package:client/custom_color.dart';
import 'package:client/services/map_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/view/start_view.dart';
import 'package:location/location.dart';
import 'package:sms/sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:client/services/permissions_services.dart';

///This class handles the map and it's buttons by using GoogleMap
///_generateRoute() is used to get the route route from server.
///services/map_services.dart handles logic.
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _mapController = Completer();
  MapServices mapServices = MapServices();

  //Collections of the markers and polylines shown on map.
  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();

  //Used to separate the two widgets.
  final fromID = 'from';
  final toID = 'to';

  //Start position when opening the map
  final LatLng _stockholmCenter = LatLng(59.329428, 18.068803);

  //Describes look of the map
  String _mapStyle;

  bool _isLocationGranted;

  @override
  void initState() {
    _isLocationGranted = PermissionServices.isLocationGranted();
    //Sets style of map
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    //Sets default states (colors) of light level buttons.
    colorLow = colorOff;
    colorMid = colorOff;
    colorHigh = colorOff;
    super.initState();
  }


  Widget _googleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(_mapStyle);
        _mapController.complete(controller);
      },
      myLocationEnabled: _isLocationGranted,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      padding: EdgeInsets.only(top: 100),
      markers: _markers,
      polylines: _polylines,
      initialCameraPosition: CameraPosition(
        target: _stockholmCenter,
        zoom: 11.0,
      ),
    );
  }

  bool _isLoading = false;

  _setProgressToLoading(){
    setState(() {
      _isLoading = true;
    });
  }

  _setProgressToDone(){
    setState(() {
      _isLoading = false;
    });
  }

  void _clearRoutes(){
    setState(() {
      colorLow = disableColor;
      colorMid = disableColor;
      colorHigh = disableColor;
      if(_polylines != null) _polylines.clear();
      _opacityButtons = 0.0;
      _polyLinesLow = Set();
      _polyLinesMid = Set();
      _polyLinesHigh = Set();
    });
  }

  ///generates route and draws it onto the map
  void _generateRoute() async {
    if (mapServices
        .getMarkers()
        .length < 2) return;
    _clearRoutes();
    //Future<Set<Polyline>> s = mapServices.getMockAll();
    Future<Set<Polyline>> futurePolyLinesLow = mapServices.getPolylines(10);
    Future<Set<Polyline>> futurePolyLinesMid = mapServices.getPolylines(7);
    Future<Set<Polyline>> futurePolyLinesHigh = mapServices.getPolylines(5);

    _moveCameraToMidPoint();
    _setProgressToLoading();

    _polyLinesLow = await futurePolyLinesLow;
    _polyLinesMid = await futurePolyLinesMid;
    _polyLinesHigh = await futurePolyLinesHigh;

    _setProgressToDone();
    _showLightLevelButtons();
  }

  void _generateAllRoutes() async{
    _setProgressToLoading();
    _polyLinesLow = await mapServices.getMockAll();

    _setProgressToDone();
    _showLightLevelButtons();
  }
  
  double _opacityButtons = 0.0;

  _launchCaller() async {
    if (await PermissionServices.isPhoneGrantedCheck()) {
      const url = "tel:112";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void _showLightLevelButtons() {
    setState(() {
      _opacityButtons = 1.0;
      if(_polyLinesLow == null) {
        _lowEnabled = false;
        colorLow = disableColor;
      } else {
        _lowEnabled = true;
        colorLow = colorOff;
      }
      if(_polyLinesMid == null) {
        _midEnabled = false;
        colorMid = disableColor;
      } else {
        _midEnabled = true;
        colorMid = colorOff;
      }
      if(_polyLinesHigh == null) {
        _highEnabled = false;
        colorHigh = disableColor;
      } else {
        _highEnabled = true;
        colorHigh = colorOff;
      }
    });
  }

  bool _lowEnabled, _midEnabled, _highEnabled;

  void sendSms() {
    SmsSender sender = new SmsSender();
    String number = "12343567";

    SmsMessage message = new SmsMessage(number, "Help, i\'m in danger!");

    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
      }
    });
    sender.sendSms(message);
  }

  Set<Polyline> _polyLinesLow, _polyLinesMid, _polyLinesHigh;

  ///Adds a marker/pin to the map at the given location.
  void _addPinToMap(LatLng location, String id) {
    if (id == fromID) {
      mapServices.setLocation_From(location);
    } else if (id == toID) {
      mapServices.setLocation_To(location);
    } else {
      throw Exception('Id not found!');
    }
    setState(() {
      _clearRoutes();
      _markers = mapServices.getMarkers();
    });
  }

  ///Moves camera to position between two nodes.
  void _moveCameraToMidPoint() async {
    final GoogleMapController controller = await _mapController.future;
    LatLng midPoint = mapServices.getMidPoint();
    LatLngBounds bounds = mapServices.getMidPointBounds();
    print('midpoint: $midPoint');
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: midPoint, zoom: 12.0)));
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

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
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: geolocation.coordinates, zoom: 16.0)));
        _addPinToMap(geolocation.coordinates, id);
      },
    );
  }

  ///Positions camera to current position and uses it as Pin on map
  void _currentLocation() async {
    if (await PermissionServices.isLocationGrantedCheck()) {
      setState(() {
        _isLocationGranted = true;
      });
      final GoogleMapController controller = await _mapController.future;
      LocationData currentLocation;
      var location = new Location();
      try {
        currentLocation = await location.getLocation();
      } on Exception {
        currentLocation = null;
      }

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 16.0,
        ),
      ));

      LocationData loc = await location.getLocation();
      LatLng current = LatLng(loc.latitude, loc.longitude);
      _addPinToMap(current, 'from');
      setState(() {
        _searchFromText = "My Location";
      });
    }
  }

  // Needed as reference for opening drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var _searchFromText = 'Search From';

  Color colorOff = Colors.blueGrey;
  Color colorOn = Colors.blue;
  Color colorLow, colorMid, colorHigh;
  Color disableColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            //Drawer menu
            drawer: Drawer(
              child: Container(
                color: new MaterialColor(0xFF191a1f, color),
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(
                      decoration: BoxDecoration(
                          color: new MaterialColor(0xFF191a1f, color)),
                      child: Text(
                        'User Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    //List tile that navigates to start view
                    ListTile(
                        title: Text(
                          'Sign out',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500),
                        ),
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return StartView();
                                }))),
                  ],
                ),
              ),
            ),
            body: Stack(
              alignment: Alignment.bottomRight,
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
                          //width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                _scaffoldKey.currentState.openDrawer(),
                          ),
                        ),
                        //Search Boxes
                        Container(
                          width: 280,
                          alignment: Alignment.topCenter,
                          child: _googleSearchField(_searchFromText, fromID),
                        ),
                        //Generate route button
                        Container(
                            width: 50,
                            child: IconButton(
                              icon: Icon(
                                Icons.call_split,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _generateRoute();
                                // to print all edges on map, use below.
                                //_generateAllRoutes();
                              },
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 50,
                          height: 50,
                        ),
                        Container(
                            width: 280,
                            alignment: Alignment.topCenter,
                            child: _googleSearchField('Search To', toID)),
                        Container(
                          width: 50,
                          child: IconButton(
                            icon: Icon(Icons.my_location),
                            color: Colors.white,
                            onPressed: _currentLocation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: _opacityButtons,
                    //opacity: 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: "low",
                          backgroundColor: colorLow,
                          child: Text(
                              'Low', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if(_lowEnabled) {
                              setState(() {
                                colorLow = colorOn;
                                colorMid = colorOff;
                                colorHigh = colorOff;
                                _polylines = _polyLinesLow;
                              });
                            }
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FloatingActionButton(
                          heroTag: "mid",
                          backgroundColor: colorMid,
                          child: Text(
                              'Mid', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if(_midEnabled){
                            setState(() {

                              colorLow = colorOff;
                              colorMid = colorOn;
                              colorHigh = colorOff;
                              _polylines = _polyLinesMid;
                            });
                            }
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FloatingActionButton(
                          heroTag: "high",
                          backgroundColor: colorHigh,
                          child: Text(
                              'High', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if(_highEnabled) {
                              setState(() {
                                colorLow = colorOff;
                                colorMid = colorOff;
                                colorHigh = colorOn;
                                _polylines = _polyLinesHigh;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.call,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () => _launchCaller(),
                    ),
                  ),
                ),
                  _isLoading ? Center(child: CircularProgressIndicator(value: null)): SizedBox()
              ],
            )));
  }
}

