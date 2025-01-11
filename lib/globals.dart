library globals;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

String userName = '';
late Position currentPosition;
String currentAddress = '';
Color backgroundColor = const Color(0xFFE8F5FF);
// Color containerColor = const Color(0xFFffd64f).withOpacity(0.8);
Color containerColor = Colors.grey.shade100;

double getWidth(BuildContext context, percentage) {
  return (MediaQuery.of(context).size.width * percentage) / 100;
}

double getHeight(BuildContext context, percentage) {
  return (MediaQuery.of(context).size.height * percentage) / 100;
}
