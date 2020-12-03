import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:juggernaut/sides/connection/connectionClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketConnection implements Connection {
  final Socket socket;

  ConnectionClient client;

  SocketConnection(this.socket, BuildContext context) {
    this.client = ConnectionClient(this, context);
    this.socket.listen(
          this._onData,
          onDone: () => this._connectionError(),
          onError: (e) => this._connectionError(),
        );
  }

  void _onData(Iterable<int> data) {
    String.fromCharCodes(data).split('}').forEach((messagePart) {
      if (messagePart.isEmpty) {
        return;
      }
      Map<String, dynamic> message = json.decode(messagePart + '}');
      this.client.onMessage(message);
    });
  }

  void _connectionError() {
    this.socket.destroy();
    this.client.onConnectionClosed();
  }

  @override
  void clientClosed() {
    this.socket.write('{}');
    this.socket.flush().then((value) => this.socket.destroy());
  }

  @override
  void sendToServer(Map<String, dynamic> message) {
    this.socket.write(json.encode(message));
  }

  @override
  bool canReset() {
    return false;
  }

  @override
  void reset() {}

  static void connect(BuildContext context) {
    SharedPreferences.getInstance().then((preferences) {
      String defaultConnectHost = preferences.getString('defaultConnectHost');
      String defaultConnectPort = preferences.getString('defaultConnectPort');
      showDialog(
        context: context,
        builder: (context) {
          final hostText = TextEditingController(text: defaultConnectHost);
          final portText = TextEditingController(text: defaultConnectPort);
          return new AlertDialog(
            title: new Text("Connect to partner"),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Text('Select port'),
                  TextField(
                    controller: portText,
                    decoration: InputDecoration(labelText: "Port"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  Text('Select host'),
                  TextField(
                    controller: hostText,
                    decoration: InputDecoration(labelText: "Host"),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Connect'),
                onPressed: () {
                  int port = int.parse(portText.text);
                  Socket.connect(hostText.text, port).then((partner) {
                    preferences.setString('defaultConnectHost', hostText.text);
                    preferences.setString('defaultConnectPort', portText.text);
                    SocketConnection(partner, context);
                  });
                },
              ),
            ],
          );
        },
      );
    });
  }
}
