import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'src/knockquest_app.dart';
import 'src/services/local_storage_service.dart';
import 'src/services/supabase_service.dart';
import 'src/state/auth_store.dart';
import 'src/state/lead_store.dart';

void main() {
  runZonedGuarded(
    () async {
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
      await SupabaseService.instance.init();
      const localDataDir = String.fromEnvironment('LOCAL_DATA_DIR');
      await LocalStorageService.instance.init(
        path: localDataDir.isEmpty ? null : localDataDir,
      );
      await AuthStore.instance.init();
      LeadStore.instance.init();
      runApp(const KnockQuestApp());
    },
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
