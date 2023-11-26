import 'dart:io';
import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/models/UserModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finalproject_mobile/login/login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences logindata;
  late String username = "";
  List<Users> userList = [];
  bool _isLoading = true;

  DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    initial();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username')!;
    });
    getUsers();
  }

  Future<List<Users>> getUsers() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Users>> userListFuture = dbHelper.getUsers(username);
      userListFuture.then((_userList) {
        if (mounted) {
          setState(() {
            userList = _userList;
          });
        }
      });
    });
    return userList;
  }

  final double coverHeight = 280;
  final double profileHeight = 144;

  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      Directory? appDocDir = await getExternalStorageDirectory();
      String appDocPath = appDocDir!.path;

      String destinationPath =
          '$appDocPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await imageTemp.copy(destinationPath);

      editFoto(destinationPath, username);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      Directory? appDocDir = await getExternalStorageDirectory();
      String appDocPath = appDocDir!.path;

      String destinationPath =
          '$appDocPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await imageTemp.copy(destinationPath);

      editFoto(destinationPath, username);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            buildTop(),
            buildContent(),
          ],
        ));
  }

  Widget buildTop() {
    final bottom = profileHeight / 2;
    final top = coverHeight - profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: imageProfile(),
        ),
      ],
    );
  }

  Widget buildContent() => Column(
        children: [
          const SizedBox(height: 20),
          Text(username,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
          const SizedBox(height: 5),
          Text("Password : ",
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.black,
              )),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: userList.isNotEmpty
                ? Text(
                    userList[0].userPassword,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    'No user data available',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent),
              onPressed: () {
                logindata.setBool("login", true);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
              },
              child: Text('Logout',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )))
        ],
      );

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: profileHeight / 2,
            backgroundImage: image != null
                ? FileImage(image!) as ImageProvider<Object>
                : (userList.isNotEmpty &&
                        userList[0].gambar != null &&
                        userList[0].gambar!.isNotEmpty)
                    ? FileImage(File(userList[0].gambar!))
                        as ImageProvider<Object>
                    : const AssetImage('assets/images/user_profile.png')
                        as ImageProvider<Object>,
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: ((builder) => bottomSheet()),
                );
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.teal,
                size: 28.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(children: <Widget>[
        const Text(
          "Choose Profile Photo",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(children: <Widget>[
          TextButton.icon(
              icon: const Icon(Icons.camera),
              onPressed: () {
                pickImageC();
              },
              label: const Text("Camera")),
          TextButton.icon(
              icon: const Icon(Icons.image),
              onPressed: () {
                pickImage();
              },
              label: const Text("Gallery")),
        ])
      ]),
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.white,
        child: Image.network(
          "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y29kaW5nfGVufDB8fDB8fHww",
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
        ),
      );

  editFoto(String gambar, String username) async {
    Database db = await dbHelper.database;
    var batch = db.batch();
    db.execute('UPDATE akun SET gambar=? WHERE userName=?', [gambar, username]);
    await batch.commit();
  }
}
