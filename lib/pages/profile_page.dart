import 'package:flutter/material.dart';
import 'package:shubham_flutter/pages/home_page.dart';
import 'package:shubham_flutter/service/auth_service.dart';

import '../widgets/widgets.dart';
import 'login_page.dart';


class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({Key? key, required this.userName, required this.email}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 27),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[600],
            ),
            SizedBox(height:15),
            Text(
              widget.userName, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 30,),
            Divider(
              height: 2,
            ),
            ListTile(
              onTap: (){
                nextScreen(context, HomePage());
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text('Groups',
                style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: (){},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text('Profile',
                style: TextStyle(color: Colors.black),),
            ), ListTile(
              onTap: () async{
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: Text('logout'),
                        content: Text('DO you Really wanna Logout'),
                        actions: [
                          IconButton(onPressed: (){
                            Navigator.pop(context);
                          }, icon: Icon(
                            Icons.cancel,
                            color: Colors.red,)),
                          IconButton(onPressed: ()async{
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> LoginPage()),
                                    (route) => false);
                          }, icon: Icon(
                            Icons.done,
                            color: Colors.green,))
                        ],
                      );
                    });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout',
                style: TextStyle(color: Colors.black),),
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey[600],
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Full Name", style: TextStyle(fontSize: 17),),
                Text(widget.userName, style: TextStyle(fontSize: 17),),
              ],
            ),
            Divider(
               height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Emaiil", style: TextStyle(fontSize: 17),),
                Text(widget.email, style: TextStyle(fontSize: 17),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
