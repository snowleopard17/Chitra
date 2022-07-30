import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/CamHome.dart';

class ChitraApp extends StatelessWidget {
  const ChitraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const SafeArea(
          child: CamHome()
      ),
    );
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (err) {
    if (kDebugMode) {
      print('Error fetch camera: $err');
    }
  }
  runApp(const ChitraApp());
}
