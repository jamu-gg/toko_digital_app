import 'package:flutter_test/flutter_test.dart'; // pustaka untuk menulis test
import 'package:toko_digital_app/models/cart_item.dart'; // model yang diuji
import 'package:toko_digital_app/helpers/format_helper.dart'; // fungsi format yang diuji

void main() { // titik awal test
  test('totalPrice = harga x jumlah', () { // test 1
    final item = CartItem(productId: 1, name: 'Kail', price: 15000, quantity: 3); // buat item contoh
    expect(item.totalPrice, 45000); // harapannya 15000 x 3 = 45000
  }); // akhir test 1

  test('formatRupiah memakai titik pemisah ribuan', () { // test 2
    expect(formatRupiah(150000), 'Rp 150.000'); // ratusan ribu
    expect(formatRupiah(8000), 'Rp 8.000'); // ribuan
    expect(formatRupiah(1250000), 'Rp 1.250.000'); // jutaan
  }); // akhir test 2
} // akhir main
