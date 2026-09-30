import 'package:flutter/material.dart'; // pustaka widget Material
import 'package:provider/provider.dart'; // untuk context.watch / context.read
import '../providers/cart_provider.dart'; // provider keranjang
import '../models/cart_item.dart'; // model CartItem
import '../helpers/format_helper.dart'; // formatRupiah
import '../helpers/icon_helper.dart'; // getIconForProduct

class CartPage extends StatelessWidget { // halaman keranjang belanja
  const CartPage({super.key}); // constructor konstan

  /// Alur checkout: konfirmasi -> kosongkan keranjang -> tampilkan dialog sukses.
  Future<void> _handleCheckout(BuildContext context, CartProvider cart) async { // menerima context & provider
    final total = cart.totalPrice; // simpan total SEBELUM keranjang dikosongkan
    final count = cart.totalItemCount; // simpan jumlah barang SEBELUM dikosongkan

    final confirmed = await showDialog<bool>( // tampilkan dialog konfirmasi, tunggu jawaban true/false
      context: context, // konteks saat ini
      builder: (dialogContext) => AlertDialog( // isi dialog
        title: const Text('Konfirmasi Checkout'), // judul dialog
        content: Text('Bayar $count barang dengan total ${formatRupiah(total)}?'), // pertanyaan konfirmasi
        actions: [ // tombol-tombol dialog
          TextButton( // tombol batal
            onPressed: () => Navigator.pop(dialogContext, false), // tutup dialog, kirim false
            child: const Text('Batal'), // label tombol
          ), // akhir TextButton
          FilledButton( // tombol setuju
            onPressed: () => Navigator.pop(dialogContext, true), // tutup dialog, kirim true
            child: const Text('Checkout'), // label tombol
          ), // akhir FilledButton
        ], // akhir actions
      ), // akhir AlertDialog
    ); // akhir showDialog

    if (confirmed != true) return; // jika batal / dialog ditutup, hentikan proses

    await cart.checkout(); // kosongkan keranjang (database + memori)

    if (!context.mounted) return; // pastikan halaman masih aktif sebelum memakai context lagi

    await showDialog<void>( // tampilkan dialog sukses
      context: context, // konteks saat ini
      builder: (dialogContext) => AlertDialog( // isi dialog
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48), // ikon centang hijau
        title: const Text('Checkout Berhasil'), // judul dialog
        content: Text('Terima kasih! Total pembayaran ${formatRupiah(total)}.'), // pesan sukses
        actions: [ // tombol dialog
          FilledButton( // tombol OK
            onPressed: () => Navigator.pop(dialogContext), // tutup dialog
            child: const Text('OK'), // label tombol
          ), // akhir FilledButton
        ], // akhir actions
      ), // akhir AlertDialog
    ); // akhir showDialog
  } // akhir _handleCheckout

  @override // menimpa fungsi bawaan
  Widget build(BuildContext context) { // menyusun tampilan halaman
    final cartProvider = context.watch<CartProvider>(); // pantau perubahan keranjang (rebuild otomatis)
    final items = cartProvider.cartItems; // daftar item keranjang

    return Scaffold( // kerangka halaman
      appBar: AppBar(title: const Text('Keranjang Belanja')), // bilah judul
      body: items.isEmpty // jika keranjang kosong...
          ? const Center( // ...tampilkan pesan di tengah layar
              child: Padding( // jarak pinggir agar teks tidak mepet
                padding: EdgeInsets.all(24), // jarak 24 ke semua sisi
                child: Column( // susunan vertikal ikon + teks
                  mainAxisSize: MainAxisSize.min, // tinggi Column seukuran isinya saja
                  children: [ // daftar anak
                    Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey), // ikon keranjang kosong
                    SizedBox(height: 12), // jarak vertikal
                    Text( // pesan
                      'Keranjang masih kosong.\nYuk pilih alat pancing dulu!', // isi pesan (\n = baris baru)
                      textAlign: TextAlign.center, // rata tengah
                      style: TextStyle(fontSize: 16, color: Colors.grey), // abu-abu
                    ), // akhir Text
                  ], // akhir children
                ), // akhir Column
              ), // akhir Padding
            ) // akhir Center
          : Column( // ...jika tidak kosong: daftar item (atas) + ringkasan (bawah)
              children: [ // daftar anak Column
                Expanded( // daftar item mengambil seluruh sisa tinggi dan bisa digulir -> anti overflow
                  child: ListView.separated( // daftar yang bisa digulir dengan pemisah
                    padding: const EdgeInsets.all(12), // jarak daftar dari tepi
                    itemCount: items.length, // jumlah item
                    separatorBuilder: (_, __) => const SizedBox(height: 8), // jarak 8 antar kartu
                    itemBuilder: (context, index) { // pembuat item ke-index
                      final CartItem item = items[index]; // ambil item ke-index
                      return _CartItemTile( // tampilkan kartu item
                        item: item, // data item
                        onIncrease: () => cartProvider.increaseQuantity(item), // tombol +
                        onDecrease: () => cartProvider.decreaseQuantity(item), // tombol -
                        onRemove: () => cartProvider.removeFromCart(item), // tombol hapus
                      ); // akhir _CartItemTile
                    }, // akhir itemBuilder
                  ), // akhir ListView
                ), // akhir Expanded
                _CheckoutSummary( // ringkasan total + tombol checkout di bawah
                  totalPrice: cartProvider.totalPrice, // total harga
                  totalItems: cartProvider.totalItemCount, // total jumlah barang
                  onCheckout: () => _handleCheckout(context, cartProvider), // aksi tombol checkout
                ), // akhir _CheckoutSummary
              ], // akhir children
            ), // akhir Column
    ); // akhir Scaffold
  } // akhir build
} // akhir kelas

