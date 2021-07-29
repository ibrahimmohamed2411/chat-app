import 'package:chat_app/widgets/auth/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatSnapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        final chatDocs = chatSnapshot.data!.docs;
        if (chatDocs.length == 0) {
          return Center(
            child: Text(
              'Let\'s start chatting now',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return ListView.builder(
          reverse: true,
          itemBuilder: (ctx, index) => MessageBubble(
            message: chatDocs[index]['text'],
            isMe: chatDocs[index]['userID'] == currentUser!.uid ? true : false,
            userName: chatDocs[index]['username'],
            key: ValueKey(
              chatDocs[index].id,
            ),
          ),
          itemCount: chatDocs.length,
        );
      },
    );
  }
}
