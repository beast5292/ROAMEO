import 'package:flutter/material.dart';
import 'package:practice/Home/home_page.dart';
import 'package:practice/SightSeeingMode/CameraPage/pages/camera_page.dart';
import 'package:practice/SightSeeingMode/CameraPage/providers/Image_provider.dart';
import 'package:practice/SightSeeingMode/location_select/pages/autoCwidget.dart';
import 'package:practice/SightSeeingMode/location_select/services/autoCService.dart';
import 'package:practice/SightSeeingMode/location_select/providers/selected_place_provider.dart';
import 'package:provider/provider.dart';

void main() {

  //providers
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SelectedImageProvider()), ChangeNotifierProvider(create:(_)=> SelectedPlaceProvider()) 
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
Widget build(BuildContext context) {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  );
}
}
