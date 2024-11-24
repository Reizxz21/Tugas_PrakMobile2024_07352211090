import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ECommerceApp());
}
class ECommerceApp extends StatelessWidget {
  const ECommerceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BookListPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to E-Commerce App', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// Model Buku
class Book {
  final String id;
  final String title;
  final String author;
  final String description;

  Book({required this.id, required this.title, required this.author, required this.description});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString() ?? '',
      title: json['title'] ?? 'tidak ada judul',
      author: json['author']?? 'tidak diketahui',
      description: json['description']?? 'tidak ada deskripsi',
    );
  }
}

// Fungsi HTTP Request
Future<List<Book>> fetchBooks() async {
  final response = await http.get(Uri.parse('https://events.hmti.unkhair.ac.id/api/books'));
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((json) => Book.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat daftar buku');
  }
}

Future<Book> fetchBookById(String id) async {
  final response = await http.get(Uri.parse('https://events.hmti.unkhair.ac.id/api/books/$id'));
  if (response.statusCode == 200) {
    return Book.fromJson(json.decode(response.body));
  } else if (response.statusCode == 404) {
    throw Exception('Buku tidak ditemukan');
  } else {
    throw Exception('Gagal memuat detail buku');
  }
}

Future<void> addBook(String title, String author, String description) async {
  final response = await http.post(
    Uri.parse('https://events.hmti.unkhair.ac.id/api/books'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'title': title, 'author': author, 'description': description}),
  );
  if (response.statusCode != 201) {
    throw Exception('Gagal menambahkan buku');
  }
}

Future<void> updateBook(String id, String title, String author, String description) async {
  final response = await http.put(
    Uri.parse('https://events.hmti.unkhair.ac.id/api/books/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'title': title, 'author': author, 'description': description}),
  );
  if (response.statusCode != 200) {
    throw Exception('Gagal memperbarui buku');
  }
}

Future<void> deleteBook(String id) async {
  final response = await http.delete(Uri.parse('https://events.hmti.unkhair.ac.id/api/books/$id'));
  if (response.statusCode != 200) {
    throw Exception('Gagal menghapus buku');
  }
}

// Daftar Buku
// Halaman Daftar Buku
class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late Future<List<Book>> books;

  @override
  void initState() {
    super.initState();
    books = fetchBooks();
  }

  void refreshBooks() {
    setState(() {
      books = fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBookPage(onBookAdded: refreshBooks)),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada buku tersedia'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await deleteBook(book.id);
                    refreshBooks(); // Perbarui daftar buku setelah dihapus
                  },
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailPage(bookId: book.id, onBookUpdated: refreshBooks),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Halaman Tambah Buku
class AddBookPage extends StatefulWidget {
  final VoidCallback onBookAdded;

  const AddBookPage({required this.onBookAdded, super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String author = '';
  String description = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator: (value) => value!.isEmpty ? 'Penulis tidak boleh kosong' : null,
                onSaved: (value) => author = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                onSaved: (value) => description = value!,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            await addBook(title, author, description);
                            widget.onBookAdded(); // Panggil callback untuk refresh daftar buku
                            Navigator.pop(context);
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text(e.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      child: const Text('Tambah'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Detail Buku
class BookDetailPage extends StatelessWidget {
  final String bookId;
  final VoidCallback onBookUpdated;

  const BookDetailPage({required this.bookId, required this.onBookUpdated, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: FutureBuilder<Book>(
        future: fetchBookById(bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final book = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(book.author, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(book.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await deleteBook(book.id);
                        onBookUpdated();
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditBookPage(
                              book: book,
                              onBookUpdated: onBookUpdated,
                            ),
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class EditBookPage extends StatefulWidget {
  final Book book;
  final VoidCallback onBookUpdated;

  const EditBookPage({required this.book, required this.onBookUpdated, super.key});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String author;
  late String description;

  @override
  void initState() {
    super.initState();
    // Isi nilai awal form dengan data buku yang akan diedit
    title = widget.book.title;
    author = widget.book.author;
    description = widget.book.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: author,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penulis tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => author = value!,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => description = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await updateBook(widget.book.id, title, author, description);
                    widget.onBookUpdated();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