/// Satu kartu item di daftar keranjang (tata letak dirapikan).
class _CartItemTile extends StatelessWidget { // kelas privat
  final CartItem item; // data item
  final VoidCallback onIncrease; // aksi tombol +
  final VoidCallback onDecrease; // aksi tombol -
  final VoidCallback onRemove; // aksi tombol hapus

  const _CartItemTile({ // constructor konstan
    required this.item, // item wajib
    required this.onIncrease, // aksi + wajib
    required this.onDecrease, // aksi - wajib
    required this.onRemove, // aksi hapus wajib
  }); // akhir constructor

  @override // menimpa fungsi bawaan
  Widget build(BuildContext context) { // menyusun tampilan kartu
    return Card( // kotak berbayang
      margin: EdgeInsets.zero, // tanpa margin bawaan (jarak diatur oleh separator)
      child: Padding( // jarak dalam kartu
        padding: const EdgeInsets.all(12), // jarak 12
        child: Row( // susunan horizontal: ikon | info | kontrol jumlah
          crossAxisAlignment: CrossAxisAlignment.center, // sejajarkan vertikal di tengah
          children: [ // daftar anak Row
            Container( // kotak latar ikon produk
              width: 48, // lebar 48
              height: 48, // tinggi 48
              decoration: BoxDecoration( // hiasan kotak
                color: Colors.blue.shade50, // latar biru muda
                borderRadius: BorderRadius.circular(10), // sudut bulat
              ), // akhir decoration
              child: Icon(getIconForProduct(item.name), color: Colors.blue.shade700), // ikon sesuai produk
            ), // akhir Container
            const SizedBox(width: 12), // jarak horizontal 12
            // Expanded: bagian info mengambil sisa lebar, sehingga nama panjang tidak
            // mendorong kontrol +/- keluar layar (mencegah overflow horizontal).
            Expanded( // mengambil sisa lebar baris
              child: Column( // susunan vertikal: nama, harga satuan, subtotal
                crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
                children: [ // daftar anak Column
                  Text( // nama produk
                    item.name, // isi teks
                    maxLines: 2, // maksimal 2 baris
                    overflow: TextOverflow.ellipsis, // kepanjangan -> "..."
                    style: const TextStyle(fontWeight: FontWeight.w600), // tebal sedang
                  ), // akhir Text
                  const SizedBox(height: 2), // jarak kecil
                  Text( // harga satuan
                    '${formatRupiah(item.price)} / item', // contoh: "Rp 150.000 / item"
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12), // abu-abu kecil
                  ), // akhir Text
                  const SizedBox(height: 4), // jarak kecil
                  Text( // subtotal baris ini
                    formatRupiah(item.totalPrice), // harga x jumlah
                    maxLines: 1, // satu baris
                    overflow: TextOverflow.ellipsis, // kepanjangan -> "..."
                    style: TextStyle( // gaya subtotal
                      fontWeight: FontWeight.bold, // tebal
                      color: Colors.green.shade700, // hijau tua
                    ), // akhir style
                  ), // akhir Text
                ], // akhir children
              ), // akhir Column
            ), // akhir Expanded
            const SizedBox(width: 8), // jarak horizontal 8
            Column( // kolom kanan: pengubah jumlah + tombol hapus
              mainAxisSize: MainAxisSize.min, // tinggi seukuran isi
              children: [ // daftar anak
                Container( // kotak berbingkai pembungkus tombol - dan +
                  decoration: BoxDecoration( // hiasan kotak
                    border: Border.all(color: Colors.grey.shade300), // garis tepi abu-abu
                    borderRadius: BorderRadius.circular(20), // sudut sangat bulat
                  ), // akhir decoration
                  child: Row( // susunan horizontal: [-] jumlah [+]
                    mainAxisSize: MainAxisSize.min, // lebar seukuran isi
                    children: [ // daftar anak
                      _RoundIconButton(icon: Icons.remove, onTap: onDecrease), // tombol kurangi
                      SizedBox( // lebar tetap untuk angka jumlah agar posisi tombol stabil
                        width: 28, // lebar 28
                        child: Text( // angka jumlah
                          '${item.quantity}', // ubah angka jadi teks
                          textAlign: TextAlign.center, // rata tengah
                          style: const TextStyle(fontWeight: FontWeight.bold), // tebal
                        ), // akhir Text
                      ), // akhir SizedBox
                      _RoundIconButton(icon: Icons.add, onTap: onIncrease), // tombol tambah
                    ], // akhir children
                  ), // akhir Row
                ), // akhir Container
                const SizedBox(height: 4), // jarak vertikal 4
                InkWell( // area yang bisa ditekan (efek riak)
                  onTap: onRemove, // aksi hapus
                  child: const Padding( // jarak agar area tekan lebih besar
                    padding: EdgeInsets.all(4), // jarak 4
                    child: Row( // ikon + teks "Hapus"
                      mainAxisSize: MainAxisSize.min, // lebar seukuran isi
                      children: [ // daftar anak
                        Icon(Icons.delete_outline, size: 16, color: Colors.red), // ikon tempat sampah
                        SizedBox(width: 2), // jarak kecil
                        Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.red)), // label merah
                      ], // akhir children
                    ), // akhir Row
                  ), // akhir Padding
                ), // akhir InkWell
              ], // akhir children
            ), // akhir Column
          ], // akhir children Row
        ), // akhir Row
      ), // akhir Padding
    ); // akhir Card
  } // akhir build
} // akhir kelas

