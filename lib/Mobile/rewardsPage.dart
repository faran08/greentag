import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greentag/globals.dart';
import 'package:shimmer/shimmer.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rewards",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(
                        'Documents') // Replace with actual collection name
                    .where('userName', isEqualTo: userName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final int coins = docs.length * 10; // Calculating coins

                  double circleSize = MediaQuery.of(context).size.height * 0.2;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Shimmer.fromColors(
                            period: const Duration(milliseconds: 5000),
                            baseColor: Colors.blue,
                            highlightColor: Colors.lightBlue.shade100,
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '$coins',
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Text(
                  'Redeem your tagging points at your favourite online spot for sustainable items',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate or do something when IKEA image is tapped
                    },
                    child: Container(
                      width: width * 0.4,
                      height: width * 0.4,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 3),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'images/IKEA.png'), // Provide your path
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate or do something when Amazon image is tapped
                    },
                    child: Container(
                      width: width * 0.4,
                      height: width * 0.4,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 3),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'images/amazon.png'), // Provide your path
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // centers the image buttons
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate or do something when IKEA image is tapped
                      },
                      child: Container(
                        width: width * 0.4,
                        height: width * 0.4,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 3),
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                                'images/flipkart.png'), // Provide your path
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate or do something when Amazon image is tapped
                      },
                      child: Container(
                        width: width * 0.4,
                        height: width * 0.4,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 3),
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                                'images/ebay.png'), // Provide your path
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
