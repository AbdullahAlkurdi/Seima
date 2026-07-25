import 'package:flutter/material.dart';
import 'package:seima/app/di.dart';
import 'package:seima/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(const SeimaApp());
}
