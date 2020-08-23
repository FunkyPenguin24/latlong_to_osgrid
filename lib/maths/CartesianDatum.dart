import 'Cartesian.dart';
import 'LatLong.dart';
import 'package:vector_math/vector_math.dart';

class CartesianDatum extends Cartesian {

  CartesianDatum(x, y, z, d) : super(x, y, z, d);

  getDatum() => datum;
  setDatum(d) {
    this.datum = d;
  }

  toLatLong(datum) {
    final latLon = super.toLatLong(datum);
    final point = new LatLong(latLon.lat, latLon.long, latLon.height, this.datum);
    return point;
  }

  convertDatum(toDatum) {
    var oldCartesian;
    var transform;

    if (this.datum == null || this.datum == datums["WGS84"]) {
      oldCartesian = this;
      transform = toDatum["transform"];
    }
    if (toDatum == datums["WGS84"]) {
      oldCartesian = this;
      transform = this.datum["transform"].map((t) => -t).toList();
    }
    if (transform == null) {
      oldCartesian = this.convertDatum(datums["WGS84"]);
      transform = toDatum["transform"];
    }

    final newCartesian = oldCartesian.applyTransform(transform);
    newCartesian.datum = toDatum;

    return newCartesian;
  }

  applyTransform(var t) {
    final x1 = x;
    final y1 = y;
    final z1 = z;

    final tx = t[0]; //x shift in metres
    final ty = t[1]; //y shift
    final tz = t[2]; //z shift
    final s = t[3]/1e6 + 1; //scale: normalise parts-per-million to s+1
    final rx = radians(t[4]/3600); //x-rotation: normalise arcseconds to radians
    final ry = radians(t[5]/3600); //y-rotation
    final rz = radians(t[6]/3600); //z-rotation

    //apply the transform
    final x2 = tx + x1*s - y1*rz + z1*ry;
    final y2 = ty + x1*rz + y1*s - z1*rx;
    final z2 = tz - x1*ry + y1*rx + z1*s;

    return new CartesianDatum(x2, y2, z2, null);
  }

}