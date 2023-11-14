// Widget reutilizable para las burbujas decorativas
import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final double radius;

  const Bubble(this.radius, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withOpacity(0.3),
    );
  }
}