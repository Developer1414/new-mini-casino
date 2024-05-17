import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'model.dart';

// class RouletteBoardView extends StatefulWidget {
//   final double angle;
//   final double current;
//   final double currentPlusAngle;
//   final List<RouletteLuck> items;

//   const RouletteBoardView(
//       {Key? key,
//       this.angle = 0,
//       this.current = 0,
//       this.items = const [],
//       this.currentPlusAngle = 0})
//       : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return _BoardViewState();
//   }
// }

// class _BoardViewState extends State<RouletteBoardView> {
//   Size get size => Size(MediaQuery.of(context).size.width * 0.7,
//       MediaQuery.of(context).size.width * 0.7);

//   double _rotote(int index) => (index / widget.items.length) * 2 * pi;

//   int getBallNumber(double ballAngle, int totalSectors) {
//     // Общий угол поворота колеса
//     double totalWheelAngle = widget.currentPlusAngle * 2 * pi;

//     // Определяем номер сектора, на котором остановился мяч
//     int sectorNumber =
//         ((ballAngle % totalWheelAngle) / (totalWheelAngle / totalSectors))
//             .floor();

//     // Увеличиваем номер сектора на 1, так как индексация начинается с 0
//     sectorNumber = sectorNumber + 1;

//     // Возвращаем номер сектора
//     return sectorNumber;
//   }

//   Widget line() {
//     return const SizedBox(
//       width: 180,
//       child: Divider(
//         thickness: 2.0,
//         color: Color(0xffa49458),
//       ),
//     );
//   }

//   Widget ball() {
//     return Transform.rotate(
//       angle: widget.currentPlusAngle * 2 * pi,
//       child: Transform.translate(
//         offset: Offset(0, MediaQuery.of(context).size.width / 3.8),
//         child: SizedBox(
//             height: 12,
//             width: 12,
//             child: Container(
//               height: 10,
//               width: 10,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//             )),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double ballAngle = widget.currentPlusAngle * 2 * pi;
//     print('Ball: ${getBallNumber(ballAngle, widget.items.length)}');

//     return Stack(
//       alignment: Alignment.center,
//       children: <Widget>[
//         Container(
//           height: size.height * 1.18,
//           width: size.width * 1.18,
//           decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [
//             BoxShadow(blurRadius: 20, color: Color.fromARGB(95, 0, 0, 0))
//           ]),
//         ),
//         Container(
//           height: size.height * 1.12,
//           width: size.width * 1.12,
//           decoration: const BoxDecoration(
//               shape: BoxShape.circle, color: Color(0xffcbb069)),
//         ),
//         Container(
//           height: size.height * 0.98,
//           width: size.width * 0.98,
//           decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [
//             BoxShadow(blurRadius: 20, color: Color.fromARGB(95, 0, 0, 0))
//           ]),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(width: 3.0, color: const Color(0xffa78641)),
//             shape: BoxShape.circle,
//           ),
//           child: Transform.rotate(
//             angle: -(widget.current + widget.angle) * 2 * pi,
//             child: Stack(
//               alignment: Alignment.center,
//               children: <Widget>[
//                 for (var luck in widget.items) ...[_buildCard(luck)],
//                 for (var luck in widget.items) ...[_buildImage(luck)],
//               ],
//             ),
//           ),
//         ),
//         Container(
//           height: size.height * 0.69,
//           width: size.width * 0.69,
//           decoration: BoxDecoration(
//             border: Border.all(width: 2.0, color: const Color(0xffa49458)),
//             shape: BoxShape.circle,
//           ),
//         ),
//         Container(
//           height: size.height * 0.83,
//           width: size.width * 0.83,
//           decoration: BoxDecoration(
//             border: Border.all(width: 2.0, color: const Color(0xffa49458)),
//             shape: BoxShape.circle,
//           ),
//         ),
//         ball(),
//       ],
//     );
//   }

//   _buildCard(RouletteLuck luck) {
//     var rotate = _rotote(widget.items.indexOf(luck));
//     var angle = 2 * pi / widget.items.length;
//     return Transform.rotate(
//       angle: rotate,
//       child: ClipPath(
//         clipper: _LuckPath(angle),
//         child: Container(
//           height: size.height,
//           width: size.width,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [luck.color, luck.color.withOpacity(0)])),
//         ),
//       ),
//     );
//   }

//   _buildImage(RouletteLuck luck) {
//     var rotate = _rotote(widget.items.indexOf(luck));
//     return Transform.rotate(
//       angle: rotate,
//       child: Container(
//         height: size.height,
//         width: size.width,
//         alignment: Alignment.topCenter,
//         child: ConstrainedBox(
//           constraints:
//               BoxConstraints.expand(height: size.height / 12, width: 34),
//           child: Center(
//             child: RotatedBox(
//               quarterTurns: 4,
//               child: Text(
//                 luck.value,
//                 style: GoogleFonts.roboto(
//                     fontSize: 12,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LuckPath extends CustomClipper<Path> {
//   final double angle;

//   _LuckPath(this.angle);

//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     Offset center = size.center(Offset.zero);
//     Rect rect = Rect.fromCircle(center: center, radius: size.width / 2);
//     path.moveTo(center.dx, center.dy);
//     path.arcTo(rect, -pi / 2 - angle / 2, angle, false);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(_LuckPath oldClipper) {
//     return angle != oldClipper.angle;
//   }
// }
