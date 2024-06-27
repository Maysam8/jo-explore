import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:graduationproject/view/functionality/chat_screen.dart';
import 'package:graduationproject/view/events/events_screen.dart';
import 'package:graduationproject/view/places/Details_screen.dart';
import 'package:graduationproject/view/places/destination.dart';
import 'package:graduationproject/view/user/user.dart';
import 'package:graduationproject/view/widget/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required int selectedIndex}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double? height;
  double? width;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Destinations(selectedIndex: 1)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Events()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: GNav(
        backgroundColor: AppColors.maincolor,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        gap: 8,
        tabBackgroundColor: Colors.grey.shade500,
        activeColor: Colors.white,
        color: Colors.white,
        iconSize: 24,
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
        tabs: [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.location_on,
            text: 'Destinations',
          ),
          GButton(
            icon: Icons.event,
            text: 'Events',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    "images/mainscreen.webp",
                    width: width,
                    height: height! * 0.5,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 15,
                    left: 10,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Let’s plan your next vacation !! ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poly',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 15,
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.account_circle),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Popular destinations",
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: width! * 0.4,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('destinations')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No data available'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot destinationDocument =
                            snapshot.data!.docs[index];
                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection(
                                  'destinations/${destinationDocument.id}/places')
                              .where('popular', isEqualTo: true)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> placesSnapshot) {
                            if (placesSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (placesSnapshot.hasError) {
                              return Text('Error: ${placesSnapshot.error}');
                            }
                            return Flexible(
                              child: Row(
                                children: placesSnapshot.data!.docs
                                    .map((DocumentSnapshot placeDocument) {
                                  Map<String, dynamic> data = placeDocument
                                      .data() as Map<String, dynamic>;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailsScreen(
                                            governorateId:
                                                destinationDocument.id,
                                            placeId: placeDocument.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  spreadRadius: 1.0,
                                                  offset: Offset(2.0, 2.0),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                data['image'] ?? '',
                                                height: width! * 0.30,
                                                width: width! * 0.3,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.chat),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupChatScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
