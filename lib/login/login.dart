import 'package:finalproject_mobile/bottom_nav.dart';
import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/login/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  late SharedPreferences logindata;

  bool isLoginTrue = false;

  late bool newuser;

  final db = DBHelper();

  login() async {
    List<Map<String, dynamic>> akun = await db.getAkun(_username.text);
    setState(() {
      isLoginTrue = false;
    });

    if (akun.isNotEmpty) {
      String storedHashedPassword = akun[0]['userPassword'];
      print("Password di DB : " + storedHashedPassword);

      if (verifyPassword(_password.text, storedHashedPassword)) {
        logindata.setBool("login", false);
        logindata.setString("username", _username.text);

        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const BottomNavigation();
        }));
      }
    } else {
      setState(() {
        isLoginTrue = true;
      });
    }
  }

// Function to verify the password
  bool verifyPassword(String inputPassword, String storedHashedPassword) {
    return BCrypt.checkpw(inputPassword, storedHashedPassword);
  }

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkIfAlreadyLogin();
  }

  void checkIfAlreadyLogin() async {
    logindata = await SharedPreferences.getInstance();
    newuser = logindata.getBool('login') ?? true;
    print(newuser);
    if (!newuser) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const BottomNavigation();
      }));
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 62),
              Lottie.asset(
                "./assets/lottie/pc.json",
                width: 300,
                height: 250,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to ",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Ken",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    "Za",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _username,
                      validator: (value) {
                        if (value!.isEmpty) {}
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _password,
                      validator: (value) {
                        if (value!.isEmpty) {}
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        // You can customize other properties based on your preference
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    login();

                    isLoginTrue
                        ? ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Wrong Username or Password",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          )
                        : const SizedBox();
                  }
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const RegisterPage();
                  }));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have no account? ",
                      style: GoogleFonts.poppins(
                        textStyle:
                            TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                    Text(
                      "Register here",
                      style: GoogleFonts.poppins(
                        textStyle:
                            TextStyle(color: Colors.indigo, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to hash the password
  Future<String> hashPassword(String password) async {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}
