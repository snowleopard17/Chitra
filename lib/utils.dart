import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';


XFile? imgFile;
var currentUnix;
final dirChi = Directory('/sdcard/DCIM/Chitra/');

Uint8List? tempImg = null;
var tempImgAssigned = false;

double scaleRatio = 1.0;

Future convertWidgetToImage(context, _globalKey) async {
  final RenderRepaintBoundary repaintBoundary =
  _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: scaleRatio);
  ByteData? byteData =
  await boxImage.toByteData(format: ui.ImageByteFormat.png);
  Uint8List int8list = byteData!.buffer.asUint8List();
  tempImgAssigned = true;
  tempImg = int8list;
}

