import 'package:flutter/material.dart';

Widget backgroundModel() {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 35, 38, 51),
    body: Image.asset(
      'assets/new-year.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    ),
  );
}
