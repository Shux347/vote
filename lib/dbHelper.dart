// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import 'user.dart';

class DbHelper {
  Database? _db;

  static const dbName = 'user_account.db';
  static const String tableUser = 'user';
  static const int version = 1;

  static const String cUserId = 'user_id';
  static const String cUserName = 'user_name';
  static const String cEmail = 'email';
  static const String cPassword = 'password';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    Database db = await openDatabase(path, version: version, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $tableUser ("
        " $cUserId INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $cUserName TEXT, "
        " $cEmail TEXT UNIQUE,"
        " $cPassword TEXT"
        ")");
  }

  Future<int> saveData(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient.insert(tableUser, user.toMap());
    return res;
  }

  Future<UserModel?> getLoginUser(String userEmail, String password) async {
    var dbClient = await db;
    var res = await dbClient.query(
      tableUser,
      where: "$cEmail = ? AND $cPassword = ?",
      whereArgs: [userEmail, password],
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }

    return null;
  }

  Future<int> updateUser(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient.update(
      tableUser,
      user.toMap(),
      where: '$cEmail = ?',
      whereArgs: [user.userEmail],
    );
    return res;
  }

  Future<int> deleteUser(String userId) async {
    var dbClient = await db;
    var res = await dbClient.delete(
      tableUser,
      where: '$cUserId = ?',
      whereArgs: [userId],
    );
    return res;
  }
}
