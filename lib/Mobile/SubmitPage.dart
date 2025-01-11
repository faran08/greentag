// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:greentag/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greentag/globals.dart' as global;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class SubmitPage extends StatefulWidget {
  const SubmitPage({Key? key, required this.wasteType}) : super(key: key);
  final String wasteType;
  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _remarksController = TextEditingController();
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<XFile> compressImage(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    XFile? compressedImageFile;

    compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '$path/img_${DateTime.now().millisecondsSinceEpoch}.jpg',
      minWidth: 500,
      minHeight: 500,
      quality: 88,
    );

    return XFile(compressedImageFile!.path);
  }

  Future<void> _submitData() async {
    if (_image == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select an image first.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );
    // 1. Add a new document to Firestore
    CollectionReference documents =
        FirebaseFirestore.instance.collection('Documents');
    DocumentReference newDoc = await documents.add({
      'remarks': _remarksController.text,
      'wasteType': widget.wasteType,
      'userName': global.userName,
      'currentAddress': global.currentAddress,
      'location': {
        'latitude': global.currentPosition.latitude,
        'longitude': global.currentPosition.longitude,
      },
      'submissionDate': Timestamp.now()
      // other fields...
    });

    // 2. Upload image to Firebase Storage
    XFile compressedXFile = await compressImage(File(_image!.path));
    File compressedImage = File(compressedXFile.path);
    // File imageFile = File(_image!.path);
    // File compressedImage = File(xFile.path);
    try {
      await FirebaseStorage.instance
          .ref('images/${newDoc.id}.jpg')
          .putFile(compressedImage);
      // Close the loading dialog
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      // Handle error, show dialog/alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Failed to submit data to Firestore. Try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (kDebugMode) {
        print(e);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Data and Image submitted successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Load TFLite Model
  Future<void> _loadModel() async {
    try {
      // Load the TensorFlow Lite model
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      // Load labels
      final labelsData =
          await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();

      if (kDebugMode) {
        print('Model and labels loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading model: $e');
      }
    }
  }

  Uint8List _preprocessImage(File imageFile, int inputSize) {
    // Decode the image using the `image` package
    final rawImage = img.decodeImage(imageFile.readAsBytesSync())!;

    // Resize the image to match the input size of the model
    final resizedImage =
        img.copyResize(rawImage, width: inputSize, height: inputSize);

    // Convert the image to a normalized Uint8List
    final inputBuffer = Uint8List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputBuffer[index++] = ((img.getRed(pixel) - 127.5) / 127.5).toInt();
        inputBuffer[index++] = ((img.getGreen(pixel) - 127.5) / 127.5).toInt();
        inputBuffer[index++] = ((img.getBlue(pixel) - 127.5) / 127.5).toInt();
      }
    }
    return inputBuffer;
  }

  Future<String?> _classifyImage(File imageFile) async {
    // Get input tensor shape and prepare buffer
    final inputShape = _interpreter.getInputTensor(0).shape;
    final inputSize =
        inputShape[1]; // Typically height or width for square input

    // Preprocess the image
    final inputBuffer = _preprocessImage(imageFile, inputSize);

    // Prepare output buffer
    final outputBuffer =
        List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    // Run the model
    _interpreter.run(inputBuffer, outputBuffer);

    // Find the label with the highest probability
    final maxProbabilityIndex = outputBuffer[0]
        .indexOf(outputBuffer[0].reduce((a, b) => a > b ? a : b));
    return _labels[maxProbabilityIndex];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Row(
            children: [
              const Text(
                'Submit',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black),
              ),
              Text(
                ' ${widget.wasteType}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.green),
              )
            ],
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _image == null
                      ? const Icon(
                          Icons.add,
                          size: 50,
                          color: Colors.red,
                        )
                      : Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.top,
                maxLines: 5,
                controller: _remarksController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: containerColor,
                  focusColor: containerColor,
                  hoverColor: containerColor,
                  alignLabelWithHint: true,
                  labelText: 'Remarks',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitData();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent, // Foreground color
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
