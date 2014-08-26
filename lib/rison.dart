library rison;

import 'dart:html';
import 'dart:js';
import 'package:js_wrapping/js_wrapping.dart';

String mapToRison(Map map) => context['rison'].callMethod('encode', [ new JsObject.jsify(map) ]);
Map risonToMap(String rison) => TypedJsMap.$wrap(context['rison'].callMethod('decode', [ rison ]));
Map jsObjectToMap(JsObject jsObject) => TypedJsMap.$wrap(jsObject);
List jsObjectToList(JsObject jsObject) => jsObject as JsArray;

void printMap(Map map) {
  print(mapToString(map));
}
String mapToString(Map map) {
  String result = '';
  map.forEach((k, v) {
    String value = v.toString();
    if (v is JsObject)
      value = "( ${mapToString(jsObjectToMap(v))} )";
    result = "$result, $k : $value";
  });
  return result;
}

abstract class StateKeeper {
  void listenToHash(void onHashChanged(String hash));
  void updateHash(String hash, bool replace);
}

class Rison implements StateKeeper {
  void listenToHash(void onHashChanged(String hash)) {
    onHashChanged(hashWithoutTag);
    window.onHashChange.listen((HashChangeEvent e) {
      onHashChanged(hashWithoutTag);
    });
  }

  String get hashWithoutTag {
    String hash = (window.location.hash.length > 1) ? window.location.hash.substring(1) /* remove # */ : '';
    String decodedHash = Uri.decodeFull(hash);
    return decodedHash;
  }

  void updateHash(String hash, bool replace) {
    hash = Uri.encodeFull(hash);
    String url = window.location.href;
    int hashBegin = url.indexOf("#", 0);
    if (hashBegin == -1)
      hashBegin = url.length;
    String baseUrl = url.substring(0, hashBegin);
    String actualUrl = "${baseUrl}#${hash}";
    if (replace)
      window.history.replaceState(null, '', actualUrl);
    else
      window.history.pushState(null, '', actualUrl);
  }
}

class DummyStateKeeper implements StateKeeper {
  void listenToHash(void onHashChanged(String hash)) { }
  void updateHash(String hash, bool replace) { }
}
