import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduationproject/view/places/Details_screen.dart';
import 'package:graduationproject/view/user/Favorite_screen.dart';
import 'package:graduationproject/view/user/review.dart';
import 'package:graduationproject/view/widget/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Place extends StatefulWidget {
  final String governorateId;

  const Place({Key? key, required this.governorateId}) : super(key: key);

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<DocumentSnapshot>> _hotelsFuture;

  List<String> favoritePlaces = [];
  List<String> favoritePlaceImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _hotelsFuture = fetchHotels();
  }

  Future<List<DocumentSnapshot>> fetchHotels() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.governorateId)
        .collection('hotels')
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(userId: 'user_id'),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Places'),
            Tab(text: 'Hotels'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 6),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('destinations')
                      .doc(widget.governorateId)
                      .collection('places')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var doc = snapshot.data!.docs[index];
                        String placeName = doc['place'];
                        int stars = doc['stars'];
                        String? price = doc['price'];

                        bool isFavorite = favoritePlaces.contains(placeName);
                        return GestureDetector(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          doc['image'],
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                      Positioned(
                                          top: 8,
                                          left: 8,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isFavorite) {
                                                  favoritePlaces
                                                      .remove(placeName);
                                                  favoritePlaceImages
                                                      .remove(doc['image']);
                                                  removeFromFavorites(
                                                      placeName, doc['image']);
                                                } else {
                                                  favoritePlaces.add(placeName);
                                                  favoritePlaceImages
                                                      .add(doc['image']);
                                                  addToFavorites(
                                                      placeName, doc['image']);
                                                }
                                              });
                                            },
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.white
                                                  : null,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              placeName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          SizedBox(width: 8),
                                          Row(
                                            children: List.generate(
                                              stars,
                                              (index) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReviewsPage(
                                                    placeName: placeName,
                                                    placeId: doc.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 0,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Reviews",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 0,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsScreen(
                                                        governorateId: widget
                                                            .governorateId,
                                                        placeId: doc.id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Details",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Flexible(
                                            child: Text(
                                              price != '0' ? '$price JD' : '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.maincolor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Hotels Tab
          FutureBuilder<List<DocumentSnapshot>>(
            future: _hotelsFuture,
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.data!.isEmpty) {
                return Center(child: Text('No hotels available.'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data![index];
                  String hotelName = doc['name'];
                  String hotelPhone = doc['phone'];
                  String hotelImage = doc['image'];
                  int stars = doc['stars'];

                  return GestureDetector(
                   
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(hotelImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotelName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Phone: $hotelPhone',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 8),
                                    Row(
                                      children: List.generate(
                                        stars,
                                        (index) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        try {
                                          var snapshot = await FirebaseFirestore
                                              .instance
                                              .collection('destinations')
                                              .doc(widget.governorateId)
                                              .collection('hotels')
                                              .get();

                                          if (snapshot.docs.isNotEmpty) {
                                            var doc = snapshot.docs.first;
                                            var latitude = doc['Latitude'];
                                            var longitude = doc['Longitude'];

                                            var url =
                                                'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          } else {
                                            throw 'Place data not found';
                                          }
                                        } catch (e) {
                                          print('Error: $e');
                                          // يمكنك هنا عرض رسالة للمستخدم بحدوث خطأ
                                        }
                                      },
                                      icon: Icon(
                                        Icons.location_on,
                                        color: AppColors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void addToFavorites(String placeName, String imageUrl) {
    FirebaseFirestore.instance.collection('favorites').doc('user_id').update({
      'placeNames': FieldValue.arrayUnion([placeName]),
      'placeImages': FieldValue.arrayUnion([imageUrl])
    }).then((_) {
      setState(() {
        favoritePlaces.add(placeName);
        favoritePlaceImages.add(imageUrl);
      });
    }).catchError((error) {
      print("Failed to add place to favorites: $error");
    });
  }

  void removeFromFavorites(String placeName, String imageUrl) {
    FirebaseFirestore.instance.collection('favorites').doc('user_id').update({
      'placeNames': FieldValue.arrayRemove([placeName]),
      'placeImages': FieldValue.arrayRemove([imageUrl])
    }).then((_) {
      setState(() {
        favoritePlaces.remove(placeName);
        favoritePlaceImages.remove(imageUrl);
      });
    }).catchError((error) {
      print("Failed to remove place from favorites: $error");
    });
  }
}
