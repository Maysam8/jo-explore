import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduationproject/view/functionality/payment_screen.dart';
import 'package:graduationproject/view/widget/custom_button.dart';
import 'package:intl/intl.dart';

class EventsDetails extends StatefulWidget {
  final String eventId;

  const EventsDetails({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventsDetails> createState() => _EventsDetailsState();
}

class _EventsDetailsState extends State<EventsDetails> {
  TextEditingController attendees = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();

  List<int> numberOfAttendees = List.generate(10, (index) => index + 1);
  double? height;
  double? width;
  int selectedAttendees = 1;
  late Future<DocumentSnapshot<Map<String, dynamic>>> eventFuture;

  @override
  void initState() {
    super.initState();
    eventFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: eventFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              var eventData = snapshot.data!.data()!;
              String eventName = eventData['name'];
              String eventDescription = eventData['description'];
              String eventPrice = eventData['price'];
              String eventImageURL = eventData['image'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    eventImageURL,
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                  Container(
                      width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            eventName,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' price:$eventPrice JD',
                            style:
                                TextStyle(fontSize: 18, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      eventDescription,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poly',
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Attendees Quantity",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 2),
                            ListTile(
                              title: TextFormField(
                                controller: attendees,
                                decoration: InputDecoration(
                                  hintText: "Select attendees",
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                ),
                              ),
                              trailing: DropdownButton(
                                value: selectedAttendees,
                                hint: Text("Select"),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedAttendees = newValue!;
                                    attendees.text = newValue.toString();
                                  });
                                },
                                items: numberOfAttendees.map((attendee) {
                                  return DropdownMenuItem(
                                    value: attendee,
                                    child: Text(attendee.toString()),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            ListTile(
                              title: TextFormField(
                                controller: date,
                                decoration: InputDecoration(
                                  hintText: "02/15/2024",
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  ).then((pickedDate) {
                                    if (pickedDate != null) {
                                      setState(() {
                                        date.text = DateFormat('MM/dd/yyyy')
                                            .format(pickedDate);
                                      });
                                    }
                                  });
                                },
                                icon: Icon(Icons.date_range),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            ListTile(
                              title: TextFormField(
                                controller: time,
                                decoration: InputDecoration(
                                  hintText: "9:30 AM",
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.access_time),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CustomButton(
                      text: " Start reservation",
                      onTap: () {
                        String attendeesValue = attendees.text;
                        String dateValue = date.text;
                        String timeValue = time.text;

                        FirebaseFirestore.instance
                            .collection('reservations')
                            .add({
                          'placeId': widget.eventId,
                          'attendees': attendeesValue,
                          'date': dateValue,
                          'time': timeValue,
                        }).then((value) {
                          print("Reservation added successfully!");
                        }).catchError((error) {
                          print("Failed to add reservation: $error");
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MySample(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
