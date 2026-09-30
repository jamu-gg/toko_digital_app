import 'package:flutter/material.dart'; // pustaka widget Material
import 'package:provider/provider.dart'; // untuk context.watch / context.read
import '../providers/product_provider.dart'; // provider produk
import '../providers/cart_provider.dart'; // provider keranjang
import '../models/product.dart'; // model Product
import '../helpers/format_helper.dart'; // formatRupiah
import '../helpers/icon_helper.dart'; // getIconForProduct
import 'cart_page.dart'; // halaman keranjang

class CatalogPage extends StatelessWidget { // halaman katalog produk
  const CatalogPage({super.key}); // constructor konstan

  @override // menimpa fungsi bawaan
  Widget build(BuildContext context) { // menyusun tampilan halaman
    // watch: halaman dibangun ulang otomatis setiap provider memanggil notifyListeners()
    final productProvider = context.watch<ProductProvider>(); // pantau perubahan produk
    final cartProvider = context.watch<CartProvider>(); // pantau perubahan keranjang

    return Scaffold( // kerangka halaman (appBar + body)
      appBar: AppBar( // bilah judul di atas
        title: const Text('Toko Alat Pancing'), // teks judul
        actions: [ // widget di sisi kanan appBar
          Padding( // beri jarak di sisi kanan
            padding: const EdgeInsets.only(right: 12), // jarak kanan 12
            child: Stack( // Stack = menumpuk widget (ikon + badge angka)
              alignment: Alignment.center, // posisi anak di tengah
              children: [ // daftar widget yang ditumpuk
                IconButton( // tombol ikon keranjang
                  icon: const Icon(Icons.shopping_cart), // gambar ikon keranjang
                  onPressed: () { // aksi saat ditekan
                    Navigator.push( // pindah ke halaman lain
                      context, // konteks saat ini
                      MaterialPageRoute(builder: (_) => const CartPage()), // buka CartPage
                    ); // akhir push
                  }, // akhir onPressed
                ), // akhir IconButton
                if (cartProvider.totalItemCount > 0) // tampilkan badge hanya jika keranjang tidak kosong
                  Positioned( // menempatkan badge pada posisi tertentu di Stack
                    top: 6, // jarak dari atas
                    right: 6, // jarak dari kanan
                    child: Container( // kotak bulat merah untuk badge
                      padding: const EdgeInsets.all(4), // jarak dalam
                      decoration: const BoxDecoration( // hiasan kotak
                        color: Colors.red, // warna latar merah
                        shape: BoxShape.circle, // berbentuk lingkaran
                      ), // akhir decoration
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18), // ukuran minimum badge
                      child: Text( // angka jumlah barang
                        '${cartProvider.totalItemCount}', // ubah angka menjadi teks
                        style: const TextStyle(color: Colors.white, fontSize: 11), // putih, kecil
                        textAlign: TextAlign.center, // rata tengah
                      ), // akhir Text
                    ), // akhir Container
                  ), // akhir Positioned
              ], // akhir children Stack
            ), // akhir Stack
          ), // akhir Padding
        ], // akhir actions
      ), // akhir AppBar
      body: productProvider.isLoading // jika sedang memuat...
          ? const Center(child: CircularProgressIndicator()) // ...tampilkan lingkaran loading
          : GridView.builder( // ...jika tidak, tampilkan grid produk (dibuat sesuai kebutuhan / lazy)
              padding: const EdgeInsets.all(12), // jarak grid dari tepi layar
              itemCount: productProvider.products.length, // jumlah item grid
              // MaxCrossAxisExtent: jumlah kolom menyesuaikan lebar layar (responsif),
              // tiap kartu maksimal 200 px lebar -> HP kecil 2 kolom, tablet lebih banyak kolom.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent( // pengatur tata letak grid
                maxCrossAxisExtent: 200, // lebar maksimum tiap kartu
                crossAxisSpacing: 12, // jarak antar kolom
                mainAxisSpacing: 12, // jarak antar baris
                childAspectRatio: 0.7, // rasio lebar:tinggi kartu
              ), // akhir gridDelegate
              itemBuilder: (context, index) { // fungsi pembuat kartu ke-index
                final Product product = productProvider.products[index]; // ambil produk ke-index
                return _ProductCard( // tampilkan kartu produk
                  product: product, // data produk
                  icon: getIconForProduct(product.name), // ikon sesuai nama produk
                  onAddToCart: () { // aksi saat tombol tambah ditekan
                    cartProvider.addToCart(product); // masukkan produk ke keranjang
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // tutup snackbar lama agar tidak menumpuk
                    ScaffoldMessenger.of(context).showSnackBar( // tampilkan pesan singkat di bawah
                      SnackBar( // bilah pesan
                        content: Text('${product.name} ditambahkan ke keranjang'), // isi pesan
                        duration: const Duration(milliseconds: 800), // tampil 0,8 detik
                      ), // akhir SnackBar
                    ); // akhir showSnackBar
                  }, // akhir onAddToCart
                ); // akhir _ProductCard
              }, // akhir itemBuilder
            ), // akhir GridView
    ); // akhir Scaffold
  } // akhir build
} // akhir kelas

