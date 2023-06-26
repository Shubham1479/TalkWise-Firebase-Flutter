import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shubham_flutter/pages/register_page.dart';
import 'package:shubham_flutter/service/auth_service.dart';
import 'package:shubham_flutter/service/datebase_services.dart';
import 'package:shubham_flutter/widgets/widgets.dart';

import '../helper/helper_function.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email="";
  String password="";
  bool _isLoading= false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("TalkWise", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)
                  ),
                const Text("Login To see what they are talking about!", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                  Image.asset('assets/img/login.png',
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email,
                      color: Theme.of(context).primaryColor)),
                    onChanged: (val){
                      setState(() {
                        email = val;
                      });
                    },
                    // checking the validation of email
                    validator: (val){
                      return  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val!) ? null:
                      "Plase Enter a valid Email";
                    },
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).primaryColor)),
                    validator: (val){
                      if(val!.length<6){
                        return "password must be atleast 6 characters";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (val){
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  SizedBox( width: double.infinity,
                    child: ElevatedButton(
                        onPressed: (){
                        login();
                    },
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          )
                        ),
                      child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 16),)),
                  ),
                  SizedBox(height: 5,),
                  Text.rich(
                    TextSpan(
                      text: "Dont have an Account yet!?",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                          TextSpan(
                            text: "Register Here",
                            style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap=(){
                              nextScreen(context, const RegisterPage());
                            },
                          )
                      ],
                    )
                  )
                ],
            ),
          ),
        ),
      ),
    );
  }

  login() async{
    if(formKey.currentState!.validate()) {
      setState(() {
        _isLoading= true;
      });
      await authService.logInWithUserNameandPassword(email, password).then((value)async{
        if(value == true) {
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
          // saving the shared preference state
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackBar(context,Colors.red,value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

}