/// Tombol ikon kecil untuk + dan - (ukuran tetap supaya rapi).
class _RoundIconButton extends StatelessWidget { // kelas privat
  final IconData icon; // ikon yang ditampilkan
  final VoidCallback onTap; // aksi saat ditekan

  const _RoundIconButton({required this.icon, required this.onTap}); // constructor konstan

  @override // menimpa fungsi bawaan
  Widget build(BuildContext context) { // menyusun tampilan tombol
    return IconButton( // tombol ikon
      onPressed: onTap, // aksi saat ditekan
      icon: Icon(icon, size: 18), // gambar ikon ukuran 18
      padding: EdgeInsets.zero, // tanpa jarak dalam
      constraints: const BoxConstraints.tightFor(width: 34, height: 34), // ukuran tombol pasti 34x34
      visualDensity: VisualDensity.compact, // kepadatan kecil
    ); // akhir IconButton
  } // akhir build
} // akhir kelas

/// Panel bawah: total belanja + tombol Checkout.
class _CheckoutSummary extends StatelessWidget { // kelas privat
  final double totalPrice; // total harga
  final int totalItems; // total jumlah barang
  final VoidCallback onCheckout; // aksi tombol checkout

  const _CheckoutSummary({ // constructor konstan
    required this.totalPrice, // total harga wajib
    required this.totalItems, // total barang wajib
    required this.onCheckout, // aksi wajib
  }); // akhir constructor

