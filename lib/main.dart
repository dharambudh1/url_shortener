import "package:flutter/material.dart";
import "package:url_shortener/screens/home_screen.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "URL Shortener",
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
