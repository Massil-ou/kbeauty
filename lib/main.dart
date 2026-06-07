import 'package:flutter/material.dart';
import 'App/Manager.dart';
import 'App/KBeautyApp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create Manager singleton
  final manager = Manager();
  await manager.bootstrap();

  runApp(KBeautyApp(manager: manager));
}
