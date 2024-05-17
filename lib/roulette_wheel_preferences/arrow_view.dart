import 'dart:math';

import 'package:flutter/material.dart';

class RouletteArrowView extends StatelessWidget {
  const RouletteArrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );

    // return Align(
    //   alignment: Alignment.center,
    //   child: Transform.rotate(
    //     angle: pi,
    //     child: Padding(
    //       padding: EdgeInsets.only(top: 80),
    //       child: ClipPath(
    //         clipper: _RouletteArrowClipper(),
    //         child: Container(
    //           decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                   begin: Alignment.topCenter,
    //                   end: Alignment.bottomCenter,
    //                   colors: [Colors.black12, Colors.black])),
    //           height: 40,
    //           width: 40,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class _RouletteArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    _path.lineTo(_center.dx, size.height);
    _path.lineTo(size.width, 0);
    _path.lineTo(_center.dx, _center.dy);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
