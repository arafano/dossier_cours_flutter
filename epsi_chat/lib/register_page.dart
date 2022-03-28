import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController tecUsername = new TextEditingController();
  TextEditingController tecEmail = new TextEditingController();
  TextEditingController tecPassword = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Enregistrement")),
      body: _buildColumnFields()
    );
  }

  Widget _buildColumnFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Spacer(),
          TextField(
            controller: tecUsername,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              label: Text('Nom d\'utilisateur'),
              prefixIcon: Icon(Icons.person)
            ),
          ),
          TextField(
            controller: tecEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              label: Text('e-mail'),
              prefixIcon: Icon(Icons.email)
            ),
          ),
          TextField(
            controller: tecPassword,
            textInputAction: TextInputAction.done,
            obscureText: true,
            decoration: InputDecoration(
              label: Text('Mot de passe'),
              prefixIcon: Icon(Icons.password)
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onRegister,
              child: Text('S\'ENREGISTRER'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onLoginPage,
              child: Text('DÉJA UN COMPTE? S\'IDENTIFIER'),
            ),
          ),
          Spacer()
        ],
      ),
    );
  }


  _onRegister() async {
    print('username : $tecUsername');
    print('email : $tecEmail');
    print('pwd : $tecPassword');
    //Récupération des champs
    String userName = tecUsername.text;
    String email = tecEmail.text;
    String password = tecPassword.text;
    //Préparation de la requête à énvoyer au serveur

    try{
      var responseRegister = await http.post(
        Uri.parse("https://flutter-learning.mooo.com/auth/local/register"),
        body: {
          "username": userName,
          "email": email,
          "password": password,
        }
      );
      if(responseRegister.statusCode == 200){
        //Informer l'utilisateur du succès de la requête
        SnackBar snackBarSuccess  = new SnackBar(content: Text("Enregistrement réussie"));
        ScaffoldMessenger.of(context).showSnackBar(snackBarSuccess);
        //Vider nos TextField
        tecUsername.clear();
        tecEmail.clear();
        tecPassword.clear();
      } else  if (responseRegister.statusCode >0){
        //Si le serveur répond autre chose que 200 alors on affiche le status
        SnackBar snackBarFailure  = new SnackBar(content: Text("erreur : " + responseRegister.statusCode.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBarFailure);
      }
    } on SocketException catch (socketException){
      //On affiche un message lorsque le serveur est inatteignable (erreur de connexion
      SnackBar snackBarFailure = new SnackBar(content: Text("Nous avons des difficultés à joindre le serveur"));
      ScaffoldMessenger.of(context).showSnackBar(snackBarFailure);
    }
  }

  void _onLoginPage() {
    Navigator.pushNamed(context,'/login');
  }
}
