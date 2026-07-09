import 'package:flutter/material.dart';
import '../models/unit.dart';
import 'start_screen.dart';

class UnitListScreen extends StatelessWidget {
  const UnitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Preserve declaration order of grades as they first appear.
    final grades = <int>[];
    for (final u in units) {
      if (!grades.contains(u.grade)) grades.add(u.grade);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('中学数学 ドリル')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final grade in grades) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                '中$grade',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final unit in units.where((u) => u.grade == grade))
              Card(
                child: ListTile(
                  title: Text(unit.title),
                  subtitle: Text(unit.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => StartScreen(unit: unit)),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
