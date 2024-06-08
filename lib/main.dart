import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paycar/presentation/screen/loading_screen.dart';
import 'package:paycar/presentation/screen/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
     return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
     
      
    );
  }
}