/// Kartu produk, dipisah agar kode rapi.
class _ProductCard extends StatelessWidget { // kelas privat (awalan _) hanya dipakai di berkas ini
  final Product product; // data produk yang ditampilkan
  final IconData icon; // ikon produk
  final VoidCallback onAddToCart; // fungsi yang dipanggil saat tombol tambah ditekan

  const _ProductCard({ // constructor konstan
    required this.product, // produk wajib
    required this.icon, // ikon wajib
    required this.onAddToCart, // aksi wajib
  }); // akhir constructor

  @override // menimpa fungsi bawaan
  Widget build(BuildContext context) { // menyusun tampilan kartu
    return Card( // Card = kotak dengan bayangan & sudut bulat
      elevation: 3, // ketebalan bayangan
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // sudut membulat 12
      child: Padding( // jarak dalam kartu
        padding: const EdgeInsets.all(10), // jarak 10 ke semua sisi
        child: Column( // susunan vertikal: ikon, nama, baris harga
          children: [ // daftar anak Column
            // Expanded: area ikon mengambil SISA ruang, FittedBox mengecilkan ikon bila ruang sempit
            // -> mencegah overflow (garis kuning-hitam).
            Expanded( // mengisi sisa tinggi kartu
              child: FittedBox( // menyesuaikan ukuran ikon dengan ruang yang ada
                child: Icon(icon, size: 64, color: Colors.blue.shade700), // ikon produk
              ), // akhir FittedBox
            ), // akhir Expanded
            const SizedBox(height: 6), // jarak vertikal 6
            // maxLines + ellipsis: nama panjang dipotong dengan "..." bukan membuat layout jebol.
            Text( // nama produk
              product.name, // isi teks
              textAlign: TextAlign.center, // rata tengah
              maxLines: 2, // maksimal 2 baris
              overflow: TextOverflow.ellipsis, // kelebihan teks diganti "..."
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), // tebal sedang, kecil
            ), // akhir Text
            const SizedBox(height: 6), // jarak vertikal 6
            Row( // susunan horizontal: harga (kiri) + tombol tambah (kanan)
              children: [ // daftar anak Row
                Expanded( // harga mengambil sisa lebar setelah tombol
                  child: Text( // teks harga
                    formatRupiah(product.price), // ubah angka ke format "Rp 150.000"
                    maxLines: 1, // satu baris saja
                    overflow: TextOverflow.ellipsis, // kepanjangan -> "..."
                    style: TextStyle( // gaya teks harga
                      color: Colors.green.shade700, // hijau tua
                      fontWeight: FontWeight.bold, // tebal
                      fontSize: 13, // ukuran 13
                    ), // akhir style
                  ), // akhir Text
                ), // akhir Expanded
                IconButton.filled( // tombol ikon berlatar warna
                  onPressed: onAddToCart, // aksi saat ditekan
                  icon: const Icon(Icons.add_shopping_cart, size: 18), // ikon tambah ke keranjang
                  tooltip: 'Tambah ke keranjang', // teks bantuan saat ditahan
                  visualDensity: VisualDensity.compact, // ukuran tombol diperkecil
                ), // akhir IconButton
              ], // akhir children Row
            ), // akhir Row
          ], // akhir children Column
        ), // akhir Column
      ), // akhir Padding
    ); // akhir Card
  } // akhir build
} // akhir kelas
