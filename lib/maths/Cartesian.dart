import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class Cartesian extends Vector3 {

  var datum;
  final double x, y, z;

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

  getEllipsoids() => ellipsoids;
  getDatums() => datums;

  ///Creates a cartesian coordinate
  Cartesian(this.x, this.y, this.z, this.datum) : super.zero();

  ///Converts the cartesian coordinate to latitude and longitude using a given ellipsoid
  toLatLong(var datum) {
    final ellipsoid = ellipsoids[datum["ellipsoid"]];
    final a = ellipsoid!["a"]!;
    final b = ellipsoid["b"]!;
    final f = ellipsoid["f"]!;

    final e2 = 2*f - f*f; //1st eccentricity
    final E2 = e2 / (1-e2); //2nd eccentricity
    final p = math.sqrt(x*x + y*y); //distance from minor axis
    final R = math.sqrt(p*p + z*z); //polar radius

    //parametric latitude
    final tanB = (b*z)/(a*p) * (1+E2*b/R);
    final sinB = tanB / math.sqrt(1+tanB*tanB);
    final cosB = sinB / tanB;

    //geodetic latitude
    final double w = cosB.isNaN ? 0 : math.atan2(z + E2*b*sinB*sinB*sinB, p - e2*a*cosB*cosB*cosB);

    //longitude
    final l = math.atan2(y, x);

    //height above ellipsoid
    final sinw = math.sin(w);
    final cosw = math.cos(w);
    final v = a / math.sqrt(1-e2*sinw*sinw);
    final h = p*cosw + z*sinw - (a*a/v);

    final point = new LatLong(degrees(w), degrees(l), h, datum);
    return point;
  }

}