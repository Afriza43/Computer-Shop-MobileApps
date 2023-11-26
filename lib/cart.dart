// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:finalproject_mobile/check_out.dart';
import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/models/Cart_model.dart';
import 'package:finalproject_mobile/models/UserModels.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  DBHelper dbHelper = DBHelper();
  List<Cart> cartList = [];
  // ignore: unused_field
  int _subtotal = 0;
  List<String> items = ['WIB', 'WITA', 'WIT', 'London'];
  String? selectedItem = 'WIB';
  late String userName = '';
  List<Users> userList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    getLoginData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void getLoginData() async {
    SharedPreferences logindata = await SharedPreferences.getInstance();
    setState(() {
      userName = logindata.getString('username') ?? "";
    });
    getCart();
    getUsers();
  }

  Future<List<Users>> getUsers() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Users>> userListFuture = dbHelper.getUsers(userName);
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

  Future<List<Cart>> getCart() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Cart>> cartListFuture = dbHelper.getCart(userName);
      cartListFuture.then((_cartList) {
        if (mounted) {
          setState(() {
            cartList = _cartList;
          });
        }
      });
    });
    int subtotal = 0;
    for (int i = 0; i < cartList.length; i++) {
      subtotal += cartList[i].jumlah * int.parse(cartList[i].harga);
    }
    setState(() {
      _subtotal = subtotal;
    });
    return cartList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Text("Shopping Cart",
                  style: GoogleFonts.montserrat(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
        actions: [
          buildProfileAvatar(userList.isNotEmpty ? userList[0].gambar : null),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : cartList.isEmpty
              ? _emptyCart()
              : _cartItem(),
      bottomNavigationBar: Visibility(
        visible: cartList.isEmpty ? false : true,
        child: BottomAppBar(
          color: Colors.white,
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Total Keranjang',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                              'Rp. ' +
                                  NumberFormat.currency(
                                          locale: 'ID',
                                          symbol: "",
                                          decimalDigits: 0)
                                      .format(_subtotal)
                                      .toString(),
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckoutPage(cartItems: cartList),
                        ),
                      );
                    },
                    child: Container(
                      height: 40.0,
                      child: Center(
                        child: Text('Checkout',
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            height: 70.0,
            padding:
                EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blueAccent,
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _cartItem() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<Cart>>(
                future: getCart(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF254DFF), Color(0xFF00C6FF)],
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(20.0),
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.network(
                                    cartList[i].gambar,
                                    height: 110.0,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(width: 25.0),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(cartList[i].nama,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              'Rp. ' +
                                                  NumberFormat.currency(
                                                          locale: 'ID',
                                                          symbol: "",
                                                          decimalDigits: 0)
                                                      .format(int.parse(
                                                              cartList[i]
                                                                  .harga) *
                                                          cartList[i].jumlah)
                                                      .toString(),
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold)),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                height: 30,
                                                width: 100,
                                                margin:
                                                    EdgeInsets.only(top: 10.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color: Colors.grey)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () {
                                                        if (cartList[i].jumlah >
                                                            1) {
                                                          _kurangJmlKeranjang(
                                                              cartList[i].id,
                                                              cartList[i]
                                                                  .userName);
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: Colors.redAccent,
                                                        size: 22,
                                                      ),
                                                    ),
                                                    Text(
                                                      cartList[i]
                                                          .jumlah
                                                          .toString(),
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14.0),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        _tambahJmlKeranjang(
                                                            cartList[i].id,
                                                            cartList[i]
                                                                .userName);
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color:
                                                            Colors.greenAccent,
                                                        size: 22,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10.0),
                                                  padding: EdgeInsets.only(
                                                      right: 10.0,
                                                      top: 7.0,
                                                      bottom: 5.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: InkWell(
                                                      onTap: () {
                                                        _deleteKeranjang(
                                                            cartList[i].id,
                                                            cartList[i]
                                                                .userName);
                                                      },
                                                      child: Container(
                                                        height: 25,
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: Colors.black,
                                                          size: 22,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 25.0),
                    child: Text(
                      calculateTimes(selectedItem!),
                      style: GoogleFonts.montserrat(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedItem,
                    items: items
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    onChanged: (item) {
                      setState(() {
                        selectedItem = item;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCart() {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: Future.delayed(const Duration(seconds: 1)),
            builder: (c, s) => s.connectionState == ConnectionState.done
                ? cartList.isEmpty
                    ? SafeArea(
                        child: new Container(
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: Lottie.asset(
                                    "./assets/lottie/cart_empty.json",
                                    width: 340,
                                    height: 300,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      ],
    );
  }

  _tambahJmlKeranjang(String id, String userName) async {
    Database db = await dbHelper.database;
    var batch = db.batch();
    db.execute('UPDATE computer SET jumlah=jumlah+1 WHERE id=? AND userName=?',
        [id, userName]);
    await batch.commit();
  }

  _kurangJmlKeranjang(String id, String userName) async {
    Database db = await dbHelper.database;
    var batch = db.batch();
    db.execute('UPDATE computer SET jumlah=jumlah-1 WHERE id=? AND userName=?',
        [id, userName]);
    await batch.commit();
  }

  _deleteKeranjang(String id, String userName) async {
    Database db = await dbHelper.database;
    var batch = db.batch();
    db.execute(
        'DELETE FROM computer WHERE id=? AND userName=?', [id, userName]);
    await batch.commit();
  }

  _kosongkanKeranjang(String userName) async {
    Database db = await dbHelper.database;
    var batch = db.batch();
    db.execute('DELETE FROM computer WHERE userName=?', [userName]);
    await batch.commit();
  }

  String calculateTimes(String selectedTimezone) {
    DateTime currentTime = DateTime.now();
    TimeOfDay currentLocalTime = TimeOfDay.fromDateTime(currentTime);

    DateTime convertedTime;
    switch (selectedTimezone) {
      case 'WITA':
        convertedTime = currentTime.add(Duration(hours: 1));
        break;
      case 'WIT':
        convertedTime = currentTime.add(Duration(hours: 2));
        break;
      case 'London':
        convertedTime = currentTime.subtract(Duration(hours: 7));
        break;
      default:
        convertedTime = currentTime; // WIB (default/current)
        break;
    }

    TimeOfDay convertedLocalTime = TimeOfDay.fromDateTime(convertedTime);
    return 'Waktu Checkout: ${formatTime(convertedLocalTime)}';
  }

  String formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
