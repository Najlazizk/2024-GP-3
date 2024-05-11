import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electech/controller/firebase_data_controller.dart';
import 'package:electech/controller/timer_provider_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DeviceSettingScreen extends StatefulWidget {
  const DeviceSettingScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceSettingScreen> createState() => _DeviceSettingScreenState();
}

class _DeviceSettingScreenState extends State<DeviceSettingScreen> {
  CountDownController controller = CountDownController();
  TimeOfDay _timeOfDay = TimeOfDay.now();
  final dataController = FirebaseDataController();

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

    Timer.periodic(Duration(minutes: minutes), (timer) {
      if (on1) {
        showNotification('Alert', 'You exceed the threshold');
      }
    });
  }

  // display flutter local notification
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> savingFcmToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    await storeToken(token);
  }

  final _firebaseInstance = FirebaseFirestore.instance.collection('FcmTokens'); // Replace 'FcmTokens' with your desired collection name

  Future<void> storeToken(String token) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance.where('fcmT', isEqualTo: token).limit(1).get();

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
    dataController.updateDevice(widget.deviceId, {
      'relay1': "OFF",
      'relay2': "OFF",
    });
  }

  Future<void> deleteToken() async {
    String token = (await FirebaseMessaging.instance.getToken())!;
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance.where('fcmT', isEqualTo: token).limit(1).get();

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
    String milliseconds = (milli % 1000).toString().padLeft(2, "0"); // 1001 % 1000 = 1, 1450 % 1000 = 450
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");
    String hours = ((milli ~/ (1000 * 60 * 60)) % 24).toString().padLeft(2, "0");
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

    Future.delayed(const Duration(seconds: 1), () {
      final isDeviceOn = Provider.of<TimerProvider>(context, listen: false).isDeviceOn;

      if (isDeviceOn) {
        setState(() {
          clicked = !clicked;
          on1 = !on1;
          if (clicked) {
            startTimer();
            dataController.updateDevice(widget.deviceId, {
              'relay1': "ON",
              'relay2': "ON",
            });
            // sendRequest("1", "ON");
            // sendRequest("2", "ON");
          } else {
            stopAndResetTimer();

            // sendRequest("1", "OFF");
            // sendRequest("2", "OFF");
          }
        });
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
    final theme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                clicked = !clicked;
                on1 = !on1;
                if (clicked) {
                  startTimer();
                  dataController.updateDevice(widget.deviceId, {
                    'relay1': "ON",
                    'relay2': "ON",
                  });
                  // sendRequest("1", "ON");
                  // sendRequest("2", "ON");
                } else {
                  stopAndResetTimer();

                  // sendRequest("1", "OFF");
                  // sendRequest("2", "OFF");
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: on1 ? const Color(0xFF9ED2FC) : const Color(0xFF9ED2FC), // Change color based on state
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                on1 ? "OFF" : "ON",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 250,
              width: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9ED2FC),
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
          const SizedBox(height: 10),
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
                items: const [
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
            ],
          ),
          // Container(
          //     margin: const EdgeInsets.only(right: 200, top: 20),
          //     child: Text(
          //       'Switches',
          //       style: TextStyle(color: theme.tertiary, fontSize: 25, fontWeight: FontWeight.bold),
          //     )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                // Padding(
                //     padding: const EdgeInsets.only(
                //       top: 40,
                //     ),
                //     child: CircularPercentIndicator(
                //       radius: 110,
                //       lineWidth: 15,
                //       percent: 0.90,
                //       progressColor: theme.primary,
                //     )),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _timeOfDay.format(context).toString(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _TimePicker();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                        backgroundColor: theme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                      child: Text(
                        'Time Select',
                        style: TextStyle(color: Colors.blue[100], fontSize: 18),
                      ),
                    ),
                  ],
                )
              ]),
            ],
          ),
        ],
      ),
    );
  }

  // Future<void> _TimePicker() async {
  //   await showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) => setState(() {
  //         _timeOfDay = value!;
  //       }));
  // }

  Future<void> _TimePicker() async {
    TimeOfDay? selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (selectedTime != null) {
      // Get the current time
      final now = DateTime.now();
      // Convert the selected time to DateTime
      final selectedDateTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

      // Check if the selected time is in the future
      if (selectedDateTime.isAfter(now)) {
        // Calculate the duration until the selected time
        final durationUntilSelectedTime = selectedDateTime.difference(now);

        // Start the timer with the calculated duration
        Timer(durationUntilSelectedTime, () {
          // Start the timer when the selected time is reached
          startTimer();
        });
      } else {
        // The selected time is in the past, do something else if needed
        print('Selected time is in the past.');
      }

      setState(() {
        _timeOfDay = selectedTime;
      });
    }
  }
}
