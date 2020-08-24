import 'maths/Datums.dart';
import 'maths/LatLongEllipsodialDatum.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;

class LatLongConverter {

  ///Returns the easting and northing values of an OS Grid Reference given the decimal latitude and longitude values
  OSRef getOSGBfromDec(double lat, double long, [var datum]) {
    if (datum == null) {
      datum = Datums.WGS84;
    }
    //since we are converting from WGS84 lat/long, we need to provide the converter with its datum so it knows what it's converting from
    LatLong latLong = new LatLong(lat, long, 0, datum); //gives the lat and long coordinates to the converter along with the height and the Datum of the lat long coords
    OSRef osRef = latLong.toOsGrid(); //returns an array with 2 elements, the first is the easting and the second is the northing
    return osRef;
  }

  ///Returns the easting and northing values of an OS Grid Reference given the degrees, minutes and seconds of latitude and longitude values
  OSRef getOSGBfromDms(double latdeg, double latmin, double latsec, double longdeg, double longmin, double longsec, [var datum]) {
    if (datum == null) {
      datum = Datums.WGS84;
    }
    LatLong latLong = new LatLong.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, 0, datum);
    OSRef osRef = latLong.toOsGrid();
    return osRef;
  }

  ///Returns a latitude and longitude value in a given datum (default WGS84) for a given easting and northing value
  LatLong getLatLongFromOSGB(double easting, double northing, [var datum]) {
    OSRef osRef = new OSRef(easting, northing);
    LatLong latLong = osRef.toLatLon(datum);
    return latLong;
  }

  ///Returns the decimal value of a lat or long coordinate given its degrees minutes and seconds
  double getDecimalFromDegree(double deg, double min, double sec) {
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

  ///Returns the degrees minutes and seconds of a coordinate given its decimal value
  dynamic getDegreeFromDecimal(double dec) {
    double positiveDec = dec;
    if (dec < 0) { //if the decimal is negative, switch it to positive for the calculations
      positiveDec *= -1;
    }
    int degrees = positiveDec.toInt();
    int minutes = ((positiveDec - degrees) * 60).toInt();
    double seconds = (positiveDec - degrees - minutes/60) * 3600;
    return [dec.toInt(), minutes, seconds];
  }

}

class LatLong extends LatLongEllipsodialDatum {

  ///Creates a new lat and long object with a given latitude, longitude and height (datum is optional but by default is WGS84)
  LatLong(la, lo, h, d) : super(la, lo, h, d);
  ///Creates a new lat and long object with a given latitude and longitude given in degrees, minutes and seconds, and height (datum is optional but by default is WGS84)
  LatLong.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, h, d) : super.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, h, d);
  ///Creates a new lat and long object from a given JSON object
  LatLong.fromJson(json) : super.fromJson(json);

  ///This function first converts the lat and long coordinates from the specified datum into the OSGB36 datum
  ///It then puts the new lat and long coordinates through a mathematic algorithm that produces the easting and northing references
  ///Returns an OSRef object which contains the easting and northing
  OSRef toOsGrid() {
    final point = convertDatum(datums["OSGB36"]);

    final w = radians(point.lat);
    final l = radians(point.long);

    final a = 6377563.396;
    final b = 6356256.909;
    final F0 = 0.9996012717;
    final w0 = radians(49);
    final l0 = radians(-2);
    final N0 = -100000;
    final E0 = 400000;
    final e2 = 1 - (b*b)/(a*a);
    final n = (a-b)/(a+b);
    final n2 = n*n;
    final n3 = n*n*n;

    final cosw = Math.cos(w);
    final sinw = Math.sin(w);
    final v = a*F0/Math.sqrt(1-e2*sinw*sinw);
    final p = a*F0*(1-e2)/Math.pow(1-e2*sinw*sinw, 1.5);
    final N2 = v/p-1;

    final Ma = (1+n+(5/4)*n2 + (5/4)*n3) * (w-w0);
    final Mb = (3*n + 3*n*n + (21/8)*n3) * Math.sin(w-w0) * Math.cos(w+w0);
    final Mc = ((15/8)*n2 + (15/8)*n3) * Math.sin(2*(w-w0)) * Math.cos(2*(w+w0));
    final Md = (35/24)*n3 * Math.sin(3*(w-w0)) * Math.cos(3*(w+w0));
    final M = b * F0 * (Ma - Mb + Mc - Md); //meridional arc

    final cos3w = cosw*cosw*cosw;
    final cos5w = cos3w*cosw*cosw;
    final tan2w = Math.tan(w)*Math.tan(w);
    final tan4w = tan2w*tan2w;

    final I = M + N0;
    final II = (v/2)*sinw*cosw;
    final III = (v/24)*sinw*cos3w*(5-tan2w+9*N2);
    final IIIA = (v/720)*sinw*cos5w*(61-58*tan2w+tan4w);
    final IV = v*cosw;
    final V = (v/6)*cos3w*(v/p-tan2w);
    final VI = (v/120) * cos5w * (5 - 18*tan2w + tan4w + 14*N2 - 58*tan2w*N2);

    final dl = l-l0;
    final dl2 = dl*dl;
    final dl3 = dl2*dl;
    final dl4 = dl3*dl;
    final dl5 = dl4*dl;
    final dl6 = dl5*dl;

    var N = I + II*dl2 + III*dl4 + IIIA*dl6;
    var E = E0 + IV*dl + V*dl3 + VI*dl5;

    N = double.parse(N.toStringAsFixed(0));
    E = double.parse(E.toStringAsFixed(0));

    OSRef ref = OSRef(E, N);
    ref.fullRef = "$E $N";

    return ref;

  }

}

class OSRef {
  var d = Datums.WGS84;
  double easting;
  double northing;
  String fullRef = "";

  ///Creates a new OSRef object with a given easting and northing
  OSRef(this.easting, this.northing);
  ///Creates a new OSRef object from a given JSON object
  OSRef.fromJson(Map<String, dynamic> json) {
    this.easting = json["easting"];
    this.northing = json["northing"];
    this.fullRef = json["fullRef"];
    this.d = json["datum"];
  }

  ///Converts the OSRef into a JSON object
  Map<String, dynamic> toJson() =>
      {
        "easting" : easting,
        "northing" : northing,
        "fullRef" : fullRef,
        "datum" : d,
      };

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