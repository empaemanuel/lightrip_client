import 'package:flutter/material.dart';
import 'package:client/view/start_view.dart';

//Entry point hands over control to the controller
void main() {
  runApp(StartApp());
}

class StartApp extends StatelessWidget {

  //If running localhost, change server variable below to your machine's
  //ip-address. Example: 'http://192.168.33.154:8080'
//  static String server = 'your ip adress and port goes here';

  //if you want to use the external server, use server below.
  //Route generation might not work as expected due to timeouts caused by long
  // loading times.
    static String server = 'https://lightrip-server.herokuapp.com';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StartView(),
    );
  }
}
