import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:graduationproject/view/functionality/payment_screen.dart';
import 'package:graduationproject/view/widget/colors.dart';
import 'package:graduationproject/view/widget/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final String placeId;
  final String governorateId;

  const DetailsScreen({
    Key? key,
    required this.placeId,
    required this.governorateId,
  }) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  TextEditingController attendees = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();

  List<int> numberOfAttendees = List.generate(10, (index) => index + 1);

  int selectedAttendees = 1;
  double price = 0;
  double? height;
  double? width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Stack(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('destinations')
                        .doc(widget.governorateId)
                        .collection('places')
                        .doc(widget.placeId)
                        .collection('details')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No data available');
                      }
                      var doc = snapshot.data!.docs.first;
                      var description = doc['description'];
                      var imageUrl = doc['image'];
                      return Column(
                        children: [
                          imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                          SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Overview",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poly',
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        try {
                                          var snapshot = await FirebaseFirestore
                                              .instance
                                              .collection('destinations')
                                              .doc(widget.governorateId)
                                              .collection('places')
                                              .doc(widget.placeId)
                                              .collection('details')
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
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 10),
                            child: Text(
                              description,
                              style: TextStyle(
                                fontFamily: 'Poly',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    left: 10,
                    top: 20,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
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
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('destinations')
                          .doc(widget.governorateId)
                          .collection('places')
                          .doc(widget.placeId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text('No data available');
                        }
                        var placeData = snapshot.data!;
                        var price =
                            placeData['price']; // الحصول على السعر من البيانات

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ${(double.parse(price) * selectedAttendees).toStringAsFixed(2)}', // عرض السعر الجديد في الواجهة
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20),
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
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
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
                                updatePrice(
                                    newValue); // استدعاء دالة تحديث السعر هنا
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
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
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
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
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
              CustomButton(
                text: "Start reservation",
                onTap: () {
                  double updatedPrice = price * int.parse(attendees.text);

                  String attendeesValue = attendees.text;
                  String dateValue = date.text;
                  String timeValue = time.text;

                  FirebaseFirestore.instance.collection('reservations').add({
                    'placeId': widget.placeId,
                    'attendees': attendeesValue,
                    'date': dateValue,
                    'time': timeValue,
                    'price': updatedPrice.toString(),
                  }).then((value) {
                    print("Reservation added successfully!");
                  }).catchError((error) {
                    print("Failed to add reservation: $error");
                  });

               
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updatePrice(int attendeesCount) {
    FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.governorateId)
        .collection('places')
        .doc(widget.placeId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        var placeData = snapshot.data();
        var price = double.parse(placeData?['price']);

        var updatedPrice = price * attendeesCount;

        setState(() {
          selectedAttendees = attendeesCount;
          this.price = updatedPrice; // تحديث قيمة price
        });
      }
    });
  }
}
