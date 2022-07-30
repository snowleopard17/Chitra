import 'package:flutter/material.dart';
import 'dart:io';

import '../../utils.dart';

class transformMode extends StatefulWidget {
  const transformMode({Key? key}) : super(key: key);

  @override
  State<transformMode> createState() => _transformModeState();
}

class _transformModeState extends State<transformMode> {
  int _rotateFactor = 0;
  double fingerOffset = 0.0;

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(),
          Positioned(top: 1, right: 1, child: _opBar(context)),

          Container(
              decoration: BoxDecoration(),
              child: RepaintBoundary(
                key: _globalKey,
                child: RotatedBox(
                  quarterTurns: _rotateFactor,
                  child: InteractiveViewer(
                    maxScale: 500,
                    child: Transform.rotate(
                        angle: fingerOffset,
                        child: tempImgAssigned
                            ? Image.memory(tempImg!)
                            : Image.file(File(imgFile!.path))),
                  ),
                ),
              )),
          Positioned(
              bottom: 3,
              child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(12),
                  child: _danceBar())),
          // SizedBox(
          //   height: 22,
          // )
        ],
      ),
    ));
  }

  Widget _opBar(context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      primary: Color(0xff1f1f1f),
    );
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
        style: style,
        onPressed: () {
          convertWidgetToImage(context, _globalKey)
              .then((value) => {Navigator.pop(context)});
        },
        child: Row(
          children: const [
            Icon(
              Icons.done,
              color: Colors.white60,
            ),
            Text(
              'Apply',
              style: TextStyle(color: Colors.white60),
            )
          ],
        ),
      )
    ]);
  }

  Widget _danceBar() {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 30),
      primary: Color(0xff1f1f1f),
      shadowColor: Colors.black,
    );

    return GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            fingerOffset += details.delta.dx / 100;
          });
        },
        onHorizontalDragEnd: (details) {
          /// some code to add inertia
        },
        child: Container(
          color: Color(0xff1f1f1f),
          height: 58,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              style: style,
              onPressed: () {
                _rotateFactor--;
                setState(() {});
              },
              child: const Icon(
                Icons.rotate_left,
                size: 48,
                color: Colors.white54,
              ),
            ),
            Text(
              "Swipe to Rotate",
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.w500),
            ),
            ElevatedButton(
              style: style,
              onPressed: () {
                _rotateFactor++;
                setState(() {});
              },
              child: const Icon(
                Icons.rotate_right,
                size: 48,
                color: Colors.white54,
              ),
            ),
          ]),
        ));
  }
}
