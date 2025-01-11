import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:greentag/globals.dart';
import 'package:intl/intl.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final CollectionReference _documents =
      FirebaseFirestore.instance.collection('Documents');

  DateTime? _selectedDate;
  String? _selectedWasteType;

  Stream<QuerySnapshot> _buildQuery() {
    Query query = _documents.orderBy('submissionDate', descending: true);

    if (_selectedDate != null) {
      // Convert DateTime to Timestamp for Firestore
      DateTime startDateTime = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      DateTime endDateTime = startDateTime.add(Duration(days: 1));

      Timestamp startTimestamp = Timestamp.fromDate(startDateTime);
      Timestamp endTimestamp = Timestamp.fromDate(endDateTime);

      // Add filtering condition to query
      query = query
          .where('submissionDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('submissionDate', isLessThan: endTimestamp);
    }

    if (_selectedWasteType != null) {
      // Add another filtering condition to query
      print(_selectedWasteType);
      query = query.where('wasteType', isEqualTo: _selectedWasteType);
    }
    print('Query: ${query.toString()}');

    return query.snapshots();
  }

  Future<String> getImageUrl(String docId) async {
    String downloadURL;
    try {
      downloadURL = await FirebaseStorage.instance
          .ref('images/$docId.jpg')
          .getDownloadURL();
    } catch (e) {
      downloadURL = ''; // handle error or use a placeholder image URL
    }
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Row(
          children: [
            Image.asset(
              'images/icon/icon.png',
              width: getWidth(context, 2),
            ),
            const Text(
              '   Eco',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  color: Colors.black),
            ),
            const Text(
              ' Rover',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  color: Colors.green),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: const Text("Filter by Date"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: DropdownButton<String>(
                value: _selectedWasteType,
                hint: const Text("Filter by Waste Type"),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWasteType = newValue;
                  });
                },
                items: <String>['Plastic', 'Paper', 'Electronics', 'Aluminium']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )
            // Waste Type Dropdown
            ,
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _selectedDate = null;
                  _selectedWasteType = null;
                });
              },
              child: const Text(
                "Remove Filters",
                style: TextStyle(color: Colors.red),
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Snapshot Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Submissions Found'));
                }

                // Extract docs from snapshot
                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                return Column(
                  children: [
                    // Date Picker Button

                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final submissionTime =
                              (data['submissionDate'] as Timestamp).toDate();
                          return Container(
                            decoration: BoxDecoration(
                                color: containerColor,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.yellow, width: 2)),
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            // Light grey background color
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display data
                                Row(
                                  children: [
                                    // Image
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 200,
                                      child: FutureBuilder<String>(
                                        // Future to get the image URL
                                        future: getImageUrl(doc.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child: SizedBox(
                                                width: 50,
                                                height: 50,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return const Icon(
                                                Icons.image_not_supported);
                                          }
                                          return CachedNetworkImage(
                                            imageUrl: snapshot.data!,
                                            placeholder: (context, url) =>
                                                const SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Icon(Icons.image_rounded),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            fit: BoxFit.cover,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Image(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                            errorListener: (exception) {
                                              print(
                                                  'Error Loading Image: $exception');
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    // Details
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Username: ${data['userName']}',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Location: ${data['currentAddress']}',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Date: ${DateFormat('d MMM yyyy').format(submissionTime)}',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Waste Type: ${data['wasteType']}', // assuming 'wasteType' key exists in your data
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
