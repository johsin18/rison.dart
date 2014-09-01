library rison;

import 'dart:html';
import 'dart:js';
import 'package:js_wrapping/js_wrapping.dart';

String toRison(Object mapOrIterable) => context['rison'].callMethod('encode', [ new JsObject.jsify(mapOrIterable) ]);
JsObject risonToJsObject(String rison) => context['rison'].callMethod('decode', [ rison ]);
Map jsObjectToMap(JsObject jsObject) => TypedJsMap.$wrap(jsObject);
List jsObjectToList(JsObject jsObject) => jsObject as JsArray;

Object fromRison(String rison) {
  JsObject jsObject = risonToJsObject(rison);

  return convertObject(jsObject, false);
}

Object fromRisonRecursive(String rison) {
  JsObject jsObject = risonToJsObject(rison);

  return convertObject(jsObject, true);
}

Object convertObject(Object object, bool recursive) {
  if (object is JsArray) {
    List list = jsObjectToList(object);
    if (recursive)
      convertArray(list);
    return list;
  }
  else if (object is JsObject) {
    Map map = jsObjectToMap(object);
    if (recursive)
      convertMap(map);
    return map;
  }
  else
    return object;
}

void convertMap(Map map) {
  map.forEach((String key, Object value) {
    map[key] = convertObject(map[key], true);
  });
}

void convertArray(List array) {
  for (int i = 0; i < array.length; ++i)
    array[i] = convertObject(array[i], true);
}

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
