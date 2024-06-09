import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentag/Mobile/signin.dart';
import 'package:greentag/Web/webpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greentag/globals.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eco Rover',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const StartupPage(),
    );
  }
}

// Ensure that after showing the StartupPage for a while, you navigate to the appropriate page:
class StartupPage extends StatefulWidget {
  const StartupPage({Key? key}) : super(key: key);

  @override
  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to the next page after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (kIsWeb) {
        // Navigate to the web page
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const WebPage()));
      } else {
        // Navigate to the mobile homepage
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const signin()));
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb)
              Image.asset(
                'images/icon/icon.png',
                width: getWidth(context, 10),
              )
            else
              Image.asset(
                'images/icon/icon.png',
                width: getWidth(context, 50),
              ),

            const SizedBox(height: 5),
            const Text(
              'A Project By SISAD',
              style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            // Optionally, you can add a loading indicator below the image
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
