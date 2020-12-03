import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:serverlobby/serverlobby.dart';
import 'package:juggernaut/sides/connection/connectionClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketServerLobby extends ServerLobby {
  final ServerSocket server;

  SocketServerLobby(this.server, BuildContext context) {
    this.server.listen((socket) => this.startConnection(RemoteServerConnection(socket, this)));
    this.startConnection(LocalServerConnection(this, context));
  }

  static void host(BuildContext rootContext) {
    SharedPreferences.getInstance().then((preferences) {
      String defaultHostPort = preferences.getString('defaultHostPort');
      showDialog(
        context: rootContext,
        builder: (dialogContext) {
          final portText = TextEditingController(text: defaultHostPort);
          return new AlertDialog(
            title: new Text("Select port"),
            content: TextField(
              controller: portText,
              decoration: InputDecoration(labelText: "Port"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Host'),
                onPressed: () {
                  int port = int.parse(portText.text);
                  ServerSocket.bind('0.0.0.0', port).then((server) {
                    Navigator.of(dialogContext).pop();
                    preferences.setString('defaultHostPort', portText.text);
                    SocketServerLobby(server, rootContext);
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

class RemoteServerConnection implements ServerConnection {
  final Socket remote;
  final SocketServerLobby lobby;

  RemoteServerConnection(this.remote, this.lobby) {
    this.remote.listen(
          this.onData,
          onDone: () => this.clientClosed(),
          onError: (e) => this.clientClosed(),
        );
  }

  void onData(Iterable<int> data) {
    String.fromCharCodes(data).split('}').forEach((messagePart) {
      if (messagePart.isEmpty) {
        return;
      } else if (messagePart == '{') {
        this.clientClosed();
      } else {
        Map<String, dynamic> message = json.decode(messagePart + '}');
        this.lobby.onMessage(this, message);
      }
    });
  }

  void clientClosed() {
    this.remote.destroy();
    this.lobby.connectionClosed(this);
  }

  @override
  void serverClosed() {
    this.remote.destroy();
  }

  @override
  void sendToClient(Map<String, dynamic> message) {
    this.remote.write(json.encode(message));
  }
}

class LocalServerConnection implements Connection, ServerConnection {
  final SocketServerLobby lobby;

  ConnectionClient client;

  LocalServerConnection(this.lobby, BuildContext context) {
    this.client = ConnectionClient(this, context);
  }

  @override
  void clientClosed() {
    this.lobby.closeServer();
    this.lobby.server.close();
    this.client = null;
  }

  @override
  void serverClosed() {
    // Change started because page returned, dont do anything
  }

  @override
  void sendToServer(Map<String, dynamic> message) {
    this.lobby.onMessage(this, message);
  }

  @override
  void sendToClient(Map<String, dynamic> message) {
    this.client.onMessage(message);
  }

  @override
  bool canReset() {
    return true;
  }

  @override
  void reset() {
    this.lobby.onReset();
  }
}
