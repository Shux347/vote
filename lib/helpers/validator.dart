import '../helpers/database.dart';

class Validator {
  final Database dbHelper;

  Validator(this.dbHelper);

  bool isValidEmailFormat(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  Future<bool> isEmailUnique(String email) async {
    return await dbHelper.isEmailUnique(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}