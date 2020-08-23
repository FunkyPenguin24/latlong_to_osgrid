import 'dart:math' as Math;
import 'Datums.dart';
import 'package:vector_math/vector_math.dart';

import 'Cartesian.dart';
import 'Dms.dart';

class LatLongEllipsodial {

  var datum = Datums.WGS84;
  var lat;
  var long;
  var height;

  final ellipsoids = {
    "WGS84":{ "a": 6378137, "b": 6356752.314245, "f": 1/298.257223563 },
    "Airy1830":{"a": 6377563.396, "b": 6356256.909, "f": 1/299.3249646 },
    "AiryModified":  { "a": 6377340.189, "b": 6356034.448,    "f": 1/299.3249646   },
    "Bessel1841":    { "a": 6377397.155, "b": 6356078.962818, "f": 1/299.1528128   },
    "Clarke1866":    { "a": 6378206.4,   "b": 6356583.8,      "f": 1/294.978698214 },
    "Clarke1880IGN": { "a": 6378249.2,   "b": 6356515.0,      "f": 1/293.466021294 },
    "GRS80":         { "a": 6378137,     "b": 6356752.314140, "f": 1/298.257222101 },
    "Intl1924":      { "a": 6378388,     "b": 6356911.946,    "f": 1/297           }, // aka Hayford
    "WGS72":         { "a": 6378135,     "b": 6356750.5,      "f": 1/298.26        },
  };

  final datums = {
    "OSGB36":{ "ellipsoid": "Airy1830", "transform": [ -446.448, 125.157, -542.060,  20.4894, -0.1502,  -0.2470,  -0.8421   ] },
    "WGS84":{ "ellipsoid": "WGS84", "transform": [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] },
    "ED50": { "ellipsoid": "Intl1924", "transform": [ 89.5, 93.8, 123.1, -1.2, 0.0, 0.0, 0.156 ] },
    "ETRS89": { "ellipsoid": "GRS80", "transform": [ 0, 0, 0, 0, 0, 0, 0 ] },
    "Irl1975": { "ellipsoid": "AiryModified", "transform": [ -482.530, 130.596, -564.557, -8.150, 1.042, 0.214, 0.631 ] },
    "NAD27": { "ellipsoid": "Clarke1866", "transform": [ 8, -160, -176, 0, 0, 0, 0 ] },
    "NAD83": { "ellipsoid": "GRS80", "transform": [ 0.9956, -1.9103, -0.5215, -0.00062, 0.025915, 0.009426, 0.011599 ] },
    "NTF": { "ellipsoid": "Clarke1880IGN", "transform": [ 168, 60, -320, 0, 0, 0, 0 ] },
    "Potsdam": { "ellipsoid": "Bessel1841", "transform": [ -582, -105, -414, -8.3, 1.04, 0.35, -3.08 ] },
    "TokyoJapan": { "ellipsoid": "Bessel1841", "transform": [ 148, -507, -685, 0, 0, 0, 0 ] },
    "WGS72": { "ellipsoid": "WGS72", "transform": [ 0, 0, -4.5, -0.22, 0, 0, 0.554 ] },
  };

  ///Creates a new Lat Long object with a given latitude and longitude in decimal form
  LatLongEllipsodial(var la, var lo, var h, this.datum) {
    this.lat = Dms().wrap90(la);
    this.long = Dms().wrap180(lo);
    this.height = h;
  }

  ///Creates a new Lat Long object with a given latitude and longitude in degrees, minutes and seconds form
  LatLongEllipsodial.fromDms(var latdeg, var latmin, var latsec, var longdeg, var longmin, var longsec, var h, this.datum) {
    this.lat = Dms().wrap90(getDecimalFromDegree(latdeg, latmin, latsec));
    this.long = Dms().wrap180(getDecimalFromDegree(longdeg, longmin, longsec));
    this.height = h;
  }

  getEllipsoids() => ellipsoids;
  getDatums() => datums;

  getLat() => lat;

  getLon() => long;

  getHeight() => height;

  ///Converts the lat long values to cartesian coordinates
  toCartesian() {
    final w = radians(lat);
    final l = radians(long);
    final h = height;
    final a = ellipsoids[datum["ellipsoid"]]["a"];
    final f = ellipsoids[datum["ellipsoid"]]["f"];

    final sinw = Math.sin(w);
    final cosw = Math.cos(w);
    final sinl = Math.sin(l);
    final cosl = Math.cos(l);

    final eSq = 2*f - f*f;
    final v = a / Math.sqrt(1 - eSq*sinw*sinw);

    final x = (v+h) * cosw * cosl;
    final y = (v+h) * cosw * sinl;
    final z = (v*(1-eSq)+h) * sinw;

    return new Cartesian(x, y, z, this.datum);
  }

  ///Returns the decimal value of a lat or long coordinate given its degrees minutes and seconds
  getDecimalFromDegree(double deg, double min, double sec) {
    double decimalDegree = deg;
    if (decimalDegree < 0) { //turns the decimal degree positive for the calculation
      decimalDegree *= -1;
    }
    decimalDegree += (min/60);
    decimalDegree += (sec/3600);

    if (deg < 0) { //turns the decimal degree back to negative if the original degree was
      decimalDegree *= -1;
    }
    return decimalDegree;
  }

}