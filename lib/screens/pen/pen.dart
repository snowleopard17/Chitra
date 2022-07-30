import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'painter.dart';
import '../../utils.dart';

class penMode extends StatefulWidget {
  const penMode({Key? key}) : super(key: key);

  @override
  State<penMode> createState() => _penModeState();
}

class _penModeState extends State<penMode>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  List<Offset> _points = <Offset>[];
  bool _drawIt = false;
  Color bgC = Colors.transparent;

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
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  tempImgAssigned
                      ? Image.memory(tempImg!)
                      : Image.file(File(imgFile!.path)),
                  Container(
                    height: 500,
                    width: 400,
                    color: bgC,
                    child: GestureDetector(
                      onPanDown: (details) {
                        print(details.localPosition);
                        setState(() {
                          _points.add(details.localPosition);
                        });
                      },
                      onPanUpdate: (details) {
                        print(details.localPosition);
                        setState(() {
                          _points.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          // _points.add(Offset(696969, 696969));
                        });
                      },
                      child: CustomPaint(
                        painter: painter(_points, _drawIt),
                      ),
                    ),
                  )
                ],
              )),
          Positioned(top: 1, right: 1, child: _opBar(context)),
          Positioned(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: _danceBar(),
            ),
            bottom: 25,
          )
        ],
      ),
    ));
  }

  Widget _opBar(context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      primary: const Color(0xff1f1f1f),
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
      primary: const Color(0xff1f1f1f),
    );

    return Column(
      children: [
        Container(
            color: const Color(0xff1f1f1f),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 52,
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    //TO DO//
                  },
                  child: const Icon(
                    Icons.architecture,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {
                      _drawIt = !_drawIt;
                    });
                  },
                  child: const Icon(
                    Icons.gesture,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {
                      if (bgC == Colors.transparent) {
                        bgC = Colors.white;
                      } else {
                        bgC = Colors.transparent;
                      }
                    });
                  },
                  child: const Icon(
                    Icons.layers,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {
                      _points = [];
                      _drawIt = false;
                    });
                  },
                  child: const Icon(
                    Icons.layers_clear,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
              ],
            ))
      ],
    );
  }
}
