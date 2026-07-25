import 'package:flutter/material.dart';
import 'package:mindora/app/di.dart';
import 'package:mindora/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(const MindoraApp());
}
