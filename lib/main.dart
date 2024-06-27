import 'package:flutter/material.dart';
import 'package:graduationproject/view/functionality/join_chat.dart';
import 'package:graduationproject/view/places/Details_screen.dart';
import 'package:graduationproject/view/user/Favorite_screen.dart';
import 'package:graduationproject/view/places/destination.dart';
import 'package:graduationproject/view/events/events_screen.dart';
import 'package:graduationproject/view/user/login_screen.dart';
import 'package:graduationproject/view/main_screen.dart';
import 'package:graduationproject/view/functionality/payment_screen.dart';
import 'package:graduationproject/view/places/places.dart';
import 'package:graduationproject/view/user/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:graduationproject/view/splach_screen.dart';
import 'package:graduationproject/view/user/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDtmUU-zBKZJZtMfDCQ0LdQ_kOpW8Zlq_M",
          appId: "1:770798797488:android:228ac2a1df1548a87b3175",
          messagingSenderId: "770798797488",
          projectId: "joexplore-d869c"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:JoinChat(),
      routes: {
        "signup": (context) => SignupScreen(),
        "Login": (context) => LoginScreen(),
        "Homepage": (context) => MainScreen(
              selectedIndex: 0,
            )
      },
    );
  }
}
