import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:chitra/screens/pen/pen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../utils.dart';
import 'filter/filterScreen.dart';
import 'transform/transform.dart';
import 'scaling/scaling.dart';
import 'volumes/volumes.dart';
import 'segmentation/segmentation.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _toolsAnimationController;
  late Animation<double> _toolsAnimation;

  @override
  void initState() {
    super.initState();
    _toolsAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _toolsAnimation = CurvedAnimation(
        parent: _toolsAnimationController,
        curve: Curves.easeInOutCubicEmphasized);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _toolsAnimationController.dispose();
    super.dispose();
  }

  void scaler() async {
    File image = new File(imgFile!.path);
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    double imagWidth = decodedImage.width.toDouble();
    double width = MediaQuery.of(context).size.width;
    scaleRatio = imagWidth / width;
  }

  @override
  Widget build(BuildContext context) {
    scaler();
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(alignment: AlignmentDirectional.center, children: [
              Container(),
              ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: tempImgAssigned
                      ? Image.memory(tempImg!)
                      : Image.file(File(imgFile!.path))),
              Positioned(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: _danceBar(),
                ),
                bottom: 12,
              ),
              Positioned(
                child: _toolBar(),
                bottom: 85,
              ),
            ])));
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
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => editMode()))
                        .then((value) => setState(() {}));
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
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => transformMode()))
                        .then((value) => setState(() {}));
                  },
                  child: const Icon(
                    Icons.transform_rounded,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: onToolButtonPressed,
                  child: const Icon(
                    Icons.construction_sharp,
                    size: 48,
                    color: Colors.white60,
                  ),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () async {
                    if (tempImg != null) {
                      File imageFile = File.fromRawPath(tempImg!);

                        currentUnix = '${DateTime.now().millisecondsSinceEpoch}';
                      if (!await dirChi.exists()) {
                        log("not exist");
                        dirChi.create();
                      }
                      String fileFormat = 'png';

                      // await imageFile.copy(
                        print('${dirChi.path}$currentUnix.$fileFormat');
                      // );
                    } else {
                      print("The tempImg is null");
                    }
                  },
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

  void onToolButtonPressed() {
    if (_toolsAnimationController.value == 1) {
      _toolsAnimationController.reverse();
    } else {
      _toolsAnimationController.forward();
    }
    setState(() {});
  }

  Widget _toolBar() {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 30),
      primary: Colors.white,
    );

    return SizeTransition(
        sizeFactor: _toolsAnimation,
        child: Container(
          padding: EdgeInsets.all(8),
          width: 250,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            children: [
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScaleImage()))
                      .then((value) => setState(() {}));
                },
                child: const Icon(
                  Icons.aspect_ratio,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const segmentation()))
                      .then((value) => setState(() {}));
                },
                child: const Icon(
                  Icons.segment_rounded,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const penMode()))
                      .then((value) => setState(() {}));
                },
                child: const Icon(
                  Icons.edit,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {},
                child: const Icon(
                  Icons.face_retouching_natural,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {},
                child: const Icon(
                  Icons.deblur,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {},
                child: const Icon(
                  Icons.filter_alt,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VolumeBox()))
                      .then((value) => setState(() {}));
                },
                child: const Icon(
                  Icons.view_in_ar,
                  size: 42,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ));
  }
}
