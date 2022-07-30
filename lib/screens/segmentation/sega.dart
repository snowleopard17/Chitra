import 'dart:io';
import 'dart:core';
import 'dart:math';
import 'package:image/image.dart';

import '../../utils.dart';
import 'dart:typed_data';

int clampPixel(int x) => x.clamp(0, 255);

void KrasNaya() async {

  tempImg = await File(imgFile!.path).readAsBytes();
  Image? dodo = decodeImage(tempImg!);
  Uint8List pixels = dodo!.getBytes(format: Format.rgba);
  for(int i=0; i<pixels.length; i+=4){
    clampPixel(pixels[i]+55).round();
    clampPixel(pixels[i+1]+55).round();
    clampPixel(pixels[i+2]+55).round();
  }
  tempImg = pixels;
  tempImgAssigned = true;
}