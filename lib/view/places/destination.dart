import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:graduationproject/view/events/events_screen.dart';
import 'package:graduationproject/view/main_screen.dart';
import 'package:graduationproject/view/places/places.dart';
import 'package:graduationproject/view/functionality/weather_screen.dart';
import 'package:graduationproject/view/widget/colors.dart';

class Destinations extends StatefulWidget {
  const Destinations({Key? key, required this.selectedIndex}) : super(key: key);

  final int selectedIndex;

  @override
  State<Destinations> createState() => _DestinationsState();
}

class _DestinationsState extends State<Destinations> {
  List<QueryDocumentSnapshot> list = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("destinations").get();
    setState(() {
      list = querySnapshot.docs;
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0)),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Events()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GNav(
        backgroundColor: AppColors.maincolor,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        gap: 8,
        tabBackgroundColor: Colors.grey.shade500,
        activeColor: Colors.white,
        color: Colors.white,
        iconSize: 24,
        selectedIndex: widget.selectedIndex,
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
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Destination",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                "Select the governorate you'd like to explore!",
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 13),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                Place(governorateId: list[index].id),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              list[index]['image'],
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "${list[index]['name']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(
                                  Icons.cloud,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => WeatherScreen(
                                        governorateName: list[index]['name'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: list.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}