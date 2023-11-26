class History {
  final int id;
  final String nama;
  final int subtotal;
  final String gambar;
  final int quantity;
  final String purchaseTime;
  final String userName;

  History({
    required this.id,
    required this.nama,
    required this.subtotal,
    required this.gambar,
    required this.quantity,
    required this.purchaseTime,
    required this.userName,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        id: json['id'],
        nama: json['nama'],
        subtotal: json['subtotal'],
        gambar: json['gambar'],
        quantity: json['quantity'],
        purchaseTime: json['purchaseTime'],
        userName: json['userName'],
      );

  factory History.fromMap(Map<String, dynamic> map) => History(
        id: map['id'],
        nama: map['nama'],
        subtotal: map['subtotal'],
        gambar: map['gambar'],
        quantity: map['quantity'],
        purchaseTime: map['purchaseTime'],
        userName: map['userName'],
      );
}
