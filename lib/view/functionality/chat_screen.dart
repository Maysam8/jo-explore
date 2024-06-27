import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduationproject/view/widget/colors.dart';

class GroupChatScreen extends StatefulWidget {
  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _username = userData['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc('group_id')
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  reverse: true,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildMessageTile(data);
                  }).toList(),
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> data) {
    final bool isCurrentUser =
        data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                isCurrentUser ? 'You' : data['senderName'] ?? 'Anonymous',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.orange : Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.all(10.0),
            child: Text(
              data['content'],
              style:
                  TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
            ),
          ),
          SizedBox(height: 5.0),
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                _formatTimestamp(data['timestamp']),
                style: TextStyle(fontSize: 10.0, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('groups')
          .doc('group_id')
          .collection('messages')
          .add({
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'senderName': _username,
        'content': messageContent,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = '${dateTime.hour}:${dateTime.minute}';
    return formattedTime;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
