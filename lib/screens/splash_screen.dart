import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/chat';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
