import 'dart:async';
import 'dart:developer';

void logger(
  String message,
  String kind, {
  DateTime? when,
  Level level = Level.finest,
}) {
  DateTime time = DateTime.now();

  if (when != null) {
    time = when;
  }

  log(
    message,
    name: kind,
    level: level.value,
    time: time,
    stackTrace: StackTrace.current,
    zone: Zone.current,
  );
}

enum Level {
  all(0),
  finest(300),
  finer(400),
  fine(500),
  config(700),
  info(800),
  warning(900),
  shout(1200),
  severe(1000),
  off(20000);

  final int value;

  const Level(this.value);
}
