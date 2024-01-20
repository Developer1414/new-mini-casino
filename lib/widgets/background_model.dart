import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:provider/provider.dart';

Widget backgroundModel() {
  return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 38, 51),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return !settingsController.isCutomBackground
              ? Image.asset(
                  'assets/backgrounds/background_${settingsController.currentDefaultBackgrond}.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ).blur(blur: settingsController.defaultBackgroundBlur)
              : Image.file(
                  settingsController.currentCustomBackgrond,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ).blur(blur: settingsController.customBackgroundBlur);
        },
      ));
}
