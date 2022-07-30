import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils.dart';

class ScaleImage extends StatefulWidget {
  const ScaleImage({Key? key}) : super(key: key);

  @override
  State<ScaleImage> createState() => _ScaleImageState();
}

class _ScaleImageState extends State<ScaleImage> {
  final GlobalKey _globalKey = GlobalKey();
  var txt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(),
          RepaintBoundary(
              key: _globalKey,
              child: tempImgAssigned
                  ? Image.memory(tempImg!)
                  : Image.file(File(imgFile!.path))),
          Positioned(bottom: 25, child: _opBar(context)),
          Positioned(
            child: _scaleBox(context),
            bottom: 85,
          )
        ],
      ),
    ));
  }

  Widget _scaleBox(context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff1f1f1f),
        borderRadius: BorderRadius.circular(12),
      ),
      width: 350,
      height: 80,
      child: TextField(
        maxLength: 3,
        controller: txt,
        autofocus: false,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Enter Scale Ratio",
          icon: Icon(Icons.aspect_ratio),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-1.]'))
        ],
      ),
    );
  }

  Widget _opBar(context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      primary: const Color(0xff1f1f1f),
    );
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      const SizedBox(
        height: 62,
      ),
      ElevatedButton(
        style: style,
        onPressed: () {
          if (txt.text != "") {
            scaleRatio = double.parse(txt.text) * scaleRatio;
            convertWidgetToImage(context, _globalKey);
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        },
        child: Row(
          children: const [
            Icon(
              Icons.done,
              color: Colors.white60,
            ),
            Text('Apply', style: TextStyle(color: Colors.white60))
          ],
        ),
      )
    ]);
  }
}
