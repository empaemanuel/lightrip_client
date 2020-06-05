// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/services/map_services.dart';

void main() {
  MapServices mapServices = MapServices();
  mapServices.setLocation_To(new LatLng(5.500278,5.499444));
  mapServices.setLocation_From(new LatLng(48.88554,50.43754));

  group('Midpoint Calculations', () {
    test('Midpoint matches calculator values', () {
      expect(mapServices.getMidPoint(), new LatLng(28.986661425347307, 23.136926593206994));
    });

    test("Midpoint bounds calculation is correct", () {
      expect(mapServices.getMidPointBounds(), new LatLngBounds(southwest : new LatLng(5.500278, 5.499444000000011), northeast: new LatLng(48.88554, 50.43754000000001)));
    });
  });
}
