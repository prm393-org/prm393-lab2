import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: cs.surface,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 48,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile & Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
