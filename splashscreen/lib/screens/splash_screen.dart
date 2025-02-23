import 'package:flutter/material.dart';
import '../widgets/zooming_splash_content.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: ZoomingSplashContent(),
    );
  }
}