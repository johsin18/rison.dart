import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:rison/rison.dart';

main() {
  test('RISON test', () {
    Map mapIn = { 'x': "string", 'y': { 'y1': 0.123 }, 'z': [ 'a', 'b', 'c']};

    String rison = RisonStateKeeper.toRison(mapIn);

    print(rison);

    Map mapOut = RisonStateKeeper.fromRison(rison);

    mapOut['y'] = new Map.from(RisonStateKeeper.jsObjectToMap(mapOut['y']));
    mapOut['z'] = RisonStateKeeper.jsObjectToList(mapOut['z']);

    print(mapIn);
    print(mapOut);
    expect(mapOut, equals(mapIn));
  });

  test('RISON test recursive', () {
    Map mapIn = { 'a' : [ { 'b': [ { 'c': 42 } ] } ] };

    String rison = RisonStateKeeper.toRison(mapIn);

    print(rison);

    Map mapOut = RisonStateKeeper.fromRison(rison, recursive: true);

    print(mapIn);
    print(mapOut);
    expect(mapOut, equals(mapIn));
  });

  test('RISON string test', () {
    String input = "string";
    String rison = RisonStateKeeper.toRison(input);

    print(rison);

    String output = RisonStateKeeper.fromRison(rison);

    expect(output, equals(input));
  });

  test('RISON int test', () {
    int input = 42;
    String rison = RisonStateKeeper.toRison(input);

    print(rison);

    int output = RisonStateKeeper.fromRison(rison);

    expect(output, equals(input));
  });

  test('RISON encoding test', () {
    String string = '(k:grün%C3%9F)';
    setHash(string);
    print("hash: ${window.location.hash}");
    String hashWithoutTag = RisonStateKeeper.hashWithoutTag;
    print("hashWithoutTag: $hashWithoutTag");
    Object mapOut = RisonStateKeeper.fromRison(RisonStateKeeper.decodeHash(hashWithoutTag));
    print(mapOut);
    expect(mapOut, equals({ 'k': 'grünß' }));
  });

  solo_test('RISON invalid test', () {
    expect(() {
      String string = '(k:x';
      Object mapOut = RisonStateKeeper.fromRison(string);
    }, throwsA(new DecodingException('Error: rison decoder error: missing \':\'')));
  });
}

void setHash(String hash) {
  String url = window.location.href;
  int hashBegin = url.indexOf("#", 0);
  if (hashBegin == -1)
    hashBegin = url.length;
  String baseUrl = url.substring(0, hashBegin);
  String actualUrl = "${baseUrl}#${hash}";
  window.history.replaceState(null, '', actualUrl);
}

