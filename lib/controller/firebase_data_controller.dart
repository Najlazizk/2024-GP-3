import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../Models/device.dart';
import '../Models/user.dart';

class FirebaseDataController extends GetxController {
  static final FirebaseDataController instance = Get.find();
  Rx<User> user = User.dummy().obs;
  final fb = FirebaseDatabase.instance.ref();

  Rx<int> bottomNavigationCurrentIndex = 0.obs;

  set setIndex(int index) {
    bottomNavigationCurrentIndex.value = index;
  }

  @override
  void onInit() {
    fetchUserData('hadeel').then((value) {
      user.value = value;
      user.value.fetchDevicesData().then((v) {
        addListonerToUser().then((value) {});
      });
    });

    super.onInit();
  }

  Future<void> addListonerToUser() async {
    print('set user listener ');
    fb.child('users/${user.value.name}').onValue.listen((event) async {
      if (event.snapshot.exists) {
        var u = User.fromJson(event.snapshot.value as Map);
        await u.fetchDevicesData().then((value) {});

        user.value = u;
      } else {
        print('null ');
      }
    });
  }

  Future<void> addListonerToAllDevices() async {
    print('set devices listeern ${user.value.devices}');
    for (Device device in user.value.devices) {
      print(device.deviceID);
      fb.child('devices/${device.deviceID}').onValue.listen((event) async {
        print('device listern called device id is ${device.deviceID}');
        if (user.value.devices.isNotEmpty) {
          user.value.devices[user.value.devices.indexWhere((element) => element.deviceID == device.deviceID)] =
              Device.fromJson(event.snapshot.value, device.deviceID);
        }
        {
          print('empty devices list');
        }
      });
    }
  }

  Future<User> fetchUserData(String username) async {
    try {
      final snapshot = await fb.child('users/$username').get();
      final userData = snapshot.value;
      if (userData != null && userData is Map) {
        var u = User.fromJson(userData);

        return u;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error gracefully
    }
    return User.dummy();
  }

  Future<Device?> fetchDeviceData(String deviceId) async {
    try {
      final snapshot = await fb.child('/devices/$deviceId').get();
      final deviceData = snapshot.value;

      if (deviceData != null && deviceData is Map) {
        return Device.fromJson(deviceData, deviceId);
      }
    } catch (e) {
      print('Error fetching devices: $e');

      // Handle error gracefully
    }
    return null;
  }

  Future<void> removeDeviceFromUser(String deviceId) async {
    try {
      // Update local user object
      user.update((val) {
        val!.devices.removeWhere((element) => element.deviceID == deviceId);
      });
      await fb.child('users/${user.value.name}/devices/$deviceId').remove();
    } catch (e) {
      print('Error removing device from user: $e');
      // Handle error gracefully
    }
  }

  Future<void> setDeviceData(Device device) async {
    try {
      await fb.child('devices/${device.deviceID}').update(device.toJson());
    } catch (e) {
      print('Error setting device data: $e');
      // Handle error gracefully
    }
  }

  Future<void> updateDevice(String deviceId, Map<String, dynamic> data) async {
    try {
      await fb.child('devices/$deviceId').update(data);
    } catch (e) {
      print('Error updating device: $e');
      // Handle error gracefully
    }
  }

  Future<void> addNewDeviceToUser(String newDeviceId) async {
    try {
      // Check if the device already exists in the user's database
      final userSnapshot = await fb.child('users/${user.value.name}/devices/$newDeviceId').get();
      if (!userSnapshot.exists) {
        // Device does not exist in the user's database, now check on device database is this device id exist
        final deviceSnapshot = await fb.child('devices/$newDeviceId').get();

        if (deviceSnapshot.exists) {
          // device id  exist now link on device id on user database
          await fb.child('/users/${user.value.name}/devices').push().set(newDeviceId);
          print('Device with ID $newDeviceId added to user ${user.value.name} successfully.');
        } else {
          print('Device with ID $newDeviceId not exists in the devices  database.');
        }
      } else {
        // Device already exists in the user's database
        print('Device with ID $newDeviceId already exists in the user ${user.value.name}\'s database.');
      }
    } catch (e) {
      print('Error adding new device to user: $e');
      // Handle error gracefully
    }
  }
}
