class Dms {

  wrap360(var degrees) {
    if (0 <= degrees && degrees < 360)
      return degrees;
    return (degrees % 360 + 360) % 360;
  }

  wrap180(var degrees) {
    if (-180<degrees && degrees <= 180)
      return degrees;
    return (degrees+540)%360-180;
  }

  wrap90(var degrees) {
    if (-90 <= degrees && degrees <= 90)
      return degrees;
    return (((degrees%360 + 270)%360 - 180).abs - 90);
  }

}