import 'package:sqflite/sqflite.dart'; // pustaka SQLite untuk Flutter (openDatabase, Database, dll)
import 'package:path/path.dart'; // pustaka path, dipakai untuk fungsi join()
import '../models/product.dart'; // model Product
import '../models/cart_item.dart'; // model CartItem

/// DatabaseHelper berpola Singleton: hanya ada SATU objek di seluruh aplikasi,
/// sehingga koneksi database dipakai bersama dan datanya konsisten.
class DatabaseHelper { // kelas pengelola database
  static final DatabaseHelper instance = DatabaseHelper._internal(); // satu-satunya objek (static = milik kelas)

  DatabaseHelper._internal(); // constructor privat (awalan _) agar tidak bisa dibuat dari luar

  static Database? _database; // penyimpan koneksi database, awalnya null (belum dibuka)

  /// Getter database: pakai koneksi yang ada, atau buka dulu bila belum ada.
  Future<Database> get database async { // async karena membuka database butuh waktu
    if (_database != null) return _database!; // jika sudah ada, langsung pakai (! = pasti tidak null)
    _database = await _initDB(); // jika belum, buka/buat database dan tunggu selesai
    return _database!; // kembalikan koneksi
  } // akhir getter

  /// Menentukan lokasi file database lalu membukanya.
  Future<Database> _initDB() async { // fungsi privat untuk inisialisasi
    final dbPath = await getDatabasesPath(); // folder standar penyimpanan database di HP
    final path = join(dbPath, 'toko_pancing.db'); // gabungkan folder + nama file

    return await openDatabase( // buka (atau buat jika belum ada) file database
      path, // lokasi file
      version: 1, // versi skema database
      onCreate: _onCreate, // dijalankan SEKALI saat database pertama kali dibuat
    ); // akhir openDatabase
  } // akhir fungsi

  /// Membuat kedua tabel lalu mengisi data awal produk.
  Future<void> _onCreate(Database db, int version) async { // db = database yang baru dibuat
    await db.execute(''' 
      CREATE TABLE master_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    '''); // tabel 1: master_products (id, name, price); id otomatis bertambah

    await db.execute(''' 
      CREATE TABLE local_cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL
      )
    '''); // tabel 2: local_cart (id, product_id, name, price, quantity)

    await _seedProducts(db); // isi tabel produk dengan data awal
  } // akhir _onCreate

  /// Mengisi data awal supaya katalog tidak kosong saat pertama kali dibuka.
  Future<void> _seedProducts(Database db) async { // menerima database yang akan diisi
    final produkAwal = [ // daftar produk awal (List berisi Map)
      {'name': 'Joran Carbon Fiber 180cm', 'price': 150000.0}, // produk 1
      {'name': 'Reel Spinning Power X 3000', 'price': 120000.0}, // produk 2
      {'name': 'Senar Fluorocarbon 100m', 'price': 35000.0}, // produk 3
      {'name': 'Kail Pancing Set Isi 20', 'price': 15000.0}, // produk 4
      {'name': 'Umpan Buatan Soft Lure', 'price': 25000.0}, // produk 5
      {'name': 'Pelampung Pancing Set', 'price': 10000.0}, // produk 6
      {'name': 'Kotak Pancing Portable', 'price': 85000.0}, // produk 7
      {'name': 'Timah Pemberat 50gr', 'price': 8000.0}, // produk 8
    ]; // akhir daftar

    for (final produk in produkAwal) { // ulangi untuk setiap produk
      await db.insert('master_products', produk); // masukkan satu baris ke tabel master_products
    } // akhir for
  } // akhir fungsi

  // ================= OPERASI TABEL master_products =================

  /// Mengambil seluruh produk dari database.
  Future<List<Product>> getAllProducts() async { // mengembalikan daftar Product
    final db = await database; // ambil koneksi database
    final result = await db.query('master_products'); // SELECT * FROM master_products
    return result.map((row) => Product.fromMap(row)).toList(); // ubah tiap baris jadi Product
  } // akhir fungsi

  // ===================== OPERASI TABEL local_cart ====================

  /// Mengambil seluruh isi keranjang.
  Future<List<CartItem>> getCartItems() async { // mengembalikan daftar CartItem
    final db = await database; // ambil koneksi database
    final result = await db.query('local_cart'); // SELECT * FROM local_cart
    return result.map((row) => CartItem.fromMap(row)).toList(); // ubah tiap baris jadi CartItem
  } // akhir fungsi

  /// Menambah item baru ke keranjang; mengembalikan id baris baru.
  Future<int> insertCartItem(CartItem item) async { // menerima item yang akan disimpan
    final db = await database; // ambil koneksi database
    return await db.insert('local_cart', item.toMap()); // INSERT INTO local_cart ...
  } // akhir fungsi

  /// Mengubah jumlah (quantity) item berdasarkan id-nya.
  Future<int> updateCartItemQuantity(int cartItemId, int newQuantity) async { // id item + jumlah baru
    final db = await database; // ambil koneksi database
    return await db.update( // UPDATE local_cart SET quantity = ? WHERE id = ?
      'local_cart', // nama tabel
      {'quantity': newQuantity}, // kolom yang diubah
      where: 'id = ?', // syarat baris yang diubah (? diisi whereArgs, aman dari SQL injection)
      whereArgs: [cartItemId], // nilai pengganti tanda ?
    ); // akhir update
  } // akhir fungsi

  /// Menghapus satu item dari keranjang.
  Future<int> deleteCartItem(int cartItemId) async { // menerima id item
    final db = await database; // ambil koneksi database
    return await db.delete( // DELETE FROM local_cart WHERE id = ?
      'local_cart', // nama tabel
      where: 'id = ?', // syarat baris yang dihapus
      whereArgs: [cartItemId], // nilai pengganti tanda ?
    ); // akhir delete
  } // akhir fungsi

  /// Mengosongkan seluruh keranjang (dipakai saat checkout).
  Future<int> clearCart() async { // tanpa parameter
    final db = await database; // ambil koneksi database
    return await db.delete('local_cart'); // DELETE FROM local_cart (tanpa where = hapus semua)
  } // akhir fungsi
} // akhir kelas
