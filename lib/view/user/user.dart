import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduationproject/view/main_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool notificationPressed = false;
  String? username; 
  String? email; 

  @override
  void initState() {
    super.initState();
    _fetchUserData(); 
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = userData['name'];
        email = user.email; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.1;

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0,)),
                  );
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.black,
              ),
              Text(
                "My profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username ?? "Username",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Others",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _buildListItem(
            Icons.email,
               email ?? "Email",
            Icons.arrow_forward_ios,
            iconColor: Colors.blue,
          ),
        
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                notificationPressed = !notificationPressed;
              });
            },
            child: _buildListItem(
              Icons.notifications,
              "Notification",
              Icons.power_settings_new,
              iconColor: notificationPressed ? Colors.green : Colors.orange,
            ),
          ),
         
          SizedBox(height: 10),
          _buildListItem(
            Icons.exit_to_app,
            "Sign Out",
            Icons.arrow_forward_ios,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData leftIcon, String text, IconData rightIcon,
      {Color iconColor = Colors.grey}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.3),
            ),
            child: Icon(leftIcon, color: iconColor),
          ),
          SizedBox(width: 10),
          Text(text),
          Spacer(),
          IconButton( 
            icon: Icon(rightIcon),
            onPressed: () {
              if (text == "Sign Out") { 
                _signOut(); 
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
