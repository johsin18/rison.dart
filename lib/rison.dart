library rison;

import 'dart:html';
import 'dart:js';
import 'dart:convert';

import 'package:js_wrapping/js_wrapping.dart';

abstract class StateKeeper {
  void listenToHash(void onHashChanged(String hash));
  void updateHash(String hash, bool replace);
}

class RisonStateKeeper implements StateKeeper {
  static String toRison(Object input) => context['rison'].callMethod('encode', [ (input is Map || input is Iterable) ? new JsObject.jsify(input) : input ]);
  static Object risonToObject(String rison) => context['rison'].callMethod('decode', [ rison ]);
  static Map jsObjectToMap(JsObject jsObject) => TypedJsMap.$wrap(jsObject);
  static List jsObjectToList(JsObject jsObject) => jsObject as JsArray;
  
  static String preencode(String text) {
    byteToHex(int byte, StringBuffer buffer) {
      const String hex = '0123456789ABCDEF';
      buffer.write('%');
      buffer.writeCharCode(hex.codeUnitAt(byte >> 4));
      buffer.writeCharCode(hex.codeUnitAt(byte & 0x0f));
    }
    StringBuffer result = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      int codeUnit = text.codeUnitAt(i);
      if (codeUnit > 127) {
        String utf16Encoded = new String.fromCharCode(codeUnit);
        List<int> utf8Encoded = UTF8.encode(utf16Encoded);
        utf8Encoded.forEach((int c) { byteToHex(c, result); });
      } else {
        result.writeCharCode(codeUnit);
      }
    }
    return result.toString();
  }
  
  static Object fromRison(String rison) {
    Object object = risonToObject(rison);
  
    return convertObject(object, false);
  }
  
  static Object fromRisonRecursive(String rison) {
    Object object = risonToObject(rison);
  
    return convertObject(object, true);
  }
  
  static Object convertObject(Object object, bool recursive) {
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
  
  static void convertMap(Map map) {
    map.forEach((String key, Object value) {
      map[key] = convertObject(map[key], true);
    });
  }
  
  static void convertArray(List array) {
    for (int i = 0; i < array.length; ++i)
      array[i] = convertObject(array[i], true);
  }
  
  static void printMap(Map map) {
    print(mapToString(map));
  }
  static String mapToString(Map map) {
    String result = '';
    map.forEach((k, v) {
      String value = v.toString();
      if (v is JsObject)
        value = "( ${mapToString(jsObjectToMap(v))} )";
      result = "$result, $k : $value";
    });
    return result;
  }

  void listenToHash(void onHashChanged(String hash)) {
    onHashChanged(hashWithoutTag);
    window.onHashChange.listen((HashChangeEvent e) {
      onHashChanged(hashWithoutTag);
    });
  }

  static String get hashWithoutTag {
    String hash = (window.location.hash.length > 1) ? window.location.hash.substring(1) /* remove # */ : '';
    hash = preencode(hash);
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
