import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greentag/globals.dart' as global;
import 'package:greentag/globals.dart';

class Submissions extends StatefulWidget {
  const Submissions({super.key});

  @override
  State<Submissions> createState() => _SubmissionsState();
}

class _SubmissionsState extends State<Submissions> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool showDetails = false;
  String? selectedWasteType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        actions: [
          DropdownButton<String>(
            elevation: 8,
            underline: Container(),
            iconSize: 30,
            borderRadius: BorderRadius.circular(10),
            iconEnabledColor: Colors.red,
            icon: const Icon(Icons.filter_list_rounded),
            value: selectedWasteType,
            items: <String>[
              'Plastic',
              'Paper',
              'Aluminium',
              'Electronics',
              'Organic'
            ] // Add all your waste types here
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedWasteType = newValue;
              });
            },
          ),
        ],
        title: const Row(
          children: [
            Text(
              'My',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Colors.black),
            ),
            Text(
              ' Submissions',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Colors.green),
            )
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: selectedWasteType == null
            ? _firestore
                .collection('Documents')
                .where('userName', isEqualTo: global.userName)
                .snapshots()
            : _firestore
                .collection('Documents')
                .where('userName', isEqualTo: global.userName)
                .where('wasteType', isEqualTo: selectedWasteType)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Submissions Found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    FutureBuilder<String>(
                      future: _loadImageUrl(doc.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Icon(Icons.image_not_supported);
                        }
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeIn,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.yellow, width: 3),
                            borderRadius:
                                BorderRadius.circular(20), // Add this line
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data!, scale: 100),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        color: Colors.red,
                        child: Text(
                          doc['wasteType'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        (doc.data() as Map<String, dynamic>)
                                .containsKey('currentAddress')
                            ? doc['currentAddress']
                            : "Address Not Available", // Using null-aware access
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _loadImageUrl(String docId) async {
    try {
      final downloadUrl =
          await _firebaseStorage.ref('images/$docId.jpg').getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Handle error accordingly
      return '';
    }
  }
}
