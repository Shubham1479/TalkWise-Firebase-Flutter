import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shubham_flutter/helper/helper_function.dart';
import 'package:shubham_flutter/pages/login_page.dart';
import 'package:shubham_flutter/pages/profile_page.dart';
import 'package:shubham_flutter/pages/search_page.dart';
import 'package:shubham_flutter/service/auth_service.dart';
import 'package:shubham_flutter/service/datebase_services.dart';
import 'package:shubham_flutter/widgets/group_tile.dart';
import 'package:shubham_flutter/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName='';
  String email='';
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading= false;
  String groupName='';


  @override
  void initState(){
    super.initState();
    gettingUserData();
  }

  // string manipulation
  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }
  

  gettingUserData() async{
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    //getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (){
            nextScreen(context, const SearchPage());
          }, icon:Icon(Icons.search) )
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Groups",style: TextStyle(
            fontSize: 27, fontWeight: FontWeight.bold),),
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
             Text(userName, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
             SizedBox(height: 30,),
             Divider(
               height: 2,
             ),
             ListTile(
               onTap: (){},
               selectedColor: Theme.of(context).primaryColor,
               selected: true,
               contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
               leading: const Icon(Icons.group),
               title: const Text('Groups',
                 style: TextStyle(color: Colors.black),),
             ),
             ListTile(
               onTap: (){
                 nextScreenReplace(context, ProfilePage(userName: userName,
                 email: email,));
               },
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
      body:
      groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
        return StatefulBuilder(
          builder: (context,setState){
          return AlertDialog(
            title:
            Text('Create A group', textAlign: TextAlign.left,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true ? Center(child: CircularProgressIndicator
                  (color: Theme.of(context).primaryColor,))
                    : TextField(
                  onChanged: (val){
                    setState(() {
                      groupName = val;
                    });
                  },
                    style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(20)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(20)),
                    focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(20)))
                ),
              ],
            ),
            actions: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,),
                child: Text('CANCEL'),),
              ElevatedButton(onPressed: () async{
                if(groupName!=""){
                  setState(() {
                    _isLoading = true;
                  });
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName).
                  whenComplete(() {
                    _isLoading = false;
                  });
                  Navigator.of(context).pop();
                  showSnackBar(context, Colors.green, "Group Created Successfully");
                }
              },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,),
                child: Text('CREATE'),
                )
            ],
          );
        });
        });
  }

  groupList(){
    return StreamBuilder(
      stream: groups,
    builder: (context, AsyncSnapshot snapshot){
      // make some choices
      if(snapshot.hasData){
          if(snapshot.data['groups']!= null) {
              if(snapshot.data['groups'].length!= 0){
                return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context,index){
                    int reverseIndex = snapshot.data['groups'].length-index-1;
                    return GroupTile(
                        groupName: getName(snapshot.data['groups'][reverseIndex]),
                        userName: snapshot.data['fullName'],
                        groupId: getId(snapshot.data['groups'][index]));
                  },
                );
              }else {
                return noGroupWidget();
              }
            }else{
            return noGroupWidget();
          };
      } else{
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      }
    },
    );
  }

  noGroupWidget(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){popUpDialog(context);},
            child: Icon(Icons.add_circle,
            color: Colors.green[650],
            size: 75,),
          ),
          SizedBox(height: 20,),
          Text('Oops Looks Like you have not joined any groups,Tap on the add icon to create a group or you can also search from top search button',
          textAlign: TextAlign.center
          )
        ],
      ),
    );
  }


}

