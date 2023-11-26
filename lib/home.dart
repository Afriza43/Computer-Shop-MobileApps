// ignore_for_file: unused_local_variable,
import 'dart:io';
import 'dart:math';

import 'package:finalproject_mobile/detail_produk.dart';
import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/models/ComputerParts.dart';
import 'package:finalproject_mobile/models/UserModels.dart';
import 'package:finalproject_mobile/services/remote_service.dart';
import 'package:finalproject_mobile/starrating.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late SharedPreferences logindata;
  // late String username;

  String username = "";
  DBHelper dbHelper = DBHelper();

  final TextEditingController _searchController = TextEditingController();
  List<Computer>? computers;
  List<Computer>? filteredComputers;
  List<Users> userList = [];
  var isLoaded = false;
  Tipe selectedTipe = Tipe.MOTHERBOARD;

  @override
  void initState() {
    super.initState();
    //fetch data from API
    getData();
    initial();
  }

  getData() async {
    computers = await RemoteService().getComputers();
    if (computers != null) {
      setState(() {
        isLoaded = true;
        filteredComputers = computers;
      });
    }
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

  void initial() async {
    SharedPreferences logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username') ?? "";
    });
    getUsers();
  }

  void onSearchTextChanged(String query) {
    setState(() {
      filteredComputers = computers
          ?.where((computer) =>
              computer.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Welcome $username',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          buildProfileAvatar(userList.isNotEmpty ? userList[0].gambar : null),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
              onChanged: onSearchTextChanged,
              decoration: InputDecoration(
                hintText: 'Search Computer Parts',
                hintStyle: GoogleFonts.libreFranklin(
                  color: Colors.grey,
                  fontSize: 17,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(80.0),
                ),
                filled: true,
                fillColor: const Color(0xffEAF2F9),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 25.0),
              child: Text(
                'Discover Our Products',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Adjust as needed
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 25.0, bottom: 5.0),
                  child: Text(
                    'Top Sales',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, right: 20.0),
                  child: DropdownButton<Tipe>(
                    value: selectedTipe,
                    onChanged: (Tipe? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedTipe = newValue;
                        });
                      }
                    },
                    items: Tipe.values.map((Tipe tipe) {
                      return DropdownMenuItem<Tipe>(
                        value: tipe,
                        child: Text(
                          tipe.toString().split('.').last,
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 180, // Set the height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: computers?.length ?? 0,
                itemBuilder: (context, index) {
                  if (computers == null) {
                    return const SizedBox();
                  }
                  final Computer pc = computers![index];
                  final double randomRating = Random().nextDouble() * 5.0;

                  // Perform the comparison without null checks
                  if (pc.tipe == selectedTipe) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        bottom: 20.0,
                      ),
                      child: Container(
                        width: 165,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF254DFF), Color(0xFF00C6FF)],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                pc.gambar,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              pc.nama,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              pc.harga,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: _searchController.text.isEmpty
                    ? ListView.builder(
                        itemCount: computers != null ? computers!.length : 0,
                        itemBuilder: (context, index) {
                          final Computer pc = computers![index];
                          final double randomRating =
                              Random().nextDouble() * 5.0;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return DetailPC(komputer: pc);
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 10,
                              ),
                              child: SizedBox(
                                width: 280,
                                height: 60,
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            pc.gambar,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                pc.nama,
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              StarRating(rating: randomRating),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: filteredComputers != null
                            ? filteredComputers!.length
                            : 0,
                        itemBuilder: (context, index) {
                          final Computer pc = filteredComputers![index];
                          final double randomRating =
                              Random().nextDouble() * 5.0;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return DetailPC(komputer: pc);
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: SizedBox(
                                width:
                                    280, // Adjust the width according to your layout
                                height: 60,
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(12),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              pc.gambar,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                pc.nama,
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              StarRating(rating: randomRating),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileAvatar(String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? FileImage(File(imageUrl))
            : AssetImage('assets/images/user_profile.png')
                as ImageProvider<Object>,
        radius: 30, // Sesuaikan radius sesuai kebutuhan
      ),
    );
  }
}
