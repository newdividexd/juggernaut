import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:juggernaut/connection/wsFactory/wsFactoryStub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:juggernaut/connection/wsFactory/wsIO.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:juggernaut/connection/wsFactory/wsHtml.dart';

abstract class WebSocketFactory {
  WebSocketChannel connect(String url);

  factory WebSocketFactory() => getWSFactory();
}
