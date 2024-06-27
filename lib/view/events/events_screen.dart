import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduationproject/view/events/events_details.dart';
import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  late Stream<QuerySnapshot> _eventsStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = FirebaseFirestore.instance.collection('events').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: StreamBuilder(
        stream: _eventsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return EventItem(
                image: data['image'],
                name: data['name'],
                date: data['date'],
                type: data['type'], 
                eventId:data ['eventId'],
              );
            },
          );
        },
      ),
    );
  }
}

class EventItem extends StatelessWidget {
   final String eventId;
  final String image;
  final String name;
  final String date;
  final String type;

  const EventItem({
    required this.eventId,
    required this.image,
    required this.name,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
   DateTime now = DateTime.now();
    DateTime eventDate = DateFormat('dd MM yyyy').parse(date); 
    Duration difference = eventDate.difference(now);
    int daysDifference = difference.inDays;


    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Date: $date',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Divider(),
                Text(
                  'Type: $type',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Days until event: $daysDifference',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: EdgeInsets.only(right: 20, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsDetails(eventId: eventId,), // تمرير eventId إلى EventsDetails
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1B2E52)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text('Details'),
            ),
          ),
        ],
      ),
    );
  }
}

