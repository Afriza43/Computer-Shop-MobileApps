import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/helper/dbhistory.dart';
import 'package:finalproject_mobile/models/Cart_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CheckoutPage extends StatefulWidget {
  final List<Cart> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  HistoryDBHelper dbHelper = HistoryDBHelper();
  late String userName = "";

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

  saveHistory(String nama, int subtotal, String gambar, int quantity,
      String purchaseTime, String userName) async {
    Database db = await dbHelper.historyDatabase;
    var batch = db.batch();
    db.execute(
      'INSERT INTO riwayat_bayar (nama, subtotal, gambar, quantity, purchaseTime, userName) VALUES (?, ?, ?, ?, ?, ?)',
      [nama, subtotal, gambar, quantity, purchaseTime, userName],
    );
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout Pesanan',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Ringkasan Pesanan',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(height: 10),
            for (var item in widget.cartItems)
              Card(
                color: Colors.blueAccent,
                child: ListTile(
                  leading: Image.network(
                    item.gambar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.nama,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${item.jumlah} x ',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                          Text('${int.parse(item.harga) * item.jumlah}',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueAccent,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(
            children: [
              Text(
                'Total Harga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Rp ${calculateTotal()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () async {
                for (var item in widget.cartItems) {
                  await saveHistory(
                    item.nama,
                    int.parse(item.harga) * item.jumlah,
                    item.gambar,
                    item.jumlah,
                    DateTime.now().toLocal().toString(),
                    item.userName,
                  );
                }
                await clearCart();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Pembelian Berhasil',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Terima kasih atas pembelian Anda!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blueAccent,
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/bottom_nav');
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Selesaikan Pembelian',
                  style: GoogleFonts.montserrat(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  int calculateTotal() {
    int total = 0;
    for (var item in widget.cartItems) {
      total += int.parse(item.harga) * item.jumlah;
    }
    return total;
  }

  Future<void> clearCart() async {
    DBHelper dbHelper = DBHelper();
    Database db = await dbHelper.database;
    var batch = db.batch();
    for (var item in widget.cartItems) {
      batch.delete('computer',
          where: 'id = ? AND userName = ?',
          whereArgs: [item.id, item.userName]);
    }
    await batch.commit();
  }
}
