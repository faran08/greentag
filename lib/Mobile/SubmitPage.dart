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
  const SubmitPage({Key? key}) : super(key: key);

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _remarksController = TextEditingController();
  late Interpreter _interpreter;
  late List<String> _labels;
  String wasteType = 'Organic';

  // Future<void> _pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     _image = image;
  //   });
  // }

  // Future<void> _pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       _image = image;
  //     });

  //     // Show loading dialog
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return const AlertDialog(
  //           content: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               CircularProgressIndicator(),
  //               SizedBox(width: 20),
  //               Text('Processing Image...'),
  //             ],
  //           ),
  //         );
  //       },
  //     );

  //     // Classify the image
  //     final result = await _classifyImage(File(image.path));

  //     // Dismiss loading dialog and show the result
  //     Navigator.of(context).pop();
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Classification Result'),
  //           content: Text(result ?? 'No result'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    await _handleImageSelection(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await _handleImageSelection(image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitRecyclableType(String selectedWasteType) {
    // Update the state with the selected waste type
    setState(() {
      _remarksController.text = ''; // Reset remarks
    });

    // Add waste type handling logic here
    // For example, set a variable for `wasteType` and use it in submission
    wasteType = selectedWasteType;
    print("Selected Waste Type: $wasteType");
  }

  Future<void> _showOrganicConfirmation() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Organic Waste Detected'),
          content: const Text('The waste has been classified as Organic.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue to submission with "Organic" waste type
                _submitRecyclableType("Organic");
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectRecyclableType() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Recyclable Waste Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset('images/WaterBottle.png', width: 40),
                title: const Text('Plastic'),
                onTap: () {
                  Navigator.of(context).pop();
                  _submitRecyclableType("Plastic");
                },
              ),
              ListTile(
                leading: Image.asset('images/paper.png', width: 40),
                title: const Text('Paper'),
                onTap: () {
                  Navigator.of(context).pop();
                  _submitRecyclableType("Paper");
                },
              ),
              ListTile(
                leading: Image.asset('images/aluminium.png', width: 40),
                title: const Text('Aluminium'),
                onTap: () {
                  Navigator.of(context).pop();
                  _submitRecyclableType("Aluminium");
                },
              ),
              ListTile(
                leading: Image.asset('images/electronics.png', width: 40),
                title: const Text('Electronics'),
                onTap: () {
                  Navigator.of(context).pop();
                  _submitRecyclableType("Electronics");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImageSelection(XFile image) async {
    setState(() {
      _image = image;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("images/load.gif", width: 100),
                const SizedBox(width: 20),
                const Text('Processing Image...'),
              ],
            ),
          );
        },
      );
    }

    // Add a delay before classifying the image
    await Future.delayed(const Duration(seconds: 2));

    // Classify the image
    final result = await _classifyImage(File(image.path));

    // Dismiss the loading dialog
    Navigator.of(context).pop();

    if (result == "Recyclable Waste") {
      _selectRecyclableType(); // Show popup for recyclable type selection
    } else if (result == "Organic Waste") {
      _showOrganicConfirmation(); // Directly confirm as organic waste
    }
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
      'wasteType': wasteType,
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
    print("File path: ${compressedImage.path}");
    print("File exists: ${compressedImage.existsSync()}");
    print("File size: ${compressedImage.lengthSync()} bytes");

    // File imageFile = File(_image!.path);
    // File compressedImage = File(xFile.path);
    try {
      // 1. Get reference to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref('images/${newDoc.id}.jpg');
      print("Storage Reference Created: ${storageRef.fullPath}");

      // 2. Check if file exists before uploading
      if (!compressedImage.existsSync()) {
        throw Exception("File does not exist at path: ${compressedImage.path}");
      }
      print("File Exists: ${compressedImage.path}");

      // 3. Upload file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(compressedImage);
      print("Upload Started...");

      // 4. Monitor the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            "Upload Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%");
      });

      // 5. Wait for upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;
      print(
          "Upload Complete! File available at: ${await storageRef.getDownloadURL()}");

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
          title: const Text('Success'),
          content: const Text('Data and Image submitted successfully!'),
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

    // Resize the image to match the model's input dimensions
    final resizedImage =
        img.copyResize(rawImage, width: inputSize, height: inputSize);

    // Create a Float32List to hold normalized pixel data
    final inputBuffer = Float32List(inputSize * inputSize * 3);
    int index = 0;

    // for (int y = 0; y < inputSize; y++) {
    //   for (int x = 0; x < inputSize; x++) {
    //     final pixel = resizedImage.getPixel(x, y);
    //            inputBuffer[index++] =
    //         (img.getRed(pixel) - 127.5) / 127.5; // Normalize red
    //     inputBuffer[index++] =
    //         (img.getGreen(pixel) - 127.5) / 127.5; // Normalize green
    //     inputBuffer[index++] =
    //         (img.getBlue(pixel) - 127.5) / 127.5; // Normalize blue
    //   }
    // }

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputBuffer[index++] = (pixel.r - 127.5) / 127.5; // Normalize red
        inputBuffer[index++] = (pixel.g - 127.5) / 127.5; // Normalize green
        inputBuffer[index++] = (pixel.b - 127.5) / 127.5; // Normalize blue
      }
    }

    // Return the normalized buffer as Uint8List
    return Uint8List.view(inputBuffer.buffer);
  }

  Future<String?> _classifyImage(File imageFile) async {
    // Get input tensor shape
    final inputShape = _interpreter.getInputTensor(0).shape;
    final inputSize = inputShape[1]; // Height and width of the input

    // Preprocess the image
    final inputBuffer = _preprocessImage(imageFile, inputSize);

    // Prepare the output buffer with the correct shape [1, 1]
    final outputBuffer = List.generate(1, (_) => List.filled(1, 0.0));

    // Run inference
    _interpreter.run(inputBuffer, outputBuffer);

    // Extract the output value
    final double outputValue = outputBuffer[0][0];

    // Interpret the result
    final label = outputValue >= 0.15 ? "Recyclable Waste" : "Organic Waste";
    return label;
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
          title: const Column(
            children: [
              Text(
                'Please Attach Picture',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.black),
              ),
              Text(
                'It will be Geo-tagged automatically',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
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
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _image == null
                      ? Image.asset(
                          "images/addNewImage.png",
                          width: 20,
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
