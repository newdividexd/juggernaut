import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:juggernaut/connection/wsFactory/wsFactory.dart';

import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:juggernaut/connection/webSocketHost.dart';
import 'package:juggernaut/sides/connection/connectionClient.dart';

class WebSocketConnection implements Connection {
  final WebSocketChannel channel;

  ConnectionClient client;

  WebSocketConnection(this.channel, BuildContext context) {
    this.client = ConnectionClient(this, context);
    this.channel.stream.listen(
          this._onData,
          onDone: () => this._connectionError(null),
          onError: (e) => this._connectionError(e),
        );
  }

  void _connectionError(e) {
    this.channel.sink.close(status.goingAway);
    this.client.onConnectionClosed();
  }

  void _onData(dynamic data) {
    this.client.onMessage(json.decode(data));
  }

  @override
  void clientClosed() {
    this.channel.sink.close(status.goingAway);
  }

  @override
  void sendToServer(Map<String, dynamic> message) {
    this.channel.sink.add(json.encode(message));
  }

  @override
  bool canReset() {
    return true;
  }

  @override
  void reset() {
    this.sendToServer({'type': 'reset'});
  }

  static void startConnection(BuildContext rootContext, String lobby, String password, bool creator) {
    final url = '${WebServer.ws}://${WebServer.host}/connection';
    final channel = WebSocketFactory().connect(url);
    WebSocketConnection(channel, rootContext);
    channel.sink.add(json.encode({
      'type': 'connection',
      'lobby': lobby,
      'password': password,
      'creator': creator,
    }));
  }

  static void _connectToLobby(BuildContext rootContext, String lobby) {
    final passwordText = TextEditingController();
    showDialog(
      context: rootContext,
      builder: (context) {
        return new AlertDialog(
          title: new Text("Connect to $lobby"),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: TextField(
              controller: passwordText,
              decoration: InputDecoration(labelText: "Password"),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Connect'),
              onPressed: () {
                Navigator.of(rootContext).pop();
                WebSocketConnection.startConnection(rootContext, lobby, passwordText.text, false);
              },
            ),
          ],
        );
      },
    );
  }

  static void _pickLobby(BuildContext rootContext, Map<String, dynamic> lobbies) {
    showDialog(
      context: rootContext,
      builder: (context) {
        return new AlertDialog(
          title: new Text("Select lobby"),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: lobbies.entries
                  .map((lobby) => FlatButton(
                      child: Text(lobby.key),
                      onPressed: () {
                        if (lobby.value) {
                          WebSocketConnection.startConnection(rootContext, lobby.key, '', false);
                        } else {
                          WebSocketConnection._connectToLobby(rootContext, lobby.key);
                        }
                      }))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  static void join(BuildContext rootContext) {
    http.get('${WebServer.http}://${WebServer.host}/lobbies').then((value) {
      Map<String, dynamic> lobbies = json.decode(value.body);
      WebSocketConnection._pickLobby(rootContext, lobbies);
    }, onError: (e) => print(e));
  }
}
