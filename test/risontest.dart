import 'package:unittest/unittest.dart';
import 'package:rison/rison.dart';

main() {
  test('RISON test', () {
    Map mapIn = { 'x': 1, 'y': { 'y1': 0.123 }, 'z': [ 'a', 'b', 'c']};

    String rison = mapToRison(mapIn);

    print(rison);

    Map mapOut = risonToMap(rison);

    expect(mapOut is Map, true);
    mapOut['y'] = new Map.from(jsObjectToMap(mapOut['y']));
    mapOut['z'] = jsObjectToList(mapOut['z']);
    expect(mapOut, mapIn);
  });
}
