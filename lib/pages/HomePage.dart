import 'dart:async';
import 'package:electech/pages/notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stopwatch stopwatch;
  late Timer t;
  bool clicked = false;
  bool on1 = false;
  bool on2 = false;
  bool on3 = false;
  var token;
  int minutes = 1; // Default selected hour

  void startTimer() {
    stopwatch.start();
    savingFcmToken();
    // Automatically turn off the "off" button after three hours
    const Duration threeHours = Duration(minutes: 30);
    Timer(threeHours, () {
      if (on1) {
        setState(() {
          clicked = false;
          on1 = false;
          stopAndResetTimer();
          sendRequest("1", "OFF");
          sendRequest("2", "OFF");
        });
      }
    });
  }

  Future<void> savingFcmToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    await storeToken(token);
  }

  final _firebaseInstance = FirebaseFirestore.instance.collection(
      'FcmTokens'); // Replace 'FcmTokens' with your desired collection name

  Future<void> storeToken(String token) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance
          .where('fcmT', isEqualTo: token)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Token already exists in Firestore
        print('Token already exists');
      } else {
        // Token doesn't exist, save it with timestamp
        String randomId = _firebaseInstance.doc().id;
        DateTime now = DateTime.now();

        // Add 3 hours to the current time
        DateTime expirationTime = now.add(Duration(minutes: minutes));

        // Format the timestamp
        String formattedTime = DateFormat('h:mm a').format(expirationTime);
        // Format the date
        String formattedDate = DateFormat('d/M/yyyy').format(expirationTime);

        await _firebaseInstance.doc(randomId).set({
          'fcmT': token,
          "minutes": minutes,
          'timestamp': formattedTime, // Store formatted time
          'date': formattedDate, // Store formatted date
        });
        print('Token stored successfully');
      }
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  void stopTimer() {
    stopwatch.stop();
  }

  void resetTimer() {
    stopwatch.reset();
  }

  void stopAndResetTimer() async {
    stopTimer();
    await deleteToken();

    resetTimer();
  }

  Future<void> deleteToken() async {
    String token = (await FirebaseMessaging.instance.getToken())!;
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance
          .where('fcmT', isEqualTo: token)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Token exists in Firestore, delete it
        String documentId = querySnapshot.docs.first.id;
        await _firebaseInstance.doc(documentId).delete();
        print('Token deleted successfully');
      } else {
        // Token not found in Firestore
        print('Token not found');
      }
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;
    String milliseconds = (milli % 1000)
        .toString()
        .padLeft(2, "0"); // 1001 % 1000 = 1, 1450 % 1000 = 450
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");
    String hours =
        ((milli ~/ (1000 * 60 * 60)) % 24).toString().padLeft(2, "0");
    return "$hours:$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    t = Timer.periodic(const Duration(microseconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String sendingRequset(String relay, String status) {
    String completeLink = 'http://192.168.254.137/cm?cmnd=Power$relay $status';
    return completeLink;
  }

  sendRequest(String relay, String status) async {
    String link = sendingRequset(relay, status);
    final url = Uri.parse(link);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Success");
    } else {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "electech",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 129, 55),
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Notifications(
                            currentFCMToken: token,
                          )));
            },
            child: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 250,
                  width: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 2, 129, 55),
                      width: 4,
                    ),
                  ),
                  child: Text(
                    returnFormattedText(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // DropdownButton for selecting hours
                  DropdownButton<int>(
                    value: minutes,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          minutes = newValue;
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('1 minute'),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text('2 minutes'),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text('3 minutes'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        clicked = !clicked;
                        on1 = !on1;
                        if (clicked) {
                          startTimer();
                          sendRequest("1", "ON");
                          sendRequest("2", "ON");
                        } else {
                          stopAndResetTimer();
                          sendRequest("1", "OFF");
                          sendRequest("2", "OFF");
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: on1
                            ? Colors.green
                            : Colors.green, // Change color based on state
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        on1 ? "OFF" : "ON",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
