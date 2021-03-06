import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/view/map_page.dart';
import 'package:client/view/start_view.dart';

import 'package:client/custom_color.dart';
import 'package:client/view/sign_up_view.dart';

class LogInView extends StatefulWidget {
  @override
  _LogInViewState createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController txt = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: new MaterialColor(0xFF191a1f, color),
        body:
            //Fixes bottom pixel overflow
            SingleChildScrollView(
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              //Aplication logo
                              Container(
                                  height: 250,
                                  width: 250,
                                  child: Image(
                                      image: AssetImage(
                                          'assets/Lightrip_Logo_no_bg.png'))),
                              //Sign in text
                              Container(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                        fontSize: 35.0,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700),
                                  )),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  //Email textfield
                                  Container(
                                      width: 250,
                                      height: 40,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black),
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500),
                                          hintText: "E-mail",
                                        ),
                                      )),
                                  //Password textfield
                                  Container(
                                      padding: EdgeInsets.only(top: 10),
                                      width: 250,
                                      height: 50,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black),
                                        controller: passwordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500),
                                          hintText: "Password",
                                        ),
                                      )),
                                  //Sign in button
                                  Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: ButtonTheme(
                                          height: 40,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18.0)),
                                            color: new MaterialColor(
                                                0xFFE5305A, color),
                                            child: Text('Sign in',
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            onPressed: () {
                                              signInWithEmailPassword(context);
                                            },
                                          ))),
                                  //Text for displaying login error messages
                                  Container(
                                      width: 250,
                                      height: 20,
                                      color: Colors.transparent,
                                      child: TextField(
                                          decoration: new InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: 15,
                                                  bottom: 11,
                                                  top: 11,
                                                  right: 15)),
                                          textAlign: TextAlign.center,
                                          controller: txt,
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500))),
                                ],
                              ),
                              //Row with clickable text that navigates to sign up page
                              Row(children: <Widget>[
                                Text('Don\'t have an account? '),
                                InkWell(
                                  child: Text('Sign up',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          color: new MaterialColor(
                                              0xFFE5305A, color),
                                          decoration:
                                              TextDecoration.underline)),
                                  onTap: () {
                                    signUpPage(context);
                                  },
                                )
                              ])
                            ],
                          )
                        ]))));
  }

  //Method for logging in with email and password
  //Displays error message if unsuccessful and navigates to map page if successful
  void signInWithEmailPassword(BuildContext context) async {
    FirebaseUser user;
    try {
      user = (await mAuth.signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text))
          .user;
    } catch (e) {
      txt.text = "Invalid username or password";
    } finally {
      if (user != null) {
        print("User is signed in");
        mapPage(context);
      }
    }
  }
}

//Navigates to start page
void registerPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return StartView();
  }));
}

//Navigates to map page
void mapPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return MapPage();
  }));
}

//Navigates to sign up page
void signUpPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return SignUpView();
  }));
}
