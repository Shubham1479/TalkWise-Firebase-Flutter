import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shubham_flutter/helper/helper_function.dart';
import 'package:shubham_flutter/pages/home_page.dart';
import 'package:shubham_flutter/pages/login_page.dart';
import 'package:shubham_flutter/shared/constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb){
    //running the initialization for the web
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: Constants.apiKey,
        appId: Constants.appId,
        messagingSenderId: Constants.messagingSenderId,
        projectId: Constants.projectId));

  }else{
    // running for web
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async{
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value!=null){
      setState(() {
        _isSignedIn= value;
      });      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? HomePage():LoginPage(),
    );
  }
}
