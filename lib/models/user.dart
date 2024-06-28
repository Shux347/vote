class User {
  final String id;
  final String email;
  final String password;
  final String role;
  final List<int> faceData;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.faceData,
  });
}
