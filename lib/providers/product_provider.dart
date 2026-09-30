import 'package:flutter/material.dart'; // berisi ChangeNotifier
import '../models/product.dart'; // model Product
import '../helpers/db_helper.dart'; // akses database

/// ChangeNotifier punya notifyListeners(): "pengeras suara" untuk memberi tahu
/// semua widget yang mendengarkan bahwa data berubah, sehingga tampilan dibangun ulang.
class ProductProvider extends ChangeNotifier { // provider daftar produk
  List<Product> _products = []; // daftar produk di memori (privat), awalnya kosong
  bool _isLoading = false; // penanda sedang memuat data atau tidak

  List<Product> get products => _products; // getter agar halaman bisa membaca daftar produk
  bool get isLoading => _isLoading; // getter status loading

  ProductProvider() { // constructor: dijalankan saat provider dibuat
    loadProducts(); // langsung muat produk dari database
  } // akhir constructor

  /// Mengambil semua produk dari database ke memori.
  Future<void> loadProducts() async { // async karena membaca database
    _isLoading = true; // tandai mulai loading
    notifyListeners(); // beri tahu UI agar menampilkan indikator loading

    _products = await DatabaseHelper.instance.getAllProducts(); // baca semua produk dari SQLite

    _isLoading = false; // tandai loading selesai
    notifyListeners(); // beri tahu UI agar menampilkan data produk
  } // akhir fungsi
} // akhir kelas
