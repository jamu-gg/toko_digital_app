/// Model Product = satu barang di toko. Kolomnya sama dengan tabel `master_products`: id, name, price.
class Product { // kelas cetakan data produk
  final int id; // id unik produk (final = tidak bisa diubah setelah dibuat)
  final String name; // nama produk
  final double price; // harga produk

  Product({ // constructor dengan parameter bernama
    required this.id, // id wajib diisi
    required this.name, // nama wajib diisi
    required this.price, // harga wajib diisi
  }); // akhir constructor

  /// Mengubah Map hasil query database menjadi objek Product.
  factory Product.fromMap(Map<String, dynamic> map) { // factory = constructor yang boleh mengembalikan objek baru
    return Product( // buat objek Product
      id: map['id'] as int, // ambil kolom id dan pastikan bertipe int
      name: map['name'] as String, // ambil kolom name bertipe String
      price: (map['price'] as num).toDouble(), // ambil price (angka) lalu ubah ke double agar aman
    ); // akhir pembuatan objek
  } // akhir factory

  /// Mengubah objek Product menjadi Map supaya bisa disimpan ke database.
  Map<String, dynamic> toMap() { // fungsi tanpa parameter, mengembalikan Map
    return { // kembalikan Map berisi pasangan kunci-nilai
      'id': id, // kolom id
      'name': name, // kolom name
      'price': price, // kolom price
    }; // akhir Map
  } // akhir fungsi
} // akhir kelas
