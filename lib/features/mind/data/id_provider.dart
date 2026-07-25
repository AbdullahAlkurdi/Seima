import 'dart:math';

final _random = Random();

String generateId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomPart = _random.nextInt(9999999);
  return '$timestamp$randomPart';
}
