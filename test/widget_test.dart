import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sstp_vpn/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    expect(find.text('SSTP VPN'), findsOneWidget);
  });
}
