import 'LatLongEllipsodialDatum.dart';
import 'package:vector_math/vector_math.dart';
import 'OSRef.dart';
import 'dart:math' as Math;

class LatLong extends LatLongEllipsodialDatum {

  ///Creates a new lat and long object with a given latitude, longitude and height (datum is optional but by default is WGS84)
  LatLong(la, lo, h, d) : super(la, lo, h, d);
  ///Creates a new lat and long object with a given latitude and longitude given in degrees, minutes and seconds, and height (datum is optional but by default is WGS84)
  LatLong.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, h, d) : super.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, h, d);

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

    print("RESULT");
    print("$E,$N");

    OSRef ref = OSRef(E, N);

    return ref;

  }

}