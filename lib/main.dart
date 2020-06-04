import 'package:flutter/material.dart';
import 'package:client/view/start_view.dart';

//Entry point hands over control to the controller
void main() {
  runApp(StartApp());
}

class StartApp extends StatelessWidget {

  //If running localhost, change server variable below to your machine's
  //ip-address. Example: 'http://192.168.33.154:8080'

  static String server = 'http://192.168.31.153:8080';
  //static String server = 'https://lightrip-server.herokuapp.com';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StartView(),
    );
  }
}
