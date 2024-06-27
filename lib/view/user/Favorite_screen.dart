import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatelessWidget {
  final String userId;

  const FavoritesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No favorites found.', style: TextStyle(fontSize: 18)));
          }
          List<dynamic>? favoritePlaces = snapshot.data!.get('placeNames');
          List<dynamic>? favoritePlaceImages = snapshot.data!.get('placeImages');
          if (favoritePlaces == null || favoritePlaceImages == null || favoritePlaces.isEmpty || favoritePlaceImages.isEmpty) {
            return Center(child: Text('No favorites found.', style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            itemCount: favoritePlaces.length,
            itemBuilder: (BuildContext context, int index) {
              if (index >= favoritePlaces.length || index >= favoritePlaceImages.length) {
                return SizedBox();
              }
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      favoritePlaceImages[index],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    favoritePlaces[index],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
