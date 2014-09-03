import 'dart:html';
import 'dart:convert';

import 'package:unittest/unittest.dart';
import 'package:rison/rison.dart';

main() {
  test('RISON test', () {
    Map mapIn = { 'x': 1, 'y': { 'y1': 0.123 }, 'z': [ 'a', 'b', 'c']};

    String rison = toRison(mapIn);

    print(rison);

    Map mapOut = fromRison(rison);

    mapOut['y'] = new Map.from(jsObjectToMap(mapOut['y']));
    mapOut['z'] = jsObjectToList(mapOut['z']);

    print(mapIn);
    print(mapOut);
    expect(mapOut, equals(mapIn));
  });

  test('RISON test recursive', () {
    Map mapIn = { 'a' : [ { 'b': [ { 'c': 42 } ] } ] };

    String rison = toRison(mapIn);

    print(rison);

    Map mapOut = fromRisonRecursive(rison);

    print(mapIn);
    print(mapOut);
    expect(mapOut, equals(mapIn));
  });

  test('RISON string test', () {
    String input = "string";
    String rison = toRison(input);

    print(rison);

    String output = fromRison(rison);

    expect(output, equals(input));
  });

  test('RISON int test', () {
    int input = 42;
    String rison = toRison(input);

    print(rison);

    int output = fromRison(rison);

    expect(output, equals(input));
  });

  test('RISON encoding test', () {
    Rison rison = new Rison();
    String string = 'grün';
    rison.updateHash(string, false);
    print(window.location.hash);
    print(Uri.encodeFull("#$string"));
    expect(window.location.hash, Uri.encodeFull("#$string"));
    expect(Uri.decodeFull(window.location.hash), "#$string");
  });
  
  solo_test('RISON encoding test faulty', () {
    Rison rison = new Rison();
    String string = 'grün,%C3%9F';
    for (int i = 0; i < string.length; i ++) {
      int codeUnit = string.codeUnitAt(i);
      print(codeUnit);
    }
    string = preencode(string);
    print(string);
    expect(Uri.decodeFull(string), 'grün,ß');
  });
}

String preencode(String text) {
  byteToHex(int byte, StringBuffer buffer) {
    const String hex = '0123456789ABCDEF';
    buffer.write('%');
    buffer.writeCharCode(hex.codeUnitAt(byte >> 4));
    buffer.writeCharCode(hex.codeUnitAt(byte & 0x0f));
  }
  StringBuffer result = new StringBuffer();
  for (int i = 0; i < text.length; i++) {
    var codeUnit = text.codeUnitAt(i);
    if (codeUnit > 127) {
      var utf16Encoded = new String.fromCharCode(codeUnit);
      List<int> utf8Encoded = UTF8.encode(utf16Encoded);
      utf8Encoded.forEach((int c) { byteToHex(c, result); });
    } else {
      result.writeCharCode(codeUnit);
    }
  }
  return result.toString();
}
