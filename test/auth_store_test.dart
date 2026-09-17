import 'package:flutter_test/flutter_test.dart';
import 'package:knockquest/src/state/auth_store.dart';

import 'test_storage.dart';

void main() {
  setUp(initTestStorage);

  test(
    'local account requires its registered password and survives sign out',
    () async {
      final auth = AuthStore.instance;
      expect(await auth.signIn('someone@example.com', 'password'), isFalse);

      expect(
        await auth.signUp('owner@example.com', 'test-secret', 'Owner'),
        isTrue,
      );
      expect(auth.currentUser.value, isNull);
      expect(await auth.signIn('owner@example.com', 'wrong'), isFalse);
      expect(await auth.signIn('owner@example.com', 'test-secret'), isTrue);

      await auth.signOut();
      expect(auth.currentUser.value, isNull);
      expect(await auth.signIn('owner@example.com', 'test-secret'), isTrue);
    },
  );
}
