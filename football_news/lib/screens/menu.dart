import 'package:flutter/material.dart';
import 'package:football_news/widgets/left_drawer.dart';
import 'package:football_news/widgets/news_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const List<({String title, String value})> _profileEntries = [
    (title: 'NPM', value: '2406431510'),
    (title: 'Name', value: 'Muhammad Azka Awliya'),
    (title: 'Class', value: 'C'),
  ];

  static const List<ItemHomePage> _menuItems = [
    ItemHomePage(name: 'See Football News', icon: Icons.newspaper),
    ItemHomePage(name: 'Add News', icon: Icons.add),
    ItemHomePage(name: 'Logout', icon: Icons.logout),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxisCount = MediaQuery.of(context).size.width < 720 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Football News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = _profileEntries
                      .map(
                        (entry) =>
                            InfoCard(title: entry.title, content: entry.value),
                      )
                      .toList();

                  if (constraints.maxWidth < 720) {
                    return Column(
                      children: [
                        for (final card in cards)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: card,
                          ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i == cards.length - 1 ? 0 : 12,
                            ),
                            child: cards[i],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat datang di Football News',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                crossAxisCount: crossAxisCount,
                children: _menuItems
                    .map((item) => ItemCard(item: item))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
