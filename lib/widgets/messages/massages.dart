import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred!'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found!'),
          );
        }

        final documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemBuilder: (context, index) {
            final message = documents[index];
            final nextMessage =
                index < documents.length - 1 ? documents[index + 1] : null;

            final currentMessageUserId = message['userId'];
            final nextMessageUserId =
                nextMessage != null ? nextMessage['userId'] : null;

            if (currentMessageUserId == nextMessageUserId) {
              return MessageBubble.next(
                message: message['text'],
                isMe: currentUser!.uid == message['userId'],
              );
            } else {
              return MessageBubble.first(
                userImage: message['userImage'],
                username: message['username'],
                message: message['text'],
                isMe: currentUser!.uid == message['userId'],
              );
            }
          },
        );
      },
    );
  }
}
