import 'dart:io';

import 'package:finalproject_mobile/helper/dbhelper.dart';
import 'package:finalproject_mobile/models/UserModels.dart';
import 'package:flutter/material.dart';
import 'package:finalproject_mobile/helper/dbhistory.dart';
import 'package:finalproject_mobile/models/HistoryModel.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryDBHelper dbHelper = HistoryDBHelper();
  DBHelper db_Helper = DBHelper();
  List<History> historyList = [];
  late String userName = '';
  bool _isLoading = true;
  List<Users> userList = [];

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
    getHistory();
    getUsers();
  }

  Future<List<Users>> getUsers() async {
    final Future<Database> dbFuture = db_Helper.initDb();
    dbFuture.then((database) {
      Future<List<Users>> userListFuture = db_Helper.getUsers(userName);
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

  Future<List<History>> getHistory() async {
    final Future<Database> dbHistoryFuture = dbHelper.initHistoryDb();
    dbHistoryFuture.then((historyDatabase) {
      final Future<List<History>> historyListFuture =
          dbHelper.getHistory(userName);
      historyListFuture.then((_historyList) {
        if (mounted) {
          setState(() {
            historyList = _historyList;
          });
        }
      });
    });
    return historyList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Text(
                'Pembelian Produk',
                style: GoogleFonts.montserrat(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          buildProfileAvatar(userList.isNotEmpty ? userList[0].gambar : null),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : historyList.isEmpty
              ? _emptyHistory()
              : _historyItem(),
    );
  }

  Widget _historyItem() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<History>>(
                future: getHistory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      History history = historyList[index];
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(20.0),
                            title: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Image.network(
                                        history.gambar,
                                        height: 80.0,
                                        width: 80.0,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 20.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              history.nama,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Subtotal: ${history.subtotal} Quantity: ${history.quantity}',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Purchase Time: ${_formatDateTime(history.purchaseTime)}',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteHistory(history.id);
                              },
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
          ],
        ),
      ),
    );
  }

  Widget _emptyHistory() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/no_history.json',
                    width: 330,
                    height: 280,
                  ),
                  Text(
                    'No History',
                    style: GoogleFonts.poppins(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTime) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return "${parsedDateTime.day}-${parsedDateTime.month}-${parsedDateTime.year}";
  }

  _deleteHistory(int id) async {
    Database db = await dbHelper.historyDatabase;
    var batch = db.batch();
    db.execute('DELETE FROM riwayat_bayar WHERE id=?', [id]);
    await batch.commit();
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
