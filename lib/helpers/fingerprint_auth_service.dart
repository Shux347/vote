import 'package:local_auth/local_auth.dart';

class FingerprintAuthService {
  final LocalAuthentication _localAuth;

  FingerprintAuthService(this._localAuth);

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to register',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on Exception {
      return false;
    }
  }
}