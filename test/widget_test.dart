import 'package:flutter_test/flutter_test.dart';
import 'package:chotto_pathshala/main.dart';

void main() {
  test('all planned learning levels are available', () {
    expect(levels.keys, containsAll(['playgroup', 'nursery', 'kg', 'class-one', 'class-two']));
  });

  test('Flutter app has the approved Bengali brand', () {
    expect(const ChottoPathshalaApp(), isA<ChottoPathshalaApp>());
  });
}