  @override // menimpa fungsi bawaan
  Widget build(BuildContext context) { // menyusun tampilan panel
    return Container( // kotak latar panel
      width: double.infinity, // selebar layar
      decoration: BoxDecoration( // hiasan panel
        color: Theme.of(context).colorScheme.surface, // warna latar sesuai tema
        boxShadow: [ // bayangan di sisi atas agar panel terlihat terpisah
          BoxShadow(
            color: Colors.black.withAlpha(25), // hitam transparan (alpha 25 dari 255)
            blurRadius: 8, // tingkat blur
            offset: const Offset(0, -2), // bayangan naik ke atas
          ), // akhir BoxShadow
        ], // akhir boxShadow
      ), // akhir decoration
      child: SafeArea( // menghindari area sistem (mis. bilah navigasi bawah HP)
        top: false, // bagian atas tidak perlu dihindari
        child: Padding( // jarak dalam panel
          padding: const EdgeInsets.all(16), // jarak 16
          child: Column( // susunan vertikal: baris total + tombol
            mainAxisSize: MainAxisSize.min, // tinggi seukuran isi
            children: [ // daftar anak
              Row( // baris: label (kiri) dan total (kanan)
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // dorong ke kiri dan kanan
                children: [ // daftar anak
                  Text('Total Belanja ($totalItems barang)', style: const TextStyle(fontSize: 14)), // label + jumlah barang
                  const SizedBox(width: 8), // jarak horizontal
                  // Flexible menjaga angka total yang besar tetap muat di layar sempit.
                  Flexible( // boleh menyusut bila ruang sempit
                    child: Text( // teks total
                      formatRupiah(totalPrice), // format "Rp xxx.xxx"
                      textAlign: TextAlign.right, // rata kanan
                      overflow: TextOverflow.ellipsis, // kepanjangan -> "..."
                      style: const TextStyle( // gaya total
                        fontSize: 20, // besar
                        fontWeight: FontWeight.bold, // tebal
                        color: Colors.green, // hijau
                      ), // akhir style
                    ), // akhir Text
                  ), // akhir Flexible
                ], // akhir children
              ), // akhir Row
              const SizedBox(height: 12), // jarak vertikal 12
              SizedBox( // membatasi ukuran tombol
                width: double.infinity, // tombol selebar panel
                height: 48, // tinggi tombol 48
                child: FilledButton.icon( // tombol berlatar warna dengan ikon
                  onPressed: onCheckout, // aksi saat ditekan
                  icon: const Icon(Icons.payment), // ikon pembayaran
                  label: const Text('Checkout'), // label tombol
                ), // akhir FilledButton
              ), // akhir SizedBox
            ], // akhir children
          ), // akhir Column
        ), // akhir Padding
      ), // akhir SafeArea
    ); // akhir Container
  } // akhir build
} // akhir kelas
