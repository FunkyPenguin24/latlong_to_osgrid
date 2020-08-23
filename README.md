# Latitude and Longitude to OS Grid Reference translator (and vice versa)

This package turns given latitude and longitude coordinates into an 12 digit OS Grid Reference and vice versa. The coordinates may be given in decimal format or degrees, minutes and seconds.

## Getting started

Add this to your app's `pubspec.yaml` file:
```
dependencies:
    latlong_to_osgrid: ^1.0.0
```

## Usage

Simply import the package and create a new LatLongConverter object to get going.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart'

class YourClass {

    LatLongConverter converter = new LatLongConverter();

}

```

The LatLongConverter object is used to get OS Grid References from Latitudes and Longitudes and vice versa. In doing this, it handles OSRef and LatLong objects that store their relevant attributes.

If you would like to instantiate a custom OSRef or LatLong object, you must import its class as follows.
OSRef objects must be given an easting and northing upon creation.
LatLong objects must be given a latitude, longitude, height and datum upon creation (import `Datums.dart` as below)

```dart
import 'package:latlong_to_osgrid/maths/OSRef.dart'; //for the OSRef object
import 'package:latlong_to_osgrid/maths/LatLong.dart'; //for the LatLong object
```

## Getting OS Grid from Lat and Long

The following functions return an OSRef object which has the attributes `easting` and `northing`.

### Using decimal Lat and Long

Using the LatLongConverter object, call the `getOSGBfromDec()` function with the decimal Lat and Long values. Unless told otherwise, the package takes these Lat and Long coordinates as being in the WGS84 datum (see below for custom datums)

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class YourClass {

    LatLongConverter converter = new LatLongConverter();

    void yourFunction(double lat, double long) {
        var result = converter.getOSGBfromDec(lat, long);
        print(${result.easting} ${result.northing});
    }

}
```

### Using degrees, minutes and seconds Lat and Long

Using the LatLongConverter object, call the `getOSGBfromDms()` function with the degrees, minutes and seconds values of the Lat and Long. If needs be, you can also call the `getDegreeFromDecimal()` function to convert from decimal lat or long to degree - the function returns a 3 element array where the degree value is the 1st element, minutes are the 2nd and seconds are the 3rd.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class YourClass {

    LatLongConverter converter = new LatLongConverter();

    void yourFunction(var latDeg, var latMin, var latSec, var longDeg, var longMin, var longSec) {
        var result = converter.getOSGBfromDms(latDeg, latMin, latSec, longDeg, longMin, longSec);
        print("${result.easting} ${result.northing}");
    }

}
```

## Getting Lat and Long from OS Grid

The following function returns a LatLong object which has the `lat`, `long`, `height`, and `datum` attributes. The latitude and longitude that result from this function are returned in decimal form. (See below to translate into degrees, minutes and seconds).
Using the LatLongConverter object, call the `getLatLongFromOSGB()` function with the easting and northing values of the OS Grid Reference.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class YourClass {

    LatLongConverter converter = new LatLongConverter();

    void yourFunction(var easting, var northing) {
        var result = converter.getLatLongFromOSGB(easting, northing);
        print("${result.lat} ${result.long}");
    }

}
```

## Specifying a custom datum

By default, the Lat and Long values are taken as though they are in the WGS84 datum. This is the most widely used datum and is used by GPS devices. If, for any reason, you would like to give or receive your Lat and Long coordinates in a different datum, you can import the `Datums.dart` file and give the required datum to the converter as below.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:latlong_to_osgrid/maths/Datums.dart';

class YourClass {

    LatLongConverter converter = new LatLongConverter();

    void yourFunction(double lat, double long) {
        var result = converter.getOSGBfromDec(lat, long, Datums.NAD27);
        print("${result.easting} ${result.northing}");
    }

}

```

The list of datums supported by this package are as follows:

    * OSGB36
    * WGS84
    * ED50
    * ETRS89
    * Irl1975
    * NAD27
    * NAD83
    * NTF
    * Potsdam
    * TokyoJapan
    * WGS72

## Switching between decimal and dms Lat and Long

As mentioned above, it is possible to use the LatLongConverter to change latitude and longitude values from decimal to degrees, minutes and seconds and vice versa.
This is done via the `getDegreeFromDecimal()` and `getDecimalFromDegree()` functions in the LatLongConverter object. Examples are given below.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class YourClass {

    LatLongConverter converter = new LatLongConverter();

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
```