import 'package:flutter/material.dart';
import 'package:grocery_app_admin/utils/firebase_messaging_service.dart';
import 'package:grocery_app_admin/views/account_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessagingService().setupFirebaseMessaging();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AccountScreen()
    );
  }
}

