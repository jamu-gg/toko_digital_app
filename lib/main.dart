import 'package:flutter/material.dart'; // pustaka widget Material Design
import 'package:provider/provider.dart'; // pustaka Provider (state management)
import 'providers/product_provider.dart'; // provider produk
import 'providers/cart_provider.dart'; // provider keranjang
import 'pages/catalog_page.dart'; // halaman katalog (halaman awal)

void main() { // titik awal program Dart
  runApp(const TokoPancingApp()); // jalankan aplikasi dengan widget akar TokoPancingApp
} // akhir main

class TokoPancingApp extends StatelessWidget { // widget akar (Stateless = tampilan tidak menyimpan state sendiri)
  const TokoPancingApp({super.key}); // constructor konstan

  @override // menandakan fungsi ini menimpa fungsi bawaan StatelessWidget
  Widget build(BuildContext context) { // fungsi yang menyusun tampilan
    // MultiProvider mendaftarkan semua provider sekaligus agar bisa diakses halaman manapun.
    return MultiProvider( // pembungkus banyak provider
      providers: [ // daftar provider
        ChangeNotifierProvider(create: (_) => ProductProvider()), // buat & sediakan ProductProvider
        ChangeNotifierProvider(create: (_) => CartProvider()), // buat & sediakan CartProvider
      ], // akhir daftar provider
      child: MaterialApp( // aplikasi bergaya Material
        title: 'Toko Alat Pancing', // judul aplikasi
        debugShowCheckedModeBanner: false, // sembunyikan pita "DEBUG" di pojok
        theme: ThemeData( // tema tampilan global
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // skema warna dibuat dari warna dasar biru
          useMaterial3: true, // pakai desain Material 3
        ), // akhir tema
        home: const CatalogPage(), // halaman pertama yang tampil
      ), // akhir MaterialApp
    ); // akhir MultiProvider
  } // akhir build
} // akhir kelas
