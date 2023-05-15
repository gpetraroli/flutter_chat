import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_chat/widgets/auth/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _imageFile;
  var _isAuthenticating = false;

  var _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a valid email address.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a valid username.';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 4 characters long.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a valid password.';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  void _setImageFile(File imageFile) {
    _imageFile = imageFile;
  }

  void _submit() async {
    setState(() {
      _isAuthenticating = true;
    });

    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final credentials =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String? imageURL;
        if (_imageFile != null) {
          final storageRef = await FirebaseStorage.instance
              .ref()
              .child('images')
              .child('users')
              .child('${credentials.user!.uid}.jpg');

          await storageRef.putFile(_imageFile!);
          imageURL = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credentials.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'image_url': imageURL,
          'username': _usernameController.text.trim(),
        });

        setState(() {
          _isAuthenticating = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'An error occurred!'),
        ),
      );

      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin)
            UserImagePicker(
              onPickedImage: _setImageFile,
            ),
          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            decoration: const InputDecoration(
              labelText: 'e-mail',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
          ),
          const SizedBox(height: 20),
          if (!_isLogin)
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'username',
              ),
              enableSuggestions: false,
              validator: _validateUsername,
            ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'password',
            ),
          ),
          const SizedBox(height: 20),
          _isAuthenticating
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isLogin ? 'Login' : 'Signup'),
                ),
          if (!_isAuthenticating)
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                  _isLogin ? 'Create an account' : 'I already have an account'),
            ),
        ],
      ),
    );
  }
}
