import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:football_news/screens/menu.dart';
import 'package:football_news/utils/api_constants.dart';
import 'package:football_news/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _thumbnailController = TextEditingController();

  static const List<String> _categories = [
    'transfer',
    'update',
    'exclusive',
    'match',
    'rumor',
    'analysis',
  ];

  String _selectedCategory = _categories.first;
  bool _isFeatured = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add News Form'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Judul Berita',
                    hintText: 'Masukkan judul berita',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong!';
                    }
                    if (value.trim().length < 4) {
                      return 'Judul minimal 4 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Isi Berita',
                    hintText: 'Masukkan konten berita',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Isi berita tidak boleh kosong!';
                    }
                    if (value.trim().length < 20) {
                      return 'Isi berita minimal 20 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category[0].toUpperCase() + category.substring(1),
                          ),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _thumbnailController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'URL Thumbnail (opsional)',
                    hintText: 'Masukkan tautan gambar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }

                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                      return 'Masukkan URL yang valid.';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tandai sebagai berita unggulan'),
                  value: _isFeatured,
                  onChanged: (isActive) {
                    setState(() {
                      _isFeatured = isActive;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: theme.textTheme.labelLarge,
                    ),
                    onPressed: () => _handleSubmit(request),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;
    if (!request.loggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before adding news.')),
      );
      return;
    }

    final payload = {
      "title": _titleController.text.trim(),
      "content": _contentController.text.trim(),
      "category": _selectedCategory,
      "thumbnail": _thumbnailController.text.trim(),
      "is_featured": _isFeatured,
    };

    try {
      final response = await request.postJson(
        '$baseUrl/create-flutter/',
        jsonEncode(payload),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        _resetForm();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Berita berhasil disimpan.'),
            ),
          );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menyimpan berita.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedCategory = _categories.first;
      _isFeatured = false;
    });
    _titleController.clear();
    _contentController.clear();
    _thumbnailController.clear();
  }
}
