import 'package:firebase_auth/firebase_auth.dart';
import 'package:shubham_flutter/helper/helper_function.dart';
import 'package:shubham_flutter/service/datebase_services.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//login
  Future logInWithUserNameandPassword (String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password))
          .user!;
      if (user != null) {
        //call our database service to update the data
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }



//register
  Future registerUserWithEmailandPassword(String fullName, String email,
      String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user!;
      if (user != null) {
        //call our database service to update the data
        await DatabaseService(uid: user.uid).savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }


//signout
  Future signOut() async{
    try{
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF('');
      await HelperFunctions.saveUserNameSF('');
      await firebaseAuth.signOut();
    } catch (e){
      return null;
    }
  }


}






