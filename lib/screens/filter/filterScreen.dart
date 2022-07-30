import 'package:flutter/material.dart';
import 'dart:io';

import 'filters.dart';
import '../../utils.dart';

class editMode extends StatefulWidget {
  const editMode({Key? key}) : super(key: key);

  @override
  State<editMode> createState() => _editModeState();
}

class _editModeState extends State<editMode> {
  final GlobalKey _globalKey = GlobalKey();

  final List<List<double>> filters = [
    IDENTITY_MATRIX,
    SEPIA_MATRIX,
    GREYSCALE_MATRIX,
    VINTAGE_MATRIX,
    SWEET_MATRIX,
  ];
  final List<String> filters_name = [
    IDENTITY_name,
    SEPIA_name,
    GREYSCALE_name,
    VINTAGE_name,
    SWEET_name,
  ];
  int filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(alignment: Alignment.center, children: [
              Container(),
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                child: RepaintBoundary(
                    key: _globalKey,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(filters[filterIndex]),
                        child: tempImgAssigned
                            ? Image.memory(tempImg!)
                            : Image.file(File(imgFile!.path)))),
              ),
              Positioned(top: 1, right: 1, child: _opBar(context)),
              Positioned(
                  bottom: 5,
                  child: Container(
                    width: width - 5,
                    child: _filterBar(),
                  ))
            ])));
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
            Icon(Icons.done, color: Colors.white60),
            Text(
              'Apply',
              style: TextStyle(color: Colors.white60),
            )
          ],
        ),
      )
    ]);
  }

  Widget _filterBar() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: false,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return ColorFiltered(
              colorFilter: ColorFilter.matrix(filters[index]),
              child: Container(
                padding: EdgeInsets.all(8),
                child: InkWell(
                  child: ClipRRect(
                    child: Stack(children: <Widget>[
                      tempImgAssigned
                          ? Image.memory(tempImg!)
                          : Image.file(File(imgFile!.path)),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              //you can get rid of below line also
                              borderRadius: BorderRadius.circular(6.0),
                              //below line is for rectangular shape
                              shape: BoxShape.rectangle,
                              //you can change opacity with color here(I used black) for rect
                              color: Colors.black.withOpacity(0.5),
                              //I added some shadow, but you can remove boxShadow also.
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5.0,
                                  offset: Offset(5.0, 5.0),
                                ),
                              ],
                            ),
                            child: Text(
                              filters_name[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ]),
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAlias,
                  ),
                  onTap: () {
                    setState(() {
                      filterIndex = index;
                    });
                  },
                ),
                // padding: EdgeInsets.all(6),
              ));
        },
      ),
      decoration: BoxDecoration(
        color: Color(0xff1f1f1f),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
