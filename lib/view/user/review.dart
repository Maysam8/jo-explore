import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ReviewsPage extends StatefulWidget {
  final String placeName;
  final String placeId;

  const ReviewsPage({Key? key, required this.placeName, required this.placeId})
      : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.placeName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('placeId', isEqualTo: widget.placeId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No reviews available.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(doc['userName']),
                      subtitle: Text(doc['review']),
                    );
                  },
                );
              },
            ),
          ),
  

  

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      labelText: 'Add your review...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    String reviewText = _reviewController.text.trim();
                    if (reviewText.isNotEmpty) {
                      _addReview(reviewText);
                      _reviewController.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                  label: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addReview(String reviewText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final username = userData['name'];
      FirebaseFirestore.instance.collection('reviews').add({
        'placeId': widget.placeId,
        'placeName': widget.placeName,
        'userId': user.uid,
        'userName': username,
        'review': reviewText,
        'timestamp': DateTime.now(),
      });
    }
  }
}
