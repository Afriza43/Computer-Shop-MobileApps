class Users {
  final String userName;
  final String userPassword;
  final String gambar;

  Users(
      {required this.userName,
      required this.userPassword,
      required this.gambar});

  factory Users.fromMap(Map<String, dynamic> json) => Users(
      userName: json["userName"],
      userPassword: json["userPassword"],
      gambar: json["gambar"]);

  Map<String, dynamic> toMap() =>
      {"userName": userName, "userPassword": userPassword, "gambar": gambar};
}
