import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:juggernaut/connection/wsFactory/wsFactory.dart';

class IOWebSocketFactory implements WebSocketFactory {
  @override
  WebSocketChannel connect(String url) {
    return IOWebSocketChannel.connect(url);
  }
}

WebSocketFactory getWSFactory() => IOWebSocketFactory();
