import 'package:postgres/postgres.dart';
import 'dart:io';

void main() async {
  final uri = Uri.parse(Platform.environment['DATABASE_URL']!);
  var connection = PostgreSQLConnection(
    uri.host,
    uri.port,
    uri.pathSegments[1],
    username: uri.userInfo.split(':')[0],
    password: uri.userInfo.split(':')[1],
    useSSL: true,
  );

  await connection.open();

  // Create users table
  await connection.query('''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      role VARCHAR(50) NOT NULL,
      face_data BYTEA
    );
  ''');

  // Create elections table
  await connection.query('''
    CREATE TABLE IF NOT EXISTS elections (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL
    );
  ''');

  // Create election_users table
  await connection.query('''
    CREATE TABLE IF NOT EXISTS election_users (
      election_id INTEGER REFERENCES elections(id),
      user_email VARCHAR(255) REFERENCES users(email),
      PRIMARY KEY (election_id, user_email)
    );
  ''');

  // Create votes table
  await connection.query('''
    CREATE TABLE IF NOT EXISTS votes (
      id SERIAL PRIMARY KEY,
      election_id INTEGER REFERENCES elections(id),
      user_id INTEGER REFERENCES users(id)
    );
  ''');

  await connection.close();
  print('Migration completed.');
}
