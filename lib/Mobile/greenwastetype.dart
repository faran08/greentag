// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:greentag/Mobile/SubmitPage.dart';
// import 'package:greentag/Mobile/rewardsPage.dart';
// import 'package:greentag/Mobile/signin.dart';
// import 'package:greentag/Mobile/submissions.dart';
// import 'package:greentag/globals.dart';
// import 'package:location/location.dart' as locEnabler;
// import 'package:greentag/globals.dart' as global;

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Position _currentPosition;
//   late String _currentAddress = 'Loading Location';
//   late String _LatLong = 'Loading Coordinates';

//   String constructAddress({
//     String? name,
//     String? thoroughfare,
//     String? subLocality,
//     String? locality,
//     String? administrativeArea,
//     String? country,
//   }) {
//     List<String> addressParts = [
//       name!,
//       thoroughfare!,
//       subLocality!,
//       locality!,
//       administrativeArea!,
//       country!,
//     ];

//     return addressParts.where((part) => part.isNotEmpty).join(', ');
//   }

//   Future<bool> enableLocationService() async {
//     locEnabler.Location location = locEnabler.Location();

//     bool _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return false;
//       }
//     }
//     return true;
//   }

//   _locateUser() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Handle location service not enabled.
//       bool _locationPermission = await enableLocationService();
//       if (!_locationPermission) {
//         return Future.error('Location services are disabled.');
//       }
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     _currentPosition = await Geolocator.getCurrentPosition();
//     _getAddressFromLatLng();
//   }

//   _getAddressFromLatLng() async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//           _currentPosition.latitude, _currentPosition.longitude);

//       Placemark place = placemarks[0];

//       setState(() {
//         global.currentPosition = _currentPosition;

//         _LatLong =
//             '(${_currentPosition.latitude}, ${_currentPosition.longitude})';
//         _currentAddress = constructAddress(
//           name: place.name,
//           thoroughfare: place.thoroughfare,
//           subLocality: place.subLocality,
//           locality: place.locality,
//           administrativeArea: place.administrativeArea,
//           country: place.country,
//         );
//         global.currentAddress = _currentAddress;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (context.mounted) {
//       _locateUser();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const RewardsPage()),
//                     );
//                   },
//                   icon: const Icon(Icons.generating_tokens_rounded,
//                       size: 40, weight: 10, color: Colors.blue)),
//               const SizedBox(
//                   width:
//                       4), // Optional: for spacing between the icon and number
//               // Your Logout Icon
//               IconButton(
//                 onPressed: () {
//                   global.userName = '';
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const signin()),
//                   );
//                 },
//                 icon: const Icon(
//                   Icons.logout_rounded,
//                   color: Colors.red,
//                   size: 30,
//                 ),
//               ),
//             ],
//           ),
//         ],
//         title: Row(
//           children: [
//             Image.asset(
//               'images/icon/icon.png',
//               width: getWidth(context, 10),
//             ),
//             const Text(
//               '   Eco',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 25,
//                   color: Colors.black),
//             ),
//             const Text(
//               ' Rover',
//               style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 25,
//                   color: Colors.green),
//             )
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
//                 child: Text(
//                   'Select GeoTag Green Waste Type',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SubmitPage(
//                                   wasteType: 'Plastic',
//                                 )),
//                       );
//                     },
//                     child: Container(
//                       width: getWidth(context, 40),
//                       height: getHeight(context, 20),
//                       padding: const EdgeInsets.all(
//                           0), // Providing spacing inside the container
//                       decoration: BoxDecoration(
//                         color:
//                             containerColor, // Changing the color to light grey
//                         borderRadius:
//                             BorderRadius.circular(15), // Adding rounded edges
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             'images/WaterBottle.png', // Specify the path to your image
//                             width: getWidth(context, 20),
//                             height: getHeight(context, 15),
//                           ),
//                           const Text(
//                             "Plastic",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SubmitPage(
//                                   wasteType: 'Paper',
//                                 )),
//                       );
//                     },
//                     child: Container(
//                       width: getWidth(context, 40),
//                       height: getHeight(context, 20),
//                       padding: const EdgeInsets.all(
//                           0), // Providing spacing inside the container
//                       decoration: BoxDecoration(
//                         color:
//                             containerColor, // Changing the color to light grey
//                         borderRadius:
//                             BorderRadius.circular(15), // Adding rounded edges
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             'images/paper.png', // Specify the path to your image
//                             width: getWidth(context, 20),
//                             height: getHeight(context, 15),
//                           ),
//                           const Text(
//                             "Paper",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const SubmitPage(
//                                     wasteType: 'Aluminium',
//                                   )),
//                         );
//                       },
//                       child: Container(
//                         width: getWidth(context, 40),
//                         height: getHeight(context, 20),
//                         padding: const EdgeInsets.all(
//                             0), // Providing spacing inside the container
//                         decoration: BoxDecoration(
//                           color:
//                               containerColor, // Changing the color to light grey
//                           borderRadius:
//                               BorderRadius.circular(15), // Adding rounded edges
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 5,
//                               blurRadius: 7,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'images/aluminium.png', // Specify the path to your image
//                               width: getWidth(context, 20),
//                               height: getHeight(context, 15),
//                             ),
//                             const Text(
//                               "Aluminium",
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const SubmitPage(
//                                     wasteType: 'Electronics',
//                                   )),
//                         );
//                       },
//                       child: Container(
//                         width: getWidth(context, 40),
//                         height: getHeight(context, 20),
//                         padding: const EdgeInsets.all(
//                             0), // Providing spacing inside the container
//                         decoration: BoxDecoration(
//                           color:
//                               containerColor, // Changing the color to light grey
//                           borderRadius:
//                               BorderRadius.circular(15), // Adding rounded edges
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 5,
//                               blurRadius: 7,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'images/electronics.png', // Specify the path to your image
//                               width: getWidth(context, 20),
//                               height: getHeight(context, 15),
//                             ),
//                             const Text(
//                               "Electronics",
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const Padding(
//                 padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//                 child: Divider(color: Colors.grey),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const Submissions()),
//                   );
//                 },
//                 child: Container(
//                   width: getWidth(context, 50),
//                   height: getHeight(context, 20),
//                   padding: const EdgeInsets.all(
//                       0), // Providing spacing inside the container
//                   decoration: BoxDecoration(
//                     color: containerColor, // Changing the color to light grey
//                     borderRadius:
//                         BorderRadius.circular(15), // Adding rounded edges
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 5,
//                         blurRadius: 7,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         'images/done.png', // Specify the path to your image
//                         width: getWidth(context, 20),
//                         height: getHeight(context, 15),
//                       ),
//                       const Text(
//                         "My Submissions",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         color: containerColor.withOpacity(0.6),
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _currentAddress,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             Text(
//               _LatLong,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
