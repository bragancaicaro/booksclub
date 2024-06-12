


import 'package:booksclub/app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:booksclub/app/app_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
void main() async{
 WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
  await Firebase.initializeApp(
    name: "booksclubapp",
    options: DefaultFirebaseOptions.currentPlatform,
  );
}