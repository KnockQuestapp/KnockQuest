import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'src/knockquest_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log(
      details.exceptionAsString(),
      name: 'knockquest.flutter_error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
    () => runApp(const KnockQuestApp()),
    (error, stackTrace) {
      log(
        'Uncaught zone error',
        name: 'knockquest.zone_error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
