import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:juggernaut/connection/socketServerLobby.dart';
import 'package:juggernaut/connection/socketConnection.dart';
import 'package:juggernaut/connection/webSocketCreate.dart';
import 'package:juggernaut/connection/webSocketJoin.dart';

final options = {
  if (!kIsWeb) 'Host': SocketServerLobby.host,
  if (!kIsWeb) 'Connect': SocketConnection.connect,
  'Join Lobby': WebSocketConnection.join,
  'Create Lobby': WebSocketCreate.create,
};

void main() {
  runApp(JuggernautApp());
}

class JuggernautApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Warzone Juggernaut',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text("Warzone Juggernaut")),
          body: Builder(
            builder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: options.entries
                    .map((entry) => RaisedButton(
                          child: Text(entry.key),
                          onPressed: () {
                            entry.value(context);
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      );
}
