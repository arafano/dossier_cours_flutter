import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController tecIdentifier = new TextEditingController();
  TextEditingController tecPassword = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Identification")),
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
            controller: tecIdentifier,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              label: Text('Nom Utilisateur ou e-mail'),
              prefixIcon: Icon(Icons.person)
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
              onPressed: _onLogin,
              child: Text('S\'IDENTIFIER'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onRegisterPage,
              child: Text('PAS DE COMPTE? S\'ENREGISTRER'),
            ),
          ),
          Spacer()
        ],
      ),
    );
  }

  void _onLogin() async {
    print('identifiant : $tecIdentifier');
    print('pwd : $tecPassword');
    //R??cup??ration des champs
    String identifiant = tecIdentifier.text;
    String password = tecPassword.text;
    //Pr??paration de la requ??te ?? ??nvoyer au serveur

    try{
      var responseRegister = await http.post(
        Uri.parse("https://flutter-learning.mooo.com/auth/local"),
        body: {
          "identifier": identifiant,
          "password": password,
        }
      );
      if(responseRegister.statusCode == 200){
        //Informer l'utilisateur du succ??s de la requ??te
        SnackBar snackBarSuccess  = new SnackBar(content: Text("Connexion r??ussie"));
        ScaffoldMessenger.of(context).showSnackBar(snackBarSuccess);
        //Vider nos TextField
        tecIdentifier.clear();
        tecPassword.clear();

        _onLoginSuccess(jsonDecode(responseRegister.body)["jwt"]);

      } else  if (responseRegister.statusCode >0){
        //Si le serveur r??pond autre chose que 200 alors on affiche le status
        SnackBar snackBarFailure  = new SnackBar(content: Text("erreur : " + responseRegister.statusCode.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBarFailure);
      }
    } on SocketException catch (socketException){
      //On affiche un message lorsque le serveur est inatteignable (erreur de connexion
      SnackBar snackBarFailure = new SnackBar(content: Text("Nous avons des difficult??s ?? joindre le serveur"));
      ScaffoldMessenger.of(context).showSnackBar(snackBarFailure);
    }
  }

  void _onRegisterPage() {
    Navigator.pushNamed(context,'/register');
  }

  void _onLoginSuccess(String jwt) {
    var storage = FlutterSecureStorage();
    storage.write(key: "jwt", value: jwt);
    Navigator.pushNamed(context,'/home');
  }
}
