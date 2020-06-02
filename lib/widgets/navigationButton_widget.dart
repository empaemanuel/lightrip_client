import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Button used for navigation
class NavigationButtonWidget extends StatelessWidget {
  NavigationButtonWidget({this.title, this.navigateTo, this.color});
  final Widget title;
  final Widget navigateTo;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: color,
        child: title,
        onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return navigateTo;
            })));
  }
}
