import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';


import '../../utils.dart';
import 'sega.dart';

class segmentation extends StatefulWidget {
  const segmentation({Key? key}) : super(key: key);

  @override
  State<segmentation> createState() => _segmentationState();
}

class _segmentationState extends State<segmentation> {
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(alignment: AlignmentDirectional.center, children: [
        Container(),
        RepaintBoundary(
            key: _globalKey,
            child: tempImgAssigned
                ? Image.memory(tempImg!)
                : Image.file(File(imgFile!.path))),
        Positioned(top: 1, right: 1, child: _opBar(context)),
        Positioned(
          child: _danceBar(),
          bottom: 1,
        )
      ]),
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
                  onPressed: () async {
                    if(tempImgAssigned) {
                      // KrasNaya();
                    }
                    else {
                      // KrasNaya();
                    }
                    setState(() {
                    });
                  },
                  child: const Icon(
                    Icons.filter,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {

                  });},
                  child: const Icon(
                    Icons.transform_rounded,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {},
                  child: const Icon(
                    Icons.construction_sharp,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () async {},
                  child: const Icon(
                    Icons.save_alt_sharp,
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
