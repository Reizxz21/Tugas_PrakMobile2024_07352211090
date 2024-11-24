class User {
  String name;
  int age;
  late List<Product> products;
  Role? role;

  User(this.name, this.age, this.role) {
    products = [];
  }
}

// Kelas untuk menampung kategori produk
class Toko {
  List<Product> elektronik = [];
  List<Product> makanan = [];
  List<Product> material = [];

  void tambahProduk(Product product) {
    if (product.jenisProduk == JenisProduk.Elektronik) {
      elektronik.add(product);
    } else if (product.jenisProduk == JenisProduk.Makanan) {
      makanan.add(product);
    } else if (product.jenisProduk == JenisProduk.Material) {
      material.add(product);
    }
  }

  void tampilkanProdukKategori() {
    print('\n=== Daftar Produk Elektronik ===');
    for (var product in elektronik) {
      print('${product.productName} - Rp${product.price} - ${product.inStock ? "Tersedia" : "Habis"}');
    }

    print('\n=== Daftar Produk Makanan ===');
    for (var product in makanan) {
      print('${product.productName} - Rp${product.price} - ${product.inStock ? "Tersedia" : "Habis"}');
    }

    print('\n=== Daftar Produk Material ===');
    for (var product in material) {
      print('${product.productName} - Rp${product.price} - ${product.inStock ? "Tersedia" : "Habis"}');
    }
  }
}

enum JenisProduk { Elektronik, Makanan, Material }

class Product {
  String productName;
  double price;
  bool inStock;
  JenisProduk jenisProduk;

  Product(this.productName, this.price, this.inStock, this.jenisProduk);
}

enum Role { Admin, Customer }

class AdminUser extends User {
  AdminUser(String name, int age) : super(name, age, Role.Admin);

  void tambahProduk(Product product, Toko kategori) {
    if (product.inStock) {
      products.add(product);
      kategori.tambahProduk(product);
      print("\n===== INFO LAPORAN TAMBAH PRODUK =====");
      print('${product.productName} berhasil ditambahkan ke daftar produk.');
    } else {
      print(
          '${product.productName} tidak tersedia dalam stok dan tidak dapat ditambahkan.');
    }
  }

  void hapusProduk(Product product) {
    products.remove(product);
    print("\n===== INFO LAPORAN HAPUS PRODUK =====");
    print('${product.productName} berhasil dihapus dari daftar produk.');
  }
}

class CustomerUser extends User {
  CustomerUser(String name, int age) : super(name, age, Role.Customer);

  void lihatProduk() {
    print('\nDaftar Produk Tersedia:');
    for (var product in products) {
      print('${product.productName} - Rp${product.price} - ${product.inStock ? "Tersedia" : "Habis"}');
    }
  }
}

Future<void> fetchProductDetails() async {
  print('Mengambil detail produk...');
  await Future.delayed(Duration(seconds: 2));
  print('\nDetail produk berhasil diambil.');
}

void main() {
  // Membuat objek AdminUser, CustomerUser, dan Kategori
  AdminUser admin = AdminUser('Reiki', 21);
  CustomerUser customer = CustomerUser('Alfi', 21);
  Toko kategori = Toko();

  Product product1 = Product('Laptop Asus', 5000000, true, JenisProduk.Elektronik);
  Product product2 = Product('Laptop Acer', 4000000, true, JenisProduk.Elektronik);
  Product product3 = Product('Nasi Padang', 30000, true, JenisProduk.Makanan);
  Product product4 = Product('Nasi Kebuli', 20000, true, JenisProduk.Makanan);
  Product product5 = Product('Semen', 65000, true, JenisProduk.Material);
  Product product6 = Product('Gergaji', 75000, true, JenisProduk.Material);
 

  try {
    admin.tambahProduk(product1, kategori);
    admin.tambahProduk(product2, kategori);
    admin.tambahProduk(product3, kategori);
    admin.tambahProduk(product4, kategori);
    admin.tambahProduk(product5, kategori);
    admin.tambahProduk(product6, kategori);
     } on Exception catch (e) {
    print('Kesalahan: $e');
  }

  fetchProductDetails();
  // Memastikan produk yang tersedia ditampilkan pada pengguna CustomerUser
  customer.products = admin.products;
  customer.lihatProduk();

  // Menampilkan produk berdasarkan kategori
  // kategori.tampilkanProdukKategori();

}
