import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shubham_flutter/pages/message_tile.dart';
import 'package:shubham_flutter/service/datebase_services.dart';
import 'package:shubham_flutter/widgets/widgets.dart';

import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName}) :
        super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin="";

  @override
  void initState(){
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin(){
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin= val;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      centerTitle: true,
       elevation: 0,
       title: Text(widget.groupName),
       backgroundColor: Theme.of(context).primaryColor,
      actions: [
        IconButton(onPressed: (){
          nextScreen(context, GroupInfo(
            groupId: widget.groupId,
            groupName: widget.groupName,
            adminName: admin,
          ));
        }, icon: Icon(Icons.info_outline))
      ],
    ),
      body: Stack(children: <Widget>[
        // chat messagges hjere
        chatMessages(),
        Container(
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 18),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
            child: Row(
              children: [
                Expanded(child: TextFormField(
                  controller: messageController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Send a Message..",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none
                  ),
                )),
                SizedBox(width: 12,),
                GestureDetector(
                  onTap: (){
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(child: Icon(Icons.send_rounded, color: Colors.white,),),
                  ),
                )
              ],
            ),
          ),
        )
      ],),
    );
  }

  chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context,AsyncSnapshot snapshot){
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index){
            return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sentByMe: widget.userName == snapshot.data.docs[index]['sender']);
          },
        ) : Container();
      },
    );
  }

  sendMessage(){
    if(messageController.text.isNotEmpty){
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender" : widget.userName,
        "time" : DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
