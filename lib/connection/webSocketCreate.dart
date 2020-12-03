import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:juggernaut/connection/webSocketHost.dart';
import 'package:juggernaut/connection/webSocketJoin.dart';

class WebSocketCreate {
  static void startCreate(BuildContext rootContext, String name, String password) {
    final body = json.encode({'name': name, 'password': password});
    http.post('${WebServer.http}://${WebServer.host}/create', body: body).then((value) {
      WebSocketConnection.startConnection(rootContext, name, password, true);
    }, onError: (e) => print(e));
  }

  static void create(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (context) {
        final passText = TextEditingController();
        final nameText = TextEditingController();
        return new AlertDialog(
          title: new Text("Create Lobby"),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Text('Select name'),
                TextField(
                  controller: nameText,
                  decoration: InputDecoration(labelText: "Name"),
                  keyboardType: TextInputType.name,
                ),
                Text('Select password'),
                TextField(
                  controller: passText,
                  decoration: InputDecoration(labelText: "Password"),
                  keyboardType: TextInputType.name,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Connect'),
              onPressed: () => WebSocketCreate.startCreate(rootContext, nameText.text, passText.text),
            ),
          ],
        );
      },
    );
  }
}
