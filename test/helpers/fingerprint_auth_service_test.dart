import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import '../../lib/helpers/fingerprint_auth_service.dart';
import 'fingerprint_auth_service_test.mocks.dart';  // Import the generated mocks

void main() {
  late MockLocalAuthentication mockLocalAuth;
  late FingerprintAuthService authService;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    authService = FingerprintAuthService(mockLocalAuth);
  });

  group('FingerprintAuthService', () {
    test('should return true when authentication succeeds', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: 'Please authenticate to register',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      )).thenAnswer((_) async => true);

      final result = await authService.authenticate();
      expect(result, true);
    });

    test('should return false when authentication fails', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: 'Please authenticate to register',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      )).thenAnswer((_) async => false);

      final result = await authService.authenticate();
      expect(result, false);
    });

    test('should return false when an exception occurs', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: 'Please authenticate to register',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      )).thenThrow(Exception('Authentication error'));

      final result = await authService.authenticate();
      expect(result, false);
    });
  });
}