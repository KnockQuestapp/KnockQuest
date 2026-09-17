import 'dart:io';

import 'package:knockquest/src/services/local_storage_service.dart';
import 'package:knockquest/src/state/auth_store.dart';

Future<void> initTestStorage() async {
  final buildDirectory = Directory('build');
  await buildDirectory.create(recursive: true);
  final storageDirectory = await buildDirectory.createTemp('test_hive_');
  await LocalStorageService.instance.init(path: storageDirectory.path);
  AuthStore.instance.currentUser.value = null;
  await LocalStorageService.instance.saveUser({
    'id': 'test_agent',
    'email': 'agent@knockquest.io',
    'name': 'Test Agent',
    'password': 'secret123',
  });
}
