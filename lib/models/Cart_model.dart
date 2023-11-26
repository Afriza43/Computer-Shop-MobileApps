class Cart {
  final String id;
  final String nama;
  final String harga;
  final String gambar;
  final String tipe;
  final String deskripsi;
  final int jumlah;
  final String userName;

  Cart({
    required this.id,
    required this.nama,
    required this.harga,
    required this.gambar,
    required this.tipe,
    required this.deskripsi,
    required this.jumlah,
    required this.userName,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        nama: json["nama"],
        harga: json["harga"],
        gambar: json["gambar"],
        tipe: json["tipe"],
        deskripsi: json["deskripsi"],
        jumlah: json["jumlah"],
        userName: json["userName"],
      );

  factory Cart.fromMap(Map<String, dynamic> map) => Cart(
        id: map['id'],
        nama: map['nama'],
        harga: map['harga'],
        gambar: map['gambar'],
        tipe: map['tipe'],
        deskripsi: map['deskripsi'],
        jumlah: map['jumlah'],
        userName: map['userName'],
      );
}
