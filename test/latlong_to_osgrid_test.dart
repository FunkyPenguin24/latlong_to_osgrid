import 'package:test/test.dart';

import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

void main() {
  test('adds one to input values', () {
    final converter = LatLongConverter();
    expect(converter.getDecimalFromDegree(52, 57, 36), 52.96);
    expect(converter.getDecimalFromDegree(1, 4, 48), 1.08);
    expect(() => converter.getDecimalFromDegree(null, null, null), throwsNoSuchMethodError);
  });
}
