
import 'package:electech/controller/firebase_data_controller.dart';

import 'device.dart'; // Import Firebase package

class User {
  final String userId;
  final String name;
  final String email;
  final List<String> devicesIds;
   List<Device> devices = [];

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.devicesIds,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) {
    List<String> d=[];
    for(Object? key in json['devices'].keys){
      d.add(json['devices'][key]);
    }

    final user = User(
      userId: json['userId'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      devicesIds: d,
    );

     //user.fetchDevicesData(); // Call fetchDevicesData method
    return user;
  }
  factory User.dummy() {
     return User(
      userId: "1",
      name:  "h",
      email: "h@gmail.com",
       devicesIds: [],

    );

  }

  Future<void> fetchDevicesData() async {
      if(devicesIds!=null){
      for (String deviceId in devicesIds) {
       final  deviceData=  await FirebaseDataController.instance.fetchDeviceData(deviceId);

       if (deviceData != null ) {

          devices.add(deviceData);
          // print('$devicesIds  :${devices[0].toString()}');
        }

    }
  }
  }






}
