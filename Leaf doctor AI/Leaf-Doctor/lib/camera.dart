import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:Leaf_Doctor/result.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture = Future.value();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initCameraController();
    _initTensorFlow();
    checkInternetConnection();
  }

  Future<void> _initCameraController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  void _processImage(String path) async {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent user from dismissing dialog
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processing image...'),
              ],
            ),
          ),
        );
      },
    );
    final String label = await _objectRecongnition(path);
    Navigator.of(context).pop(); // close the dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.32,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return ResultPreviewBottomSheet(
              imageFile: File(path),
              scrollController: scrollController,
              label: label,
              isConnected: _isConnected,
            );
          },
        );
      },
    );
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile file = await _controller.takePicture();
      final String path = file.path;
      _processImage(path);
      print('Picture saved to $path');
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _uploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('Image picked from gallery: ${pickedFile.path}');
        _processImage(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
  Future<void> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Camera')),
      backgroundColor: Colors.transparent,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _takePicture,
                        icon: SizedBox(
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.camera,size: 48,color:Color(0xFF444445)),
                          // Image.asset(
                          //   'assets/images/icons/capture.png',
                          //   width: 48,
                          //   height: 48,
                          // ),
                        ),
                      ),
                      IconButton(
                        onPressed: _uploadImage,
                        icon: SizedBox(
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.collections,size: 48,color:Color(0xFF444445)),
                          // Image.asset(
                          //   'assets/images/icons/gallery.png',
                          //   width: 48,
                          //   height: 48,
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  Future<void> _initTensorFlow() async{
    String? res = await Tflite.loadModel(
        model: "assets/model/model.tflite",
        labels: "assets/model/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }
  Future<String> _objectRecongnition(String filepath) async{
    var recognitions = await Tflite.runModelOnImage(
        path: filepath,   // required
        // imageMean: 127.5,   // defaults to 117.0
        // imageStd: 255.0,  // defaults to 1.0
        numResults: 38,    // defaults to 5
        threshold: 0.1,   // defaults to 0.1
        asynch: true      // defaults to true
    );
    // ByteData data = await rootBundle.load(filepath);
    // img.Image? leaf_image = img.decodeImage(data.buffer.asUint8List());
    // // leaf_image= img.grayscale(leaf_image!);
    // leaf_image= img.copyResize(
    //     leaf_image!,
    //     width: 250,
    //     height: 250);
    // var recognitions = await Tflite.runModelOnBinary(
    //     binary: imageToByteListUint8(leaf_image, 250),// required
    //     numResults: 38,    // defaults to 5
    //     threshold: 0.05,  // defaults to 0.1
    //     asynch: true      // defaults to true
    // );
    return recognitions![0]["label"].toString();
  }
  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        
      // get the red value from the image
      

        buffer[pixelIndex++] = pixel.r.toInt();
        buffer[pixelIndex++] = pixel.g.toInt();
        buffer[pixelIndex++] = pixel.b.toInt();
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
