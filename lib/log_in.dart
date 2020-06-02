import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:client/view/map_page.dart';

final FirebaseAuth mAuth = FirebaseAuth.instance;

final GoogleSignIn googleSignIn = new GoogleSignIn();
void signInUsingGoogle(BuildContext context) async {
  FirebaseUser user;
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken);
  try {
    user = (await mAuth.signInWithCredential(credential)).user;
  } catch (e) {
    print(e.toString());
  } finally {
    if (user != null) {
      print("Signed in with Google");
      mapPage(context);
    }
  }
}

//Method used for authenticating users through facebook
//Navigates to map page if successful
void signInUsingFacebook(BuildContext context) async {
  FirebaseUser user;
  final FacebookLogin facebookLogin = new FacebookLogin();
  facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
  final FacebookLoginResult facebookLoginResult =
      await facebookLogin.logIn(['email', 'public_profile']);
  if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
    FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
    final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: facebookAccessToken.token);
    try {
      user = (await mAuth.signInWithCredential(credential)).user;
    } catch (e) {
      print(e.toString());
    } finally {
      if (user != null) {
        print("Signed in with Google");
        mapPage(context);
      }
    }
  }
}

void mapPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return MapPage();
  }));
}
