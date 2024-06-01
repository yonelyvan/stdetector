import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stdetector/src/ui/screens/home.dart';

class Permissions extends StatefulWidget {
  const Permissions({super.key});

  @override
  State<StatefulWidget> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  /// Logger for debugging
  final logger = Logger();

  bool permissionsBluetooth = false;
  bool permissionsGps = false;

  Future<void> requestBluetoothPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isGranted) {
      setState(() {
        permissionsBluetooth = true;
      });
      logger.i(
          "Bluetooth permission granted, proceed with Bluetooth functionality");
    } else {
      logger.i("Bluetooth permission denied");
    }
  }

  bool get _permissionsGranted => permissionsBluetooth & permissionsGps;

  void requestLocationPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        permissionsGps = true;
      });
    } else {
      // Location permission denied
    }
  }

  @override
  void initState() {
    requestBluetoothPermissions();
    requestLocationPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grant permissions"),
      ),
      body: Center(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_permissionsGranted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } else {
              requestBluetoothPermissions();
              requestLocationPermissions();
            }
          },
          child: _permissionsGranted
              ? const Text(
                  'Go to Stress Detector',
                  style: TextStyle(color: Colors.white),
                )
              : const Text(
                  "Grant permissions",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
