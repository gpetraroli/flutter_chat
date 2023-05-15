import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  _submit() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    // get the current user
    final user = FirebaseAuth.instance.currentUser!;

    // get the user data for the current user
    // NOTE: here we are sending an http request to the server every time
    // a message is sent just to get the user's data; would be better to
    // store the user's data in the app's state (ex. Riverpod, Provider, ...)
    // and use that instead to avoid sending too many an http requests.
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // add the message to the messages collection
    await FirebaseFirestore.instance.collection('messages').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
            ),
          ),
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.send),
            color: Theme
                .of(context)
                .primaryColor,
          ),
        ],
      ),
    );
  }
}
