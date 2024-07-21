import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/helpers/database.dart';
import '../lib/helpers/validator.dart';

class MockDatabase extends Mock implements Database {
  @override
  Future<bool> isEmailUnique(String email) async {
    return super.noSuchMethod(
      Invocation.method(#isEmailUnique, [email]),
      returnValue: Future<bool>.value(false),
      returnValueForMissingStub: Future<bool>.value(false),
    );
  }
}

void main() {
  late MockDatabase mockDatabase;
  late Validator validator;

  setUp(() {
    mockDatabase = MockDatabase();
    validator = Validator(mockDatabase);
  });

  group('Validator', () {
    test('validates correct email format', () {
      expect(validator.isValidEmailFormat('test@example.com'), true);
    });

    test('invalidates incorrect email format', () {
      expect(validator.isValidEmailFormat('test@com'), false);
      expect(validator.isValidEmailFormat('test.com'), false);
      expect(validator.isValidEmailFormat(''), false);
    });

    test('validates correct password', () {
      expect(validator.isValidPassword('Password1!'), true);
    });

    test('invalidates incorrect password', () {
      expect(validator.isValidPassword('short'), false);
      expect(validator.isValidPassword(''), false);
    });

    test('validates unique email', () async {
      when(mockDatabase.isEmailUnique('unique@example.com')).thenAnswer((_) async => true);
      final result = await validator.isEmailUnique('unique@example.com');
      expect(result, true);
    });

    test('invalidates non-unique email', () async {
      when(mockDatabase.isEmailUnique('duplicate@example.com')).thenAnswer((_) async => false);
      final result = await validator.isEmailUnique('duplicate@example.com');
      expect(result, false);
    });
  });
}