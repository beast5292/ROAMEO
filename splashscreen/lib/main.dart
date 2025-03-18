import 'package:flutter/material.dart';
 import 'screens/splash_screen.dart';
 
 void main() {
   runApp(const MyApp());
 }
 
 class MyApp extends StatelessWidget {
   const MyApp({Key? key}) : super(key: key);
 
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       debugShowCheckedModeBanner: false,
       title: 'Animated Splash Demo',
       theme: ThemeData(
         primarySwatch: Colors.blue,
       ),
       home: const SplashScreen(),
       routes: {
         '/home': (context) => const HomeScreen(),
       },
     );
   }
 }
 
 class HomeScreen extends StatelessWidget {
   const HomeScreen({Key? key}) : super(key: key);
 
   @override
   Widget build(BuildContext context) {
     return const Scaffold(
       body: Center(
         child: Text('Main App Screen'),
       ),
     );
   }
 }