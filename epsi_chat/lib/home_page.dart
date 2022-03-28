import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'bo/message.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Message> listeMessages = List.empty();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demo liste")),
      body: Column(
        children: [
          _buildListView(),
          buildRowInput()
        ],
      ),
    );
  }

  Container buildRowInput() {
    return Container(
      decoration: BoxDecoration(color : Theme.of(context).primaryColor),
      child: Row(
        children: [
          Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  //TODO rajouter un controller (TextEditingController)
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Tappez un nouveau message",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              )
          ),
          TextButton(
            //TODO A l'appui sur le bouton on déclenche une méthode d'envoi de message
              onPressed: (){},
              child: Icon(Icons.send,color: Colors.white,)
          )
        ]
        ,),
    );
  }
  //Méthode d'envoi de message
  //TODO on prépare une requête "post" avec comme header l'authorization

  //ET comme body {"content": <LE CONTENU DU TEC>}
  //TODO Lorsque le serveur répond 200
    //TODO ALORS On récupère le body, on le désérialize en Message
    //TODO On rajoute le msg à la liste

  Expanded _buildListView() {
    return Expanded(
      child: ListView.separated(
        itemCount: listeMessages.length,
        separatorBuilder: (context, index)=> Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(listeMessages[index].author!.username),
                Spacer(),
                Text(listeMessages[index].created_at!.minute.toString(),
                  style: TextStyle(fontSize: 10.0,)),
              ],
            ),
            subtitle: Text(listeMessages[index].content,),
          );
        },
      ),
    );
  }

  _getMessages() async{
    var storage = FlutterSecureStorage();
    String? jwt = await storage.read(key: "jwt");
    var responseMessages = await http.get(
        Uri.parse("https://flutter-learning.mooo.com/messages"),
        headers: <String, String>{
          "Authorization": "Bearer " + jwt.toString()
          },
    );
    if(responseMessages.statusCode == 200){
      print(responseMessages.body.toString());
      List mapMessages = jsonDecode(responseMessages.body);
      listeMessages = mapMessages.map((i) => Message.fromJson(i)).toList();
      _reloadListView(listeMessages);
      listeMessages.forEach((element) {
        print(element.content);
      });
    }
  }

  _reloadListView(List<Message> msgs){
    setState(() {
      listeMessages = msgs;
    });
  }
}