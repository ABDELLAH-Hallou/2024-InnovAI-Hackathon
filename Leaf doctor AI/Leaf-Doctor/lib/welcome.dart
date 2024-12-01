import 'dart:io';
import 'package:Leaf_Doctor/settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:Leaf_Doctor/camera.dart';
import 'package:Leaf_Doctor/forum.dart';
import 'package:Leaf_Doctor/saved.dart';
import 'package:Leaf_Doctor/test.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA3FFB4),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add logo here
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/logo_n.png',
              height: 120.0,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 75),
            child: ElevatedButton(
              onPressed: () {
                // Handle camera button tap
                print('Camera button tapped');
                // navigate to the camera screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC9EFC7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: const Icon(Icons.camera_alt,
                    size:48,
                        color: Color(0xFF444445)
                    ),
                    // Image.asset(
                    //   'assets/images/icons/camera.png',
                    //   width: 48,
                    //   height: 48,
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'CAMERA',
                      style: TextStyle(
                        fontFamily: 'Armata',
                        color: Color(0xFF454545),
                        fontSize: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height:10),
          Container(
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 75),
            child: ElevatedButton(
              onPressed: () {
                // Handle camera button tap
                print('Forum button tapped');
                // navigate to the camera screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForumPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC9EFC7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: const Icon(Icons.forum,
                        size:48,
                        color: Color(0xFF444445)
                    ),
                    // Image.asset(
                    //   'assets/images/icons/camera.png',
                    //   width: 48,
                    //   height: 48,
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'FORUM',
                      style: TextStyle(
                        fontFamily: 'Armata',
                        color: Color(0xFF454545),
                        fontSize: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 75),
            child: ElevatedButton(
              onPressed: () {
                // Handle camera button tap
                print('Saved button tapped');
                // navigating to a test page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC9EFC7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: const Icon(Icons.bookmark,
                        size:48,color:Color(0xFF444445)),
                    // Image.asset(
                    //   'assets/images/icons/saved.png',
                    //   width: 48,
                    //   height: 48,
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'SAVED',
                      style: TextStyle(
                        fontFamily: 'Armata',
                        color: Color(0xFF454545),
                        fontSize: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 75),
            child: ElevatedButton(
              onPressed: () {
                // Handle camera button tap
                print('Catalog button tapped');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC9EFC7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: const Icon(Icons.text_snippet,
                        size:48,color:Color(0xFF444445)),
                    // Image.asset(
                    //   'assets/images/icons/catalog.png',
                    //   width: 48,
                    //   height: 48,
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'CATALOG',
                      style: TextStyle(
                        fontFamily: 'Armata',
                        color: Color(0xFF454545),
                        fontSize: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(height: 10),
          // Container(
          //   height: 65,
          //   padding: EdgeInsets.symmetric(horizontal: 75),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // Handle camera button tap
          //       print('Train button tapped');
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Color(0xFFC9EFC7),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20),
          //         side: BorderSide(color: Colors.black),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.only(left: 12.0),
          //           child: const Icon(Icons.memory,
          //               size:48,color:Color(0xFF444445)),
          //           // Image.asset(
          //           //   'assets/images/icons/AI.png',
          //           //   width: 48,
          //           //   height: 48,
          //           // ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 12.0),
          //           child: Text(
          //             'TRAIN',
          //             style: TextStyle(
          //               fontFamily: 'Armata',
          //               color: Color(0xFF454545),
          //               fontSize: 26,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: 10),
          Container(
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 75),
            child: ElevatedButton(
              onPressed: () {
                // Handle camera button tap
                print('settings button tapped');
                // navigating to a test page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC9EFC7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: const Icon(Icons.settings,
                        size:48,color:Color(0xFF444445)),
                    // Image.asset(
                    //   'assets/images/icons/settings.png',
                    //   width: 48,
                    //   height: 48,
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontFamily: 'Armata',
                        color: Color(0xFF454545),
                        fontSize: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),

          Text(
            '@ 2024 LeafDoctorAI. All rights reserved',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
