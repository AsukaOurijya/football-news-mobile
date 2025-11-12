import 'package:flutter/material.dart';
import 'package:football_news/screens/login.dart';
import 'package:football_news/screens/news_entry_list.dart';
import 'package:football_news/screens/newslist_form.dart';
import 'package:football_news/utils/api_constants.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ItemHomePage {
  const ItemHomePage({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});

  final ItemHomePage item;

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Material(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Kamu telah menekan tombol ${item.name}!'),
              ),
            );

          if (item.name == 'Add News') {
            navigator.push(
              MaterialPageRoute(builder: (context) => const NewsFormPage()),
            );
          } else if (item.name == "See Football News") {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const NewsEntryListPage(),
              ),
            );
          } else if (item.name == "Logout") {
            final response = await request.logout('$baseUrl/auth/logout/');
            if (!navigator.mounted) return;

            if (response['status']) {
              final uname = response['username'];
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    "${response['message']} See you again, $uname.",
                  ),
                ),
              );
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            } else {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(response['message'] ?? 'Logout failed.'),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } 
}
