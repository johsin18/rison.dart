import 'package:unittest/unittest.dart';
import 'package:rison/rison.dart';

main() {
  test('RISON test', () {
    Map mapIn = { 'x': 1, 'y': { 'y1': 0.123 }, 'z': [ 'a', 'b', 'c']};

    String rison = toRison(mapIn);

    print(rison);

    Map mapOut = fromRison(rison);

    expect(mapOut is Map, true);
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
}
