import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'pages/login.dart';
import 'pages/reg.dart';
import 'pages/rider.dart';
import 'pages/driver.dart';
import 'pages/mainp.dart';
import 'providers/providers.dart'; // Import the providers file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const liveQueryUrl =
      'wss://parseapi.back4app.com'; // WebSocket URL for LiveQuery

  await Parse().initialize(
    '4y5h9UNCACGxi2QxYdAhToOmV9DARFNmphc27p7u', // Replace with Back4App App ID
    'https://parseapi.back4app.com', // Replace with Back4App Server URL
    clientKey:
        'x82KGUiYnE84ioGbqJzLA92CHiSoBFZaGrPcDc3r', // Replace with Back4App Client Key
    liveQueryUrl: liveQueryUrl, // Ensure this is set for LiveQuery

    autoSendSessionId: true,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/rider': (context) => RiderPage(),
        '/driver': (context) => DriverPage(),
      },
    );
  }
}
