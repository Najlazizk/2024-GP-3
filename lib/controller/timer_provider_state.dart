import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  bool _isDeviceOn = false;

  bool get isDeviceOn => _isDeviceOn;

  void updateDeviceState(bool isOn) {
    _isDeviceOn = isOn;
    notifyListeners();
  }
}
