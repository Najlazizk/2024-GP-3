import 'package:electech/controller/firebase_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utiles/widgets/device_widget.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Obx(
          () {
        final user = FirebaseDataController.instance.user.value;
        print('update device screen ${user.devices}');

        if (user.devices.isNotEmpty) {

          return ListView.builder(
            itemCount: user.devices.length,
            itemBuilder: (context, index) => DeviceWidget(
              deviceData: user.devices[index],
            ),
          );
        } else {
          return Center(
            child: Text(
              "No devices configured yet",
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
  }
}
