import 'package:flutter/material.dart'; // dibutuhkan untuk tipe IconData dan daftar Icons

/// Memilih ikon berdasarkan nama produk. Dipakai di halaman katalog DAN keranjang.
/// (Ikon tidak disimpan di database, cukup ditentukan di sisi tampilan.)
IconData getIconForProduct(String name) { // menerima nama produk, mengembalikan ikon
  final lower = name.toLowerCase(); // ubah ke huruf kecil agar pencarian kata tidak peka kapital
  if (lower.contains('joran')) return Icons.straighten; // nama mengandung "joran" -> ikon penggaris
  if (lower.contains('reel')) return Icons.settings_backup_restore; // "reel" -> ikon putar
  if (lower.contains('senar')) return Icons.linear_scale; // "senar" -> ikon garis
  if (lower.contains('kail')) return Icons.anchor; // "kail" -> ikon jangkar
  if (lower.contains('umpan')) return Icons.bug_report; // "umpan" -> ikon serangga
  if (lower.contains('pelampung')) return Icons.circle; // "pelampung" -> ikon lingkaran
  if (lower.contains('kotak')) return Icons.inventory_2; // "kotak" -> ikon kotak
  if (lower.contains('timah')) return Icons.scale; // "timah" -> ikon timbangan
  return Icons.set_meal; // ikon bawaan jika tidak cocok kategori manapun
} // akhir fungsi
