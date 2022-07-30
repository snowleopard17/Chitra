import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import '../utils.dart';
import 'Editor.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

List<CameraDescription> cameras = <CameraDescription>[];

void logError(String code, String? message) {
  if (message != null) {
    log('Error: $code\nError Message: $message');
  } else {
    log('Error: $code');
  }
}

class CamHome extends StatefulWidget {
  const CamHome({Key? key}) : super(key: key);

  @override
  State<CamHome> createState() => _CamHomeState();
}

class _CamHomeState extends State<CamHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool enableAudio = true;
  ResolutionPreset resolutionPreset = ResolutionPreset.max;

  //Zoom Variables
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  //Exposure variables
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  bool _isRearCameraSelected = true;

  //FLash
  FlashMode? _currentFlashMode;

  //For thumbnail preview
  VideoPlayerController? videoController;

  //Animations
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;

  //"I will make a chick picker one day"~ coding thoughts
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    onNewCameraSelected(cameras[0]);
    //Animations
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCirc,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff1f1f1f),
      body: _isCameraInitialized
          ? Column(
              children: <Widget>[
                _homeBox(),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        _cameraPreviewWidget(),
                        Positioned(
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: _switchCam())),
                        Positioned(
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _captureButton()),
                        ),
                        Positioned(
                            bottom: 23,
                            right: 5,
                            child: InkWell(
                              child: _thumbnailWidget(),
                              onTap: () {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditPage()),
                                  ).then((value) => setState(() {}));
                                });
                              },
                            )),
                        _exposureModeControlRowWidget(),
                        _flash(),
                      ],
                    ),
                    // decoration: const BoxDecoration(
                    //   color: Colors.black,
                    // ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    void _showCameraException(CameraException e) {
      logError(e.code, e.description);
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        logError('Camera error ', cameraController.value.errorDescription);
      }
    });
    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (err) {
      _showCameraException(err);
    }
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
    _currentFlashMode = controller!.value.flashMode;
    _currentExposureOffset = 0.0; //Reseting Exposure offset for new camera
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Yo someshit deep is wrong',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  //Go cross fingures in and then touch sidewalls
  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Widget _homeBox() {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      primary: Color(0xff1f1f1f),
    );

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ElevatedButton(
              style: style,
              onPressed: () async {
                await _picker
                    .pickImage(source: ImageSource.gallery)
                    .then((photo) => {
                          if (photo != null)
                            {
                              tempImgAssigned = false,
                              tempImg = null,
                              imgFile = photo,
                              print(photo.path),
                              currentUnix =
                                  File(imgFile!.path).uri.pathSegments.last,
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditPage()),
                              ),
                            }
                        });
              },
              child: Row(
                children: const [Icon(Icons.dashboard), Text('Gallery')],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exposure),
              color: Colors.white,
              onPressed:
                  controller != null ? onExposureModeButtonPressed : null,
            ),
            IconButton(
              icon: const Icon(Icons.bolt),
              color: Colors.white,
              onPressed: controller != null ? onFlashModeButtonPressed : null,
            ),
            ElevatedButton(
              style: style,
              onPressed: () {},
              child: Row(children: const [
                Icon(Icons.settings),
              ]),
            ),
          ],
        ),
      ],
    );
  }
  //Exposure

  //Flash
  Widget _flash() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: Row(
        children: [
          const Spacer(),
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.off;
              });
              await controller!.setFlashMode(
                FlashMode.off,
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(
                Icons.flash_off,
                color: _currentFlashMode == FlashMode.off
                    ? Colors.amber
                    : Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.auto;
              });
              await controller!.setFlashMode(
                FlashMode.auto,
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(
                Icons.flash_auto,
                color: _currentFlashMode == FlashMode.auto
                    ? Colors.amber
                    : Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _isCameraInitialized = false;
              });
              onNewCameraSelected(
                cameras[_isRearCameraSelected ? 1 : 0],
              );
              setState(() {
                _isRearCameraSelected = !_isRearCameraSelected;
              });
            },
            child: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(
                Icons.flash_on,
                color: _currentFlashMode == FlashMode.always
                    ? Colors.amber
                    : Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.torch;
              });
              await controller!.setFlashMode(
                FlashMode.torch,
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(
                Icons.highlight,
                color: _currentFlashMode == FlashMode.torch
                    ? Colors.amber
                    : Colors.white,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  //Switch Cam
  Widget _switchCam() {
    return InkWell(
      onTap: () {
        setState(() {
          _isCameraInitialized = false;
        });
        onNewCameraSelected(
          cameras[_isRearCameraSelected ? 1 : 0],
        );
        setState(() {
          _isRearCameraSelected = !_isRearCameraSelected;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(
            Icons.circle,
            color: Colors.black38,
            size: 80,
          ),
          Icon(
            Icons.cameraswitch,
            color: Colors.white,
            size: 45,
          ),
        ],
      ),
    );
  }

  //Take Pic Backend
  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      return await cameraController.takePicture();
    } on CameraException catch (e) {
      log('Error occurred while taking picture: $e');
      return null;
    }
  }

  Widget _captureButton() {
    return (InkWell(
      onTap: () async {
        XFile? rawImage = await takePicture();
        if (rawImage!=null){
          File imageFile = File(rawImage.path);

          currentUnix = '${DateTime.now().millisecondsSinceEpoch}';
          if (!await dirChi.exists()) {
            log("not exist");
            dirChi.create();
          }
          String fileFormat = imageFile.path.split('.').last;

          await imageFile.copy(
            '${dirChi.path}/$currentUnix.$fileFormat',
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.circle, color: Colors.white, size: 80),
          Icon(Icons.lens_blur, color: Colors.black, size: 65),
        ],
      ),
    ));
  }

  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (localVideoController == null && imgFile == null)
          Container()
        else
          SizedBox(
            child: (localVideoController == null)
                ? (
                    // The captured image on the web contains a network-accessible URL
                    // pointing to a location within the browser. It may be displayed
                    // either with Image.network or Image.memory after loading the image
                    // bytes to memory.
                    kIsWeb
                        ? Image.network(imgFile!.path)
                        : Image.file(File(imgFile!.path)))
                : Container(
                    child: Center(
                      child: AspectRatio(
                          aspectRatio: localVideoController.value.aspectRatio,
                          child: VideoPlayer(localVideoController)),
                    ),
                    decoration: const BoxDecoration(),
                  ),
            width: 84.0,
            height: 84.0,
          ),
      ],
    );
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  //Exposure
  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (err) {
      log('$err');
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (err) {
      log('$err');
      rethrow;
    }
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      log('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.yellowAccent
          : Colors.white,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.yellowAccent
          : Colors.white,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  TextButton(
                    child: const Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setExposurePoint(null);
                        log('Resetting exposure point');
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                  ),
                  TextButton(
                    child: const Text('RESET OFFSET'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => controller!.setExposureOffset(0.0)
                        : null,
                  ),
                ],
              ),
              const Center(
                child: Text('Exposure Offset'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white70,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
