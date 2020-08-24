# Latitude and Longitude to OS Grid Reference translator (and vice versa)

This package turns given latitude and longitude coordinates into an 12 digit OS Grid Reference and vice versa. The coordinates may be given in decimal format or degrees, minutes and seconds.

## Getting started

Add this to your app's `pubspec.yaml` file:
```
dependencies:
    latlong_to_osgrid: ^1.2.2
```

## Usage

Simply import the package as below and you can get going.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart'

class YourClass {

    //you can use the built in converter if you don't want to deal with OSRef and LatLong objects
    //see below for more examples using the converter
    void usingConverter() {
        LatLongConverter converter = new LatLongConverter();
        OSRef result = converter.getOSGBFromDec(53.9623, -1.0819);
        print("${result.numericalRef}"); //will output the easting and northing (460334 452192)
        print("${result.letterRef}"); //will output the letter pair reference (SE 60334 52192)
    }

    //or you can use OSRef and LatLong objects themselves for conversion
    void usingObjects() {
        LatLong latL = new LatLong(53.9623, -1.0819, 0, Datums.WGS84);
        OSRef osReference = latL.toOsGrid();
        print("${osReference.numericalRef}"); //will output the easting and northing as above
        print("${osReference.letterRef}"); //will output the letter pair reference as above
    }

}

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
        OSRef result = converter.getOSGBfromDec(lat, long);
        print("${result.easting} ${result.northing}");
    }

    //you can also define your own latitude and longitude object
    void yourOtherFunction(LatLong ll) {
        OSRef result = converter.getOSGBfromDec(ll.lat, ll.long);
        print("${result.easting} ${result.northing}");
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
        OSRef result = converter.getOSGBfromDms(latDeg, latMin, latSec, longDeg, longMin, longSec);
        print("${result.easting} ${result.northing}");
    }

}
```

## Getting Lat and Long from OS Grid

The following function returns a LatLong object which has the `lat`, `long`, `height`, and `datum` attributes. The latitude and longitude that result from this function are returned in decimal form. (See below to translate into degrees, minutes and seconds).
Using the LatLongConverter object, call the `getLatLongFromOSGB()` function with the easting and northing values of the OS Grid Reference.
It is possible to provide an OS Grid Reference in letter pair format (e.g. TG 51409 13177) rather than giving a separate easting and northing. To do this you can call the `getLatLongFromOSGBLetterRef()` function of the converter.
If you are creating an OSRef object yourself, you can create it with either an easting and northing or a letter pair reference. Whichever you use, the other is generated upon creation and can be accessed via the `numericalRef` and `letterRef` attributes of the OSRef object.

```dart
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class YourClass {

    LatLongConverter converter = new LatLongConverter();

    void yourFunction(int easting, int northing) {
        LatLong result = converter.getLatLongFromOSGB(easting, northing);
        print("${result.lat} ${result.long}");
    }

    void yourFunctionOne(String letterRef) {
        LatLong result = converter.getLatLongFromOSGBLetterRef(letterRef);
        print("${result.lat} ${result.long}");
    }

    //you can also define your own OSRef object
    void yourOtherFunction(OSRef os) {
        LatLong result = converter.getLatLongFromOSGB(os.easting, os.northing);
        print("${result.lat} ${result.long}");
    }

    void yourOtherFunctionOne(OSRef os) {
        LatLong result = converter.getLatLongFromOSGBLetterRef(os.letterRef);
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
        OSRef result = converter.getOSGBfromDec(lat, long, Datums.NAD27);
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
        double latDec = converter.getDecimalFromDegree(latDeg, latMin, latSec);
        double longDec = converter.getDecimalFromDegree(longDeg, longMin, longSec);
        print("$latDec $longDec");
    }

}
```

## Converting to JSON

Both the LatLong and OSRef objects have a `toJson()` function that allows them to be converted to JSON objects for easier storage. They also both have `fromJson()` constructors which allows you to use a JSON object with the specified attributes to create them.
LatLong JSON objects contain the following attributes: `latitude`, `longitude`, `height`, and `datum`.
OSRef JSON objects contain the following attributes: `easting`, `northing`, `numericalRef`, `letterRef` and `datum`.