import 'package:flutter/material.dart'; // berisi ChangeNotifier
import '../models/product.dart'; // model Product
import '../models/cart_item.dart'; // model CartItem
import '../helpers/db_helper.dart'; // akses database

/// Provider keranjang: menyimpan isi keranjang di memori DAN di SQLite,
/// sehingga UI reaktif dan data tidak hilang saat aplikasi ditutup total.
class CartProvider extends ChangeNotifier { // provider keranjang belanja
  List<CartItem> _cartItems = []; // isi keranjang di memori, awalnya kosong

  List<CartItem> get cartItems => _cartItems; // getter agar halaman bisa membaca isi keranjang

  /// Total jumlah barang (jumlah seluruh quantity) -> untuk badge di ikon keranjang.
  int get totalItemCount { // getter dihitung otomatis
    int total = 0; // penampung hasil
    for (final item in _cartItems) { // telusuri semua item
      total += item.quantity; // tambahkan quantity tiap item
    } // akhir for
    return total; // kembalikan hasil
  } // akhir getter

  /// Total harga seluruh isi keranjang.
  double get totalPrice { // getter total harga
    double total = 0; // penampung hasil
    for (final item in _cartItems) { // telusuri semua item
      total += item.totalPrice; // tambahkan harga x jumlah tiap item
    } // akhir for
    return total; // kembalikan hasil
  } // akhir getter

  CartProvider() { // constructor
    loadCart(); // muat keranjang dari database begitu aplikasi dibuka
  } // akhir constructor

  /// Memuat ulang keranjang dari database (inilah yang membuat data tetap ada setelah restart).
  Future<void> loadCart() async { // async karena membaca database
    _cartItems = await DatabaseHelper.instance.getCartItems(); // baca semua baris local_cart
    notifyListeners(); // beri tahu UI agar diperbarui
  } // akhir fungsi

  /// Menambah produk dari katalog ke keranjang (jika sudah ada, cukup tambah quantity).
  Future<void> addToCart(Product product) async { // menerima produk yang dipilih
    final existingIndex = // cari posisi produk ini di keranjang
        _cartItems.indexWhere((item) => item.productId == product.id); // -1 jika tidak ketemu

    if (existingIndex >= 0) { // produk sudah ada di keranjang
      await increaseQuantity(_cartItems[existingIndex]); // tinggal naikkan quantity
    } else { // produk belum ada
      final newItem = CartItem( // buat item baru dengan quantity 1
        productId: product.id, // id produk
        name: product.name, // nama produk
        price: product.price, // harga produk
        quantity: 1, // jumlah awal 1
      ); // akhir item baru

      final newId = await DatabaseHelper.instance.insertCartItem(newItem); // simpan ke SQLite, dapat id baru

      _cartItems.add(CartItem( // simpan juga di memori agar UI langsung berubah
        id: newId, // id dari database
        productId: product.id, // id produk
        name: product.name, // nama produk
        price: product.price, // harga produk
        quantity: 1, // jumlah awal
      )); // akhir add

      notifyListeners(); // beri tahu UI
    } // akhir if-else
  } // akhir fungsi

  /// Tombol "+": menambah quantity.
  Future<void> increaseQuantity(CartItem item) async { // menerima item yang diubah
    item.quantity += 1; // naikkan jumlah di memori
    await DatabaseHelper.instance.updateCartItemQuantity(item.id!, item.quantity); // simpan ke SQLite
    notifyListeners(); // beri tahu UI
  } // akhir fungsi

  /// Tombol "-": mengurangi quantity; jika tinggal 1 lalu dikurangi, item dihapus.
  Future<void> decreaseQuantity(CartItem item) async { // menerima item yang diubah
    if (item.quantity > 1) { // jumlah masih lebih dari 1
      item.quantity -= 1; // kurangi jumlah di memori
      await DatabaseHelper.instance.updateCartItemQuantity(item.id!, item.quantity); // simpan ke SQLite
    } else { // jumlah tinggal 1
      await removeFromCart(item); // hapus item seluruhnya
      return; // selesai (removeFromCart sudah memanggil notifyListeners)
    } // akhir if-else
    notifyListeners(); // beri tahu UI
  } // akhir fungsi

  /// Menghapus item sepenuhnya dari keranjang.
  Future<void> removeFromCart(CartItem item) async { // menerima item yang dihapus
    await DatabaseHelper.instance.deleteCartItem(item.id!); // hapus baris di SQLite
    _cartItems.removeWhere((i) => i.id == item.id); // hapus juga dari memori
    notifyListeners(); // beri tahu UI
  } // akhir fungsi

  /// CHECKOUT: mengosongkan keranjang di database dan memori.
  Future<void> checkout() async { // dipanggil saat tombol Checkout dikonfirmasi
    await DatabaseHelper.instance.clearCart(); // hapus semua baris local_cart
    _cartItems = []; // kosongkan daftar di memori
    notifyListeners(); // beri tahu UI (halaman kembali menampilkan "keranjang kosong")
  } // akhir fungsi
} // akhir kelas
