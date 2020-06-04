import 'package:client/view/sign_in_vjew.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/view/sign_up_view.dart';
import 'package:client/widgets/navigationButton_widget.dart';
import 'package:client/view/map_page.dart';
import 'package:client/custom_color.dart';
import 'package:client/log_in.dart';
import 'package:permission_handler/permission_handler.dart';

class StartView extends StatefulWidget {
  @override
  _StartViewState createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  void _askPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
    ].request();

//    var permissions = await PHandler.Permission.location
//        .request(); //ask for permission to use location
//    if (permissions == PHandler.PermissionStatus.granted) { //if its granted do this
//
//    }
  }

  @override
  void initState() {
    _askPermission();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: new MaterialColor(0xFF191a1f, color),
        body:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Application logo
              Container(
                  height: 250,
                  width: 250,
                  child: Image(
                      image: AssetImage('assets/Lightrip_Logo_no_bg.png'))),
              // Welcome text
              Container(
                  child: Text(
                'Welcome',
                style: TextStyle(
                    fontSize: 35.0,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700),
              )),
              Column(
                children: <Widget>[
                  //Facebook button
                  ButtonTheme(
                    minWidth: 250,
                    height: 40,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: new MaterialColor(0xFF3c5899, color),
                      child: Text(
                        'Sign in with Facebook',
                        style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500),
                      ),
                      onPressed: () {
                        signInUsingFacebook(context);
                      },
                    ),
                  ),
                  //Email button
                  ButtonTheme(
                    minWidth: 250,
                    height: 40,
                    child: NavigationButtonWidget(
                      color: new MaterialColor(0xFFFFFFFF, color),
                      title: Text('Sign in with Email',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                      navigateTo: LogInView(),
                    ),
                  ),
                ],
              ),
              //Row with clickable text that navigates to sign up page
              Row(children: <Widget>[
                Text('Don\'t have an account? ',
                    style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400)),
                InkWell(
                    child: Text('Sign up',
                        style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: new MaterialColor(0xFFE5305A, color),
                            decoration: TextDecoration.underline)),
                    onTap: () {
                      signUpPage(context);
                    })
              ])
            ],
          )
        ]));
  }

  //Navigates to sign up page
  void signUpPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return SignUpView();
    }));
  }
}
