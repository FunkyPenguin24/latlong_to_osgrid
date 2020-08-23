import 'LatLongEllipsodial.dart';
import 'CartesianDatum.dart';

class LatLongEllipsodialDatum extends LatLongEllipsodial {

  getDatum() => datum;

  LatLongEllipsodialDatum(lat, lon, height, d) : super(lat, lon, height, d);
  LatLongEllipsodialDatum.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, height, d) : super.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, height, d);

  ///Converts the lat and long object into a new datum (i.e. from WGS84 into OSGB36 ready to be translated to an OS Grid Reference)
  convertDatum(toDatum) {
    final oldCartesian = toCartesian(); //gets the current lat long coords as cartesian coordinates
    final newCartesian = oldCartesian.convertDatum(toDatum); //converts the cartesian coordinates to the new datum
    //final newLatLon = newCartesian.toLatLong(ellipsoids[toDatum["ellipsoid"]]); //converts the new cartesian coordinates back into lat and long of the new datum
    final newLatLon = newCartesian.toLatLong(toDatum); //converts the new cartesian coordinates back into lat and long of the new datum
    return newLatLon;
  }

  @override
  toCartesian() {
    final cartesian = super.toCartesian();
    final cartesianDatum = new CartesianDatum(cartesian.x, cartesian.y, cartesian.z, cartesian.datum);
    return cartesianDatum;
  }

}