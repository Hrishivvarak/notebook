import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notebook/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notebook/firebase_options.dart';
import 'package:notebook/screens/signin.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot)
      {
        if(snapshot.connectionState == ConnectionState.waiting)
          {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return Signin();
        }
      }),
    );
  }
}

