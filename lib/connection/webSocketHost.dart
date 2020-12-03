import 'package:flutter/foundation.dart';

class WebServer {
  static String get ws {
    if (!kDebugMode) {
      return 'wss';
    } else {
      return 'wss';
    }
  }

  static String get http {
    if (!kDebugMode) {
      return 'https';
    } else {
      return 'https';
    }
  }

  static String get host {
    if (!kDebugMode) {
      return 'juggernautpaintings.herokuapp.com';
    } else {
      return 'juggernautpaintings.herokuapp.com';
    }
  }
}
