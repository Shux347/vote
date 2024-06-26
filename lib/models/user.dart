class UserModel {
  final String userName;
  final String userEmail;
  final String userPassword;
  String faceImagePath;

  UserModel(this.userName, this.userEmail, this.userPassword, {required this.faceImagePath});

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'userPassword': userPassword,
      'faceImagePath': faceImagePath,
    };
  }
}
