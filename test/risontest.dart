import 'package:unittest/unittest.dart';
import 'package:rison/rison.dart';

main() {
  test('RISON test', () {
    Map mapIn = { 'x' : 1 };

    String rison = mapToRison(mapIn);

    print(rison);

    Map mapOut = risonToMap(rison);

    expect(mapOut, mapIn);
    expect(mapOut is Map, true);
  });
}
