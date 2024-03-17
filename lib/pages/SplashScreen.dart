// Importing necessary Dart packages and libraries
import 'dart:async'; // Dart's asynchronous programming library
import 'package:flutter/material.dart';
import 'package:electech/coing/config.dart';
import 'package:electech/pages/homePage.dart';

// Declaring a StatefulWidget 'splashScreen' for a dynamic UI component
class splashScreen extends StatefulWidget {
  // Constructor with an optional Key parameter
  const splashScreen({Key? key}) : super(key: key);

  // Overriding createState() to return an instance of the private State class '_splashScreenState'
  @override
  State<splashScreen> createState() => _splashScreenState();
}

// Private State class for 'splashScreen'
class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    countDown();
    super.initState();
  }

  countDown() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      Route route = MaterialPageRoute(builder: (_) => HomePage());
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    });
  }

  // initState method to initialize the state of the widget, This is the frist thing will apear
  @override
  Widget build(BuildContext context) {
    return Material(
      // Material widget as the base of the UI

      child: SafeArea(
        // SafeArea to avoid intrusions by the operating system
        child: Column(
          // Column widget for vertical layout of child widgets
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Centering children vertically
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              // Container for the splash screen image
              child: Image.asset(
                "images/logo.png", // Path to the image asset
                width: 350, // Fit the image to the container's height
                height: 350,
                fit: BoxFit.fitWidth,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      textAlign: TextAlign.center,
                      "Welcome To sonoff application where you can control your home using your mobile phone",
                      style: TextStyle(color: SonOff.blackColor),
                    ),
                  ),
                  CircularProgressIndicator(
                    color: SonOff.prmaryColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
