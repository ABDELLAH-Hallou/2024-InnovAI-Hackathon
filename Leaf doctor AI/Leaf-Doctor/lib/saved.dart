import 'dart:io';

import 'package:Leaf_Doctor/savedDetails.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'DatabaseHelper.dart';
import 'result.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  Future<List<Map<String, dynamic>>>? _dataListFuture;

  @override
  void initState() {
    super.initState();
    _dataListFuture = _getData();
  }

  Future<List<Map<String, dynamic>>> _getData() async {
    final databaseHelper = DatabaseHelper();
    final dataList = await databaseHelper.getData();
    return dataList;
  }

  String _getLabel(String plantName, String deseaseName){
    return plantName + '___'+ deseaseName.replaceAll(" ", "_");
  }

  void _showPreview(BuildContext context, Map<String, dynamic> data) {
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
            return SavedResultPreviewBottomSheet(
              id: data['id'],
                imageFile: File(data['image']),
                scrollController: scrollController,
                leafName: data['leaf_name'],
                diseaseName: data['disease_name']);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Saved',
          style: TextStyle(
            fontFamily: 'Armata',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF444445),
          ),
        ),
        elevation: 1,
        iconTheme: IconThemeData(
          color: Color(0xFF444445),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dataListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred.'));
          } else {
            final dataList = snapshot.data;
            return ListView.builder(
              itemCount: dataList!.length,
              itemBuilder: (context, index) {
                final data = dataList[index];
                return GestureDetector(
                  onTap: () => _showPreview(context, data),
                  child: ListTile(
                    leading: Image.file(
                      File(data['image']),
                      width: 50,
                      height: 50,
                    ),
                    title: Text(data['leaf_name']),
                    subtitle: Text(data['status']),
                    trailing: Text(data['disease_name'] ?? ''),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
