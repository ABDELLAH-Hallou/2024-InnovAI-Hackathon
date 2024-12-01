import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;
import 'DatabaseHelper.dart';
import 'camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:share/share.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'fullscreen_image.dart';

class ResultPreviewBottomSheet extends StatefulWidget {
  final File imageFile;
  final double defaultChildSize;
  final double minChildSize;
  final double maxChildSize;
  final String label;
  final ScrollController scrollController;
  final bool isConnected;

  ResultPreviewBottomSheet({
    required this.imageFile,
    required this.scrollController,
    required this.label,
    required this.isConnected,
    this.defaultChildSize = 0.7,
    this.minChildSize = 0.32,
    this.maxChildSize = 0.9,

  });

  @override
  _ResultPreviewBottomSheetState createState() =>
      _ResultPreviewBottomSheetState();
}

String extractName(String inputString) {
  List<String> parts = inputString.split('___');

  return parts[0];
}

String getDiseaseName(String diseaseString) {
  // Split the string into parts using the "___" separator
  List<String> parts = diseaseString.split("___");

  // Get the last part of the split string and replace underscores with spaces
  String name = parts.last.replaceAll("_", " ");

  // Return the name
  return name;
}

List<Object> getPlantHealth(String diseaseName) {
  if (diseaseName.toLowerCase() == "healthy") {
    // If the diseaseName is "healthy", return the healthy message
    return [
      "Healthy",
      "Your Plant Seems Healthy enough.",
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFC9EFC7),
        ],
      ),
    ];
  } else {
    // If the diseaseName is not "healthy", return the unhealthy message with the diseaseName included
    return [
      "Not Healthy",
      "Your Plant Seem to suffer from " + diseaseName + ".",
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFEFD1C7),
        ],
      ),
    ];
  }
}

class _ResultPreviewBottomSheetState extends State<ResultPreviewBottomSheet> {
  late ImageProvider _imageProvider;
  double _currentChildSize = 0.7;
  final DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _imageProvider = FileImage(widget.imageFile);
  }

  @override
  void didUpdateWidget(covariant ResultPreviewBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageFile != oldWidget.imageFile) {
      setState(() {
        _imageProvider = FileImage(widget.imageFile);
      });
    }
  }

  Future<void> _saveImage() async {
    try {
      GallerySaver.saveImage(widget.imageFile.path);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Image saved to gallery'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _saveResult() async {
    final image = widget.imageFile.path;
    final leafName = extractName(widget.label);
    final diseaseName = getDiseaseName(widget.label);
    final status = getPlantHealth(getDiseaseName(widget.label))[0] as String;
    print(image);
    final id = await databaseHelper.insertData(
      image: image,
      leafName: leafName,
      status: status,
      diseaseName: diseaseName,
    );
    // show that the item has been saved
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reuslt saved Successfully'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _newImage() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (_) {},
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _currentChildSize =
              (_currentChildSize - details.primaryDelta! / context.size!.height)
                  .clamp(widget.minChildSize, widget.maxChildSize);
        });
      },
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        color: Colors.white,
        elevation: 3.0,
        child: Column(
          children: [
            Container(
              height: 5,
              width: 50,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height *
                          widget.maxChildSize,
                      minHeight: MediaQuery.of(context).size.height *
                          widget.minChildSize,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient:
                              getPlantHealth(getDiseaseName(widget.label))[2]
                                  as Gradient),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            child: Text(
                              "The Plant is ${getPlantHealth(getDiseaseName(widget.label))[0] as String}",
                              style: TextStyle(
                                fontFamily: 'Armata',
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                fontSize: 21,
                                height: 26 / 21,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.47,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image(
                                          image: _imageProvider,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        // widthFactor: 1,
                                        // heightFactor: 0.8,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 16,
                                              left: 16,
                                              child: IconButton(
                                                icon: const Icon(Icons.download,
                                                    color: Colors.white),
                                                // Image.asset(
                                                //     'assets/images/icons/download.png'),
                                                onPressed: _saveImage,
                                              ),
                                            ),
                                            Positioned(
                                              top: 16,
                                              right: 16,
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.open_in_full,
                                                    color: Colors.white),
                                                // Image.asset(
                                                //     'assets/images/icons/enlarge.png'),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullScreenImage(
                                                              imageFile: widget
                                                                  .imageFile,
                                                              name: extractName(
                                                                  widget
                                                                      .label)),
                                                    ),
                                                  );
                                                  // handle enlarge button press
                                                  print(
                                                      "Full screen mode enabled");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(99.4, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    side: BorderSide(
                                      width: 2,
                                      color: Color(0xFF444445),
                                    ),
                                  ),
                                  backgroundColor: Color(0xFF636C63),
                                ),
                                onPressed: _newImage,
                                child: Text('New',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                    )),
                              ),
                              TextButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(99.4, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    side: BorderSide(
                                      width: 2,
                                      color: Color(0xFF444445),
                                    ),
                                  ),
                                  backgroundColor: Color(0xFFC9EFC7),
                                ),
                                onPressed: _saveResult,
                                child: Text('Save',
                                    style: TextStyle(
                                      color: Color(0xFF454545),
                                    )),
                              ),
                              IconButton(
                                onPressed: () {
                                  Share.shareFiles([widget.imageFile.path],
                                      text: 'from Leaf Doctor mobile App');
                                },
                                icon: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: const Icon(
                                    Icons.share,
                                    color: Color(0xFF444445),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            extractName(widget.label).replaceAll("_", " "),
                            style: TextStyle(
                              fontFamily: 'Armata',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              height:
                                  1.2, // line height is specified as a multiple of font size
                              color: Color(
                                  0xFF000000), // use hex color code to specify color
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            getPlantHealth(getDiseaseName(widget.label))[1]
                                as String,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              height: 1.176,
                              color: Color.fromRGBO(0, 0, 0, 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.isConnected ? "Online Mode" : "Offline Mode",
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.176,
                              color: widget.isConnected ? Colors.green : Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height:
                                40, // set the height of the parent container
                            child: Column(
                              children: [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
