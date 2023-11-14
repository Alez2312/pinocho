// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

// Widget reutilizable para las burbujas decorativas
class TitleButton extends StatelessWidget {
  BuildContext context;
  final String title;
  final VoidCallback onTap;
  TitleButton(this.context, this.title, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}
