class UserModel {
  String userName='';
  String userEmail='';
  String userPassword='';

  UserModel(this.userName, this.userEmail, this.userPassword);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_name': userName,
      'email': userEmail,
      'password': userPassword
    };
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    userName = map['user_name'];
    userEmail = map['email'];
    userPassword = map['password'];
  }
  
}