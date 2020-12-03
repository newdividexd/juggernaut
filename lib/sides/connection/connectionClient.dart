import 'package:flutter/material.dart';

import 'package:juggernaut/sides/painting.dart';
import 'package:juggernaut/sides/sides.dart';

import 'package:juggernaut/sides/computer/computer.dart';
import 'package:juggernaut/sides/numbers/numbers.dart';
import 'package:juggernaut/sides/numbers/numberSelector.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Connection {
  void sendToServer(Map<String, dynamic> message);
  bool canReset();
  void reset();
  void clientClosed();
}

class LobbyHeader extends StatefulWidget {
  final ConnectionClient client;

  LobbyHeader(this.client);

  @override
  State<StatefulWidget> createState() {
    return LobbyHeaderState();
  }
}

class LobbyHeaderState extends State<LobbyHeader> {
  int computer = 0;
  int numbers = 0;

  @override
  void initState() {
    super.initState();
    this.widget.client.setHeader(this);
  }

  void onCounterChange(int computer, int numbers) {
    this.setState(() {
      this.computer = computer;
      this.numbers = numbers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.image)),
        Padding(padding: EdgeInsets.only(right: 5), child: Text(this.numbers.toString())),
        Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.dialpad)),
        Padding(padding: EdgeInsets.only(right: 5), child: Text(this.computer.toString())),
      ],
    );
  }
}

class ViewChangerBroker implements ViewChanger {
  NumberSelectorState state;
  @override
  void setState(NumberSelectorState state) {
    this.state = state;
    SharedPreferences.getInstance().then((preferences) {
      bool value = preferences.getBool('numbersView');
      if (value != null) {
        this.state.setView(value);
      }
    });
  }
}

class NumberView extends StatefulWidget {
  final ViewChangerBroker _broker;

  NumberView(this._broker);

  @override
  State<StatefulWidget> createState() {
    return NumberViewState();
  }
}

class NumberViewState extends State<NumberView> {
  void onViewSelected(bool value) {
    this.widget._broker.state?.setView(value);
    SharedPreferences.getInstance().then((preferences) {
      preferences.setBool('numbersView', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      onSelected: this.onViewSelected,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<bool>(value: true, child: Text('Roman')),
        PopupMenuItem<bool>(value: false, child: Text('Decimal')),
      ],
    );
  }
}

class ConnectionClient extends SideHolder {
  final Connection connection;
  final List<Map<String, dynamic>> _buffer = List();

  Side _side;
  BuildContext _rootContext;
  BuildContext _clientContext;
  LobbyHeaderState _header;

  int _computer;
  int _numbers;

  ConnectionClient(this.connection, this._rootContext);

  @override
  void setNumber(Painting painting, int value) {
    this.connection.sendToServer({
      'type': 'data',
      'name': painting.name,
      'number': value,
    });
  }

  @override
  void setOffset(Painting painting, int value) {
    this.connection.sendToServer({
      'type': 'data',
      'name': painting.name,
      'offset': value,
    });
  }

  @override
  void setSide(Side side) {
    this._side = side;
    this._buffer.forEach((message) {
      this._onPaintingData(message);
    });
    this._buffer.clear();
  }

  void onConnectionClosed() {
    if (this._clientContext != null) {
      Navigator.of(this._clientContext).pop();
    }
  }

  void setHeader(LobbyHeaderState header) {
    this._header = header;
    if (this._computer != null) {
      this._header.onCounterChange(this._computer, this._numbers);
    }
  }

  void onMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'reset':
        this._side.reset();
        break;
      case 'role':
        this._roleAsigned(message['role']);
        break;
      case 'computer':
        this._selectSide(message['computer']);
        break;
      case 'data':
        this._onPaintingData(message);
        break;
      case 'counter':
        this._onCounterChange(message['computer'], message['numbers']);
    }
  }

  void _roleAsigned(String role) {
    Navigator.of(this._rootContext).push(MaterialPageRoute(
      builder: (newContext) {
        this._rootContext = null;
        this._clientContext = newContext;
        final changer = ViewChangerBroker();
        return Scaffold(
          appBar: AppBar(
            title: Text((role == 'computer') ? 'Computer' : 'Numbers'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: LobbyHeader(this),
              ),
              if (this.connection.canReset())
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: this.connection.reset,
                    child: Icon(Icons.refresh),
                  ),
                ),
              if (role == 'paintings') NumberView(changer),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              Widget body = (role == 'computer') ? Computer(this) : Numbers(this, changer);
              if (constraints.maxWidth > constraints.maxHeight * 0.7) {
                return Center(
                  child: SizedBox(
                    width: constraints.maxHeight * 0.7,
                    child: body,
                  ),
                );
              } else {
                return body;
              }
            },
          ),
        );
      },
    )).then(
      (value) => this.connection.clientClosed(),
      onError: (e) => this.connection.clientClosed(),
    );
  }

  void _selectSide(bool computerAviable) {
    if (computerAviable) {
      this.connection.sendToServer({
        'type': 'role',
        'role': 'paintings',
      });
    } else {
      bool selected = false;
      showDialog(
        context: this._rootContext,
        builder: (context) => new AlertDialog(
          title: new Text("Chose side"),
          content: new Text("You can chose computer or paintings"),
          actions: <Widget>[
            FlatButton(
              child: Text('Computer'),
              onPressed: () {
                selected = true;
                Navigator.of(context).pop();
                this.connection.sendToServer({
                  'type': 'role',
                  'role': 'computer',
                });
              },
            ),
            FlatButton(
              child: Text('Paintings'),
              onPressed: () {
                selected = true;
                Navigator.of(context).pop();
                this.connection.sendToServer({
                  'type': 'role',
                  'role': 'paintings',
                });
              },
            ),
          ],
        ),
      ).then((value) {
        if (!selected) {
          this.connection.clientClosed();
        }
      });
    }
  }

  void _onPaintingData(Map<String, dynamic> message) {
    if (this._side == null) {
      this._buffer.add(message);
    } else {
      bool hasOffset = message['offset'] != null;
      bool hasNumber = message['number'] != null;
      Painting painting = Painting.map[message['name']];
      if (hasOffset && hasNumber) {
        var data = PaintingData();
        data.number = message['number'];
        data.offset = message['offset'];
        this._side.setData(painting, data);
      } else if (hasOffset) {
        this._side.setOffset(painting, message['offset']);
      } else if (hasNumber) {
        this._side.setNumber(painting, message['number']);
      }
    }
  }

  void _onCounterChange(int computer, int numbers) {
    if (this._header != null) {
      this._header.onCounterChange(computer, numbers);
    } else {
      this._computer = computer;
      this._numbers = numbers;
    }
  }
}
