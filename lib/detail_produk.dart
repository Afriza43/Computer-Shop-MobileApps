import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/models/Cart_model.dart';
import 'package:finalproject_mobile/models/ComputerParts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DetailPC extends StatefulWidget {
  final Computer komputer;
  const DetailPC({Key? key, required this.komputer}) : super(key: key);

  @override
  State<DetailPC> createState() => _DetailPCState();
}

class _DetailPCState extends State<DetailPC> {
  int quantity = 1;
  String selectedCurrency = 'IDR';
  double exchangeRate = 1.0;
  late double _harga;

  late SharedPreferences logindata;
  late String userName = '';

  DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  void getLoginData() async {
    SharedPreferences logindata = await SharedPreferences.getInstance();
    setState(() {
      userName = logindata.getString('username') ?? "";
    });
  }

  Future<bool> saveOrUpdateCart(Cart cartItem) async {
    try {
      Database db = await dbHelper.database;

      List<Map<String, dynamic>> result = await db.query(
        'computer',
        where: 'id = ? AND userName = ?',
        whereArgs: [cartItem.id, cartItem.userName],
      );

      if (result.isNotEmpty) {
        await db.update(
          'computer',
          {'jumlah': cartItem.jumlah},
          where: 'id = ? AND userName = ?',
          whereArgs: [cartItem.id, cartItem.userName],
        );
      } else {
        await db.insert(
          'computer',
          {
            'id': cartItem.id,
            'nama': cartItem.nama,
            'harga': cartItem.harga,
            'gambar': cartItem.gambar,
            'tipe': cartItem.tipe,
            'deskripsi': cartItem.deskripsi,
            'jumlah': cartItem.jumlah,
            'userName': cartItem.userName
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return true; // Success
    } catch (e) {
      print('Error saving/updating cart: $e');
      return false; // Failure
    }
  }

  @override
  Widget build(BuildContext context) {
    _harga = double.parse(widget.komputer.harga);

    return Scaffold(
      appBar: AppBar(
        actions: [
          buildProfileAvatar('https://i.ibb.co/rp6BG70/ken.jpg'),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    child: Image.network(
                      widget.komputer.gambar,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Product Name
              Container(
                child: Text(
                  widget.komputer.nama,
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  widget.komputer.deskripsi,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          'Price:',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedCurrency == 'IDR'
                              ? NumberFormat.currency(
                                      locale: 'ID',
                                      symbol: "Rp",
                                      decimalDigits: 0)
                                  .format(_harga)
                                  .toString()
                              : selectedCurrency == 'USD'
                                  ? NumberFormat.currency(
                                          locale: 'en_US',
                                          symbol: "\u0024",
                                          decimalDigits: 0)
                                      .format(_harga * 0.000064)
                                      .toString()
                                  : selectedCurrency == 'SGD'
                                      ? NumberFormat.currency(
                                              locale: 'en_US',
                                              symbol: "S\u0024",
                                              decimalDigits: 0)
                                          .format(_harga * 0.000086)
                                          .toString()
                                      : "",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        focusColor: Colors.white,
                        dropdownColor: Colors.white,
                        items: ['IDR', 'USD', 'SGD']
                            .map((currency) => DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(
                                    currency,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCurrency = value!;
                            if (selectedCurrency == 'USD') {
                              exchangeRate = 15.658;
                            } else if (selectedCurrency == 'SGD') {
                              exchangeRate = 11.637;
                            } else {
                              exchangeRate = 1.0;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 80.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (quantity > 1) {
                          quantity--;
                        }
                      });
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      quantity.toString(),
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  Cart cartItem = Cart(
                      id: widget.komputer.id,
                      nama: widget.komputer.nama,
                      harga: widget.komputer.harga,
                      gambar: widget.komputer.gambar,
                      tipe: widget.komputer.tipe.toString().split('.').last,
                      deskripsi: widget.komputer.deskripsi,
                      jumlah: quantity,
                      userName: userName);

                  // Save or update cart based on item existence
                  bool success = await saveOrUpdateCart(cartItem);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Item added/updated in cart successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add/update item in cart'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileAvatar(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        radius: 30, // Adjust the radius as needed
      ),
    );
  }
}
