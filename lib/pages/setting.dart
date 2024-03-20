import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final int selectedTime;
  final Function(int) onTimeChanged;

  SettingsPage({required this.selectedTime, required this.onTimeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Notification Time",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            DropdownButton<int>(
              value: selectedTime,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onTimeChanged(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text("1 Hour"),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text("2 Hours"),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text("3 Hours"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
