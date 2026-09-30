/// Mengubah angka menjadi teks rupiah dengan titik pemisah ribuan.
/// Contoh: 150000.0 -> "Rp 150.000"
String formatRupiah(double value) { // fungsi menerima angka, mengembalikan String
  final digits = value.round().toString(); // bulatkan lalu ubah jadi teks, mis. "150000"
  final buffer = StringBuffer(); // wadah untuk menyusun teks hasil sedikit demi sedikit
  for (int i = 0; i < digits.length; i++) { // telusuri setiap digit dari kiri ke kanan
    final fromEnd = digits.length - i; // berapa digit tersisa (termasuk digit ini) sampai ujung kanan
    buffer.write(digits[i]); // tulis digit saat ini ke wadah
    if (fromEnd > 1 && fromEnd % 3 == 1) { // setiap 3 digit dari kanan, sisipkan titik (bukan di akhir)
      buffer.write('.'); // tambahkan titik pemisah ribuan
    } // akhir if
  } // akhir for
  return 'Rp $buffer'; // gabungkan awalan "Rp " dengan angka yang sudah diformat
} // akhir fungsi
