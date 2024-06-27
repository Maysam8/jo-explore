import 'package:flutter/material.dart';
import 'package:graduationproject/view/functionality/chat_screen.dart';
import 'package:graduationproject/view/widget/custom_button.dart';

class JoinChat extends StatefulWidget {
  const JoinChat({super.key});

  @override
  State<JoinChat> createState() => _JoinChatState();
}

class _JoinChatState extends State<JoinChat> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(
            10), 
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: width * 0.3, 
                  child: Image.asset("images/chat1.png"),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Do you have multiple inquiries?",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10), 
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Would you like to share your experiences with others?",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                SizedBox(
                  width: width * 0.3, 
                  child: Image.asset("images/chat2.png"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: width * 0.3, 
                  child: Image.asset("images/chat3.png"),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "you can Joina communication group",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            CustomButton(
              onTap: () {   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatScreen(),
                    ),
                  );},
              text: "Join",
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    ));
  }
}
