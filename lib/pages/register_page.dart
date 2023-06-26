import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shubham_flutter/helper/helper_function.dart';
import 'package:shubham_flutter/pages/home_page.dart';
import 'package:shubham_flutter/pages/login_page.dart';
import 'package:shubham_flutter/service/auth_service.dart';

import '../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  String email="";
  String fullName="";
  String password="";
  bool _isLoading= false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)) : SingleChildScrollView(
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
                const Text("Create your Account to Chat and Explore!", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                Image.asset('assets/img/register.png',
                ),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person,
                          color: Theme.of(context).primaryColor)),
                  onChanged: (val){
                    setState(() {
                      fullName = val;
                    });
                  },
                  // checking the validation of email
                  validator: (val){
                    if(val!.isNotEmpty){
                      return null;
                    }
                    else {
                      return 'Name cannot be empty';
                    }
                  }
                ),
                SizedBox(height:5,),
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
                        register();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          )
                      ),
                      child: Text("Register",style: TextStyle(color: Colors.white,fontSize: 16),)),
                ),
                SizedBox(height: 5,),
                Text.rich(
                    TextSpan(
                      text: "Already have an Acoount?",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()..onTap=(){
                            nextScreen(context, const LoginPage());
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

  register() async{
     if(formKey.currentState!.validate()) {
       setState(() {
         _isLoading= true;
       });
       await authService.registerUserWithEmailandPassword(fullName, email, password).then((value)async{
         if(value == true) {
            // saving the shared preference state
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
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
