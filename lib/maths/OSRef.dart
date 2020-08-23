import 'package:vector_math/vector_math.dart';
import 'LatLong.dart';
import 'Datums.dart';
import 'dart:math' as Math;
class OSRef {
  var d = Datums.WGS84;
  double easting;
  double northing;

  ///Creates a new OSRef object with a given easting and northing
  OSRef(this.easting, this.northing);

  ///Converts the OSRef object (easting and northing given when object is created) into a latitude and longitude of a specified datum
  ///Most widely used datum in Europe is WGS84 (this is what is used by phone GPS)
  LatLong toLatLon([var datum]) {
    if (datum == null) {
      datum = this.d;
    }

    final E = easting;
    final N = northing;

    final a = 6377563.396; //Airy 1830 major semi axis
    final b = 6356256.909; //Airy 1830 minor semi axis
    final F0 = 0.9996012717; //NatGrid scale factor on central meridian
    final w0 = radians(49);
    final l0 = radians(-2);
    final N0 = -100e3;
    final E0 = 400e3;
    final e2 = 1 - (b*b)/(a*a);
    final n = (a-b)/(a+b);
    final n2 = n*n;
    final n3 = n*n*n;

    var w = w0;
    double M = 0;

    do {
      w = (N-N0-M)/(a*F0) + w;

      var Ma = (1 + n + (5/4)*n2 + (5/4)*n3) * (w-w0);
      var Mb = (3*n + 3*n*n + (21/8)*n3) * Math.sin(w-w0) * Math.cos(w+w0);
      var Mc = ((15/8)*n2 + (15/8)*n3) * Math.sin(2*(w-w0)) * Math.cos(2*(w+w0));
      var Md = (35/24)*n3 * Math.sin(3*(w-w0)) * Math.cos(3*(w+w0));
      M = b * F0 * (Ma - Mb + Mc - Md);
    } while ((N-N0-M).abs() >= 0.00001);

    final cosw = Math.cos(w);
    final sinw = Math.sin(w);
    final v = a*F0/Math.sqrt(1-e2*sinw*sinw);
    final p = a*F0*(1-e2)/Math.pow(1-e2*sinw*sinw, 1.5);
    final N2 = v/p-1;

    final tanw = Math.tan(w);
    final tan2w = tanw*tanw;
    final tan4w = tan2w*tan2w;
    final tan6w = tan4w*tan2w;
    final secw = 1/cosw;
    final v3 = v*v*v;
    final v5 = v3*v*v;
    final v7 = v5*v*v;

    final VII = tanw/(2*p*v);
    final VIII = tanw/(24*p*v3)*(5+3*tan2w+N2-9*tan2w*N2);
    final IX = tanw/(720*p*v5)*(61+90*tan2w+45*tan4w);
    final X = secw/v;
    final XI = secw/(6*v3)*(v/p+2*tan2w);
    final XII = secw/(120*v5)*(5+28*tan2w+24*tan4w);
    final XIIA = secw/(5040*v7)*(61+662*tan2w+1320*tan4w+720*tan6w);

    final dE = (E-E0);
    final dE2 = dE*dE;
    final dE3 = dE2*dE;
    final dE4 = dE2*dE2;
    final dE5 = dE3*dE2;
    final dE6 = dE4*dE2;
    final dE7 = dE5 * dE2;
    w = w - VII*dE2 + VIII*dE4 - IX*dE6;
    final l = l0 + X*dE - XI*dE3 + XII*dE5 - XIIA*dE7;

    LatLong latLong = LatLong(degrees(w), degrees(l), 0, Datums.OSGB36);
    if (datum != Datums.OSGB36) { //if the required datum is not osgb36, then convert to the datum given
      latLong = latLong.convertDatum(datum);
      latLong = new LatLong(latLong.lat, latLong.long, latLong.height, datum);
    }

    return latLong;

  }

}