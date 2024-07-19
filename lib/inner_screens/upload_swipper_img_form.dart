import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class UploadSwipperImgForm extends StatefulWidget {
  const UploadSwipperImgForm({super.key});

  @override
  _UploadSwipperImgFormState createState() => _UploadSwipperImgFormState();
}

class _UploadSwipperImgFormState extends State<UploadSwipperImgForm> {
  List<Uint8List> _images = [];
  bool _isUploading = false;

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<Uint8List> imageBytesList = [];
      for (var pickedFile in pickedFiles) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        imageBytesList.add(imageBytes);
      }
      setState(() {
        _images = imageBytesList;
      });
    }
  }

  Future<void> deletePreviousImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final CollectionReference imagesCollection = FirebaseFirestore.instance.collection('banner');
    final QuerySnapshot querySnapshot = await imagesCollection.where('uid', isEqualTo: user.uid).get();
    for (var doc in querySnapshot.docs) {
      final String imageUrl = doc['url'];
      final Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
      await doc.reference.delete();
    }
  }

  Future<void> uploadImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to upload images')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    await deletePreviousImages();

    List<String> imageUrls = [];
    for (var image in _images) {
      final String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('banner')
          .child("$imageName.jpg");
      await storageRef.putData(image);
      final String downloadUrl = await storageRef.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    await saveImageUrls(imageUrls);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successful')),
    );

    Navigator.pop(context);

    setState(() {
      _isUploading = false;
    });
  }

  Future<void> saveImageUrls(List<String> urls) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final CollectionReference imagesCollection =
    FirebaseFirestore.instance.collection('banner');
    for (var url in urls) {
      await imagesCollection.add({'uid': user.uid, 'url': url});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Upload'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: pickImages,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, primary: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 5,
                      ),
                      child: const Text('Pick Images'),
                    ),
                    ElevatedButton(
                      onPressed: _isUploading ? null : uploadImages,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, primary: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 5,
                      ),
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _images.isEmpty
                    ? const Center(child: Text('No images selected.'))
                    : ImageGrid(_images),
              ),
            ],
          ),
          // Conditionally show circular progress indicator
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final List<Uint8List> images;

  const ImageGrid(this.images, {super.key});

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) =>
          Image.memory(images[index]),
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(2),
    );
  }
}
