import '../lib/latlong_to_osgrid.dart';

class ExampleClass {
  LatLongConverter converter = new LatLongConverter();

  void OSGBfromDecExample(double lat, double long) {
    var result = converter.getOSGBfromDec(lat, long);
    print("${result.easting} ${result.northing}");
  }

  void OSGBfromDmsExample(var latDeg, var latMin, var latSec, var longDeg, var longMin, var longSec) {
    var result = converter.getOSGBfromDms(latDeg, latMin, latSec, longDeg, longMin, longSec);
    print("${result.easting} ${result.northing}");
  }

  void LatLongfromOSGBExample(var easting, var northing) {
    var result = converter.getLatLongFromOSGB(easting, northing);
    print("${result.lat} ${result.long}");
  }

  void DecimalToDmsExample(double lat, double long) {
    var latDms = converter.getDegreeFromDecimal(lat);
    var longDms = converter.getDegreeFromDecimal(long);
    print("${latDms[0]}° ${latDms[1]}' ${latDms[2]}\"");
    print("${longDms[0]}° ${longDms[1]}' ${longDms[2]}\"");
  }

  void DmsToDecimalExample(var latDeg, var latMin, var latSec, var longDeg, var longMin, var longSec) {
    var latDec = converter.getDecimalFromDegree(latDeg, latMin, latSec);
    var longDec = converter.getDecimalFromDegree(longDeg, longMin, longSec);
    print("$latDec $longDec");
  }

}