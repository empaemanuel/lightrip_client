import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/main.dart';

void main(){
    testWidgets('app builds test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(StartApp());
      expect(true, true);
    });
}