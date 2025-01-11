// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greentag/Mobile/homepage.dart';
import 'package:greentag/globals.dart' as global;
import 'package:greentag/globals.dart';

class signin extends StatefulWidget {
  const signin({super.key});

  @override
  State<signin> createState() => _signinState();
}

class _signinState extends State<signin> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false; // Add this line to manage loading state

  Future<void> handleSignInSignUp() async {
    if (_userName.text.length > 3 && _password.text.length > 3) {
      setState(() {
        isLoading = true; // Start loading
      });
      final CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      try {
        final QuerySnapshot result =
            await users.where('username', isEqualTo: _userName.text).get();

        if (result.docs.isEmpty) {
          // Username doesn't exist, create new user
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('User not found'),
                content: Text('Do you want to create a new user?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await users.add({
                        'username': _userName.text,
                        'password': _password.text, // Warning: Insecure!
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User created!')),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
        } else {
          if (result.docs.first['password'] == _password.text) {
            // User exists and password matches
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User signed in!')),
            );
            global.userName = _userName.text;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Incorrect Password Entered'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } catch (error) {
        // Handle any errors here, e.g., show a dialog or snackbar
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred!')),
        );
      } finally {
        setState(() {
          isLoading = false; // End loading
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incorrect Entry'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: null,
      body: SafeArea(
          child: Center(
        widthFactor: 20,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/icon/icon.png',
                width: getWidth(context, 30),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'From snap to Sustainability -',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.black),
                    ),
                    Text(
                      ' GeoTag with Responsibility',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.green),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: TextField(
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 1,
                  controller: _userName,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: containerColor,
                    focusColor: containerColor,
                    hoverColor: containerColor,
                    alignLabelWithHint: true,
                    labelText: 'Username',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: TextField(
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 1,
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: containerColor,
                    focusColor: containerColor,
                    hoverColor: containerColor,
                    alignLabelWithHint: true,
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed:
                    isLoading ? null : handleSignInSignUp, // Disable if loading
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(global.getWidth(context, 50),
                      global.getHeight(context, 7)),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Sign In/ Sign Up'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    '(If username does not exist, new username will automatically be created)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
