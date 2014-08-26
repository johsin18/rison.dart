import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;

main() {
  test('RISON test', () {
    var context = js.context;

    Map mapIn = { 'x' : 1 };

    String rison = context.rison.encode(js.map(mapIn));

    print(rison);

    Map mapOut = jsw.JsObjectToMapAdapter.cast(context.rison.decode(rison));

    expect(mapOut, mapIn);
    expect(mapOut is Map, true);
  });
}
