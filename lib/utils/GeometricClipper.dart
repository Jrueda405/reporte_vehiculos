import 'package:flutter/cupertino.dart';

class GeometricClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height*0.75)
    ..lineTo(0, size.height)
    ..lineTo(0, 0)
    ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
  
    return false;
  }
}
