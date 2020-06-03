import 'dart:async';
import 'package:client/custom_color.dart';
import 'package:client/services/map_services.dart';
import 'package:permission_handler/permission_handler.dart' as PHandler;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/view/start_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sms/sms.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  @override
  void initState() {
    super.initState();

    //Sets style of map
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    //Sets default states (colors) of light level buttons.
    colorLow = colorOn;
    colorMed = colorOff;
    colorHigh = colorOff;
  }

//  @override
//  void dispose(){
//    super.dispose();
//  }


  Widget _googleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(_mapStyle);
        _mapController.complete(controller);
      },
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
  void _generateRoute() async {
    //Future<Set<Polyline>> s = mapServices.getMockAll();
    Future<Set<Polyline>> sLow = mapServices.getPolylines(10);
    Future<Set<Polyline>> sMed = mapServices.getPolylines(7);
    Future<Set<Polyline>> sHigh = mapServices.getPolylines(5);
    _moveCameraToMidPoint();
    _ssLow = await sLow;
    _ssMed = await sMed;
    _ssHigh = await sHigh;
    setState(() {
      _polylines = _ssLow;
    });
  }

  void _showLowRoute() {
    setState(() {
      _polylines = _ssLow;
    });
  }

  void _showMediumRoute() {
    setState(() {
      _polylines = _ssMed;
    });
  }

  void _showHighRoute() {
    setState(() {
      _polylines = _ssHigh;
    });
  }

  Set<Polyline> _ssLow, _ssMed, _ssHigh;

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
      _polylines.clear();
      _opacityButtons = 0.0;
      _markers = mapServices.getMarkers();
    });
  }

  ///Moves camera to position between two nodes.
  void _moveCameraToMidPoint() async {
    final GoogleMapController controller = await _mapController.future;
    LatLng midPoint = mapServices.getMidPoint();
    LatLngBounds bounds = mapServices.getMidPointBounds();

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

  // Needed as reference for opening drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Color colorOff = Colors.blueGrey;
  Color colorOn = Colors.lightGreen;
  Color colorLow, colorMed, colorHigh;

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
                        onTap: () => Navigator.push(context, MaterialPageRoute(
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
                          width: 50,
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
                          width: 300,
                          //height: 250,
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
                              icon: Icon(
                                Icons.call_split,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _generateRoute();
                                setState(() {
                                  _opacityButtons = 1.0;
                                });
                              },
                            ))
                      ],
                    ),
                    //Emergency call button
//                    Container(
//                      padding: EdgeInsets.all(20),
//                      child: InkWell(
//                          splashColor: Colors.transparent,
//                          onTap: () {
//                            sendSms();
//                            launch('tel://112');
//                          },
//                          child: Image(
//                              image: AssetImage('assets/Icon_Emergency.png'))),
//                    )
                  ],
                ),
                //Flexible(flex: 1, fit: FlexFit.tight, child: Container()),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: _opacityButtons,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: 3,
                          backgroundColor: colorLow,
                          child:
                              Text('Low', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            _showLowRoute();
                            colorLow = colorOn;
                            colorMed = colorOff;
                            colorHigh = colorOff;
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        FloatingActionButton(
                            heroTag: 1,
                            backgroundColor: colorMed,
                            child: Text("Med"),
                            onPressed: () {
                              _showMediumRoute();
                              setState(() {
                                colorLow = colorOff;
                                colorMed = colorOn;
                                colorHigh = colorOff;
                              });
                            }),
                        SizedBox(
                          width: 5,
                        ),
                        FloatingActionButton(
                            heroTag: 2,
                            backgroundColor: colorHigh,
                            child: Text("High",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              _showHighRoute();
                              colorMed = colorOff;
                              colorLow = colorOff;
                              colorHigh = colorOn;
                            }),
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
                )
              ],
            )));
  }

  double _opacityButtons = 0.0;

  _launchCaller() async {
    const url = "tel:112";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

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
