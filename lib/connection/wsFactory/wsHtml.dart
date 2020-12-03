import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:juggernaut/connection/wsFactory/wsFactory.dart';

class HtmlWebSocketFactory implements WebSocketFactory {
  @override
  WebSocketChannel connect(String url) {
    return HtmlWebSocketChannel.connect(url);
  }
}

WebSocketFactory getWSFactory() => HtmlWebSocketFactory();
