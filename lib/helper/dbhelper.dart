import 'package:finalproject_mobile/models/Cart_model.dart';
import 'package:finalproject_mobile/models/UserModels.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DBHelper {
  static DBHelper? _dbHelper;
  static Database? _database;

  DBHelper._createObject();

  factory DBHelper() {
    if (_dbHelper == null) {
      _dbHelper = DBHelper._createObject();
    }
    return _dbHelper!;
  }

  Future<Database> initDb() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'computer1.db';
    var computerDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return computerDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE computer (
        id TEXT NOT NULL,
        nama TEXT,
        harga TEXT,
        gambar TEXT,
        tipe TEXT,
        deskripsi TEXT,
        jumlah INTEGER,
        userName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE akun (
        userName TEXT PRIMARY KEY,
        fullName TEXT,
        phone TEXT, 
        userPassword TEXT,
        gambar TEXT)
    ''');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database!;
  }

  Future<bool> login(Users user) async {
    final Database db = await initDb();

    var result = await db.rawQuery(
        "select * from akun where userName = '${user.userName}' AND userPassword = '${user.userPassword}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAkun(String userName) async {
    Database db = await initDb();
    var akun =
        await db.query("akun", where: 'userName = ?', whereArgs: [userName]);
    return akun;
  }

  Future<int> signUp(Users user) async {
    final Database db = await database;

    return db.insert('akun', user.toMap());
  }

  Future<List<Map<String, dynamic>>> selectkeranjang(String userName) async {
    Database db = await database;
    var mapList = await db
        .query('computer', where: 'userName = ?', whereArgs: [userName]);
    return mapList;
  }

  Future<List<Cart>> getCart(String userName) async {
    var mapList = await selectkeranjang(userName);
    int count = mapList.length;
    List<Cart> list = [];
    for (int i = 0; i < count; i++) {
      list.add(Cart.fromMap(mapList[i]));
    }
    return list;
  }

  Future<Map<String, dynamic>> getUserProfileById(String userName) async {
    Database db = await initDb();

    var result =
        await db.query("akun", where: 'userName = ?', whereArgs: [userName]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> selectUser(String userName) async {
    Database db = await database;
    var mapList =
        await db.query('akun', where: 'userName = ?', whereArgs: [userName]);
    return mapList;
  }

  Future<List<Users>> getUsers(String userName) async {
    var mapList = await selectUser(userName);
    int count = mapList.length;
    List<Users> list = [];
    for (int i = 0; i < count; i++) {
      list.add(Users.fromMap(mapList[i]));
    }
    return list;
  }
}
