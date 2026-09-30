/// Model CartItem = satu baris di keranjang. Sama dengan tabel `local_cart`:
/// id, product_id, name, price, quantity.
/// name & price ikut disimpan agar harga di keranjang "dibekukan" saat produk ditambahkan.
class CartItem { // kelas cetakan data item keranjang
  final int? id; // id baris keranjang; null (tanda ?) karena belum ada sebelum masuk database
  final int productId; // id produk asal (merujuk ke master_products.id)
  final String name; // nama produk saat ditambahkan
  final double price; // harga satuan saat ditambahkan
  int quantity; // jumlah barang; tanpa final karena bisa berubah (+ dan -)

  CartItem({ // constructor dengan parameter bernama
    this.id, // id opsional
    required this.productId, // productId wajib
    required this.name, // name wajib
    required this.price, // price wajib
    required this.quantity, // quantity wajib
  }); // akhir constructor

  /// Total harga satu baris = harga satuan x jumlah.
  double get totalPrice => price * quantity; // getter: dihitung otomatis tiap dipanggil

  /// Mengubah Map hasil query database menjadi CartItem.
  factory CartItem.fromMap(Map<String, dynamic> map) { // factory dari Map
    return CartItem( // buat objek CartItem
      id: map['id'] as int, // kolom id
      productId: map['product_id'] as int, // kolom product_id (snake_case di database)
      name: map['name'] as String, // kolom name
      price: (map['price'] as num).toDouble(), // kolom price diubah ke double
      quantity: map['quantity'] as int, // kolom quantity
    ); // akhir objek
  } // akhir factory

  /// Mengubah CartItem menjadi Map untuk disimpan ke database.
  Map<String, dynamic> toMap() { // fungsi pengubah ke Map
    return { // Map hasil
      'id': id, // id (null -> database membuatkan otomatis / AUTOINCREMENT)
      'product_id': productId, // kolom product_id
      'name': name, // kolom name
      'price': price, // kolom price
      'quantity': quantity, // kolom quantity
    }; // akhir Map
  } // akhir fungsi
} // akhir kelas
