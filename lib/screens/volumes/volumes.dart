import 'package:flutter/material.dart';
import 'dart:math' as math;

class VolumeBox extends StatefulWidget {
  const VolumeBox({Key? key}) : super(key: key);

  @override
  State<VolumeBox> createState() => _VolumeBoxState();
}

class _VolumeBoxState extends State<VolumeBox> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cube"),
      ),
      body: boxBoi(),
    );
  }

  Widget boxBoi() {
    return Listener(
        onPointerMove: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: Stack(alignment: Alignment.center, children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
          ),
          Transform(
            transform: Matrix4.identity()
              ..rotateX(_offset.dy * math.pi / 180)
              ..rotateY(_offset.dx * math.pi / 180),
            alignment: Alignment.center,
            child: Cubie(),
          ),
        ]));
  }
}

class Cubie extends StatelessWidget {
  const Cubie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Transform(
          transform: Matrix4.identity()..translate(-100.0, 0.0, 0.0)..rotateY(-math.pi/2),
          alignment: Alignment.center,
          child: Container(
            color: Colors.red,

        height: 200,
        width: 200,
      )),
      Transform(
        transform: Matrix4.identity()..translate(0.0, 0.0, 100.0),
        alignment: Alignment.center,
        child: Container(
          color: Colors.yellow,
          height: 200,
          width: 200,
        ),
      ),
      Transform(
        transform: Matrix4.identity()..translate(0.0,0.0, -100.0),
        alignment: Alignment.center,
        child: Container(
          color: Colors.green,
          height: 200,
          width: 200,
        ),
      ),
      Transform(
        transform: Matrix4.identity()
          ..translate(100.0, 0.0, 0.0)
          ..rotateY(math.pi / 2),
        alignment: Alignment.center,
        child: Container(
          color: Colors.lightBlueAccent,
          height: 200,
          width: 200,
        ),
      ),
      Transform(
        transform: Matrix4.identity()..rotateX(-math.pi / 2)..translate(0.0, 0.0, -100.0),
        alignment: Alignment.center,
        child: Container(
          color: Colors.purple,
          height: 200,
          width: 200,
        ),
      ),
      Transform(
        transform: Matrix4.identity()
          ..rotateX(-math.pi / 2)
          ..translate(0.0, 0.0, 100.0),
        alignment: Alignment.center,
        child: Container(
          color: Colors.white,
          height: 200,
          width: 200,
        ),
      ),
    ]);
  }
}
