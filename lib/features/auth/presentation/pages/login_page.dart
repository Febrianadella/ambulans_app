import 'package:flutter/material.dart';

import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk ke Sistem Ambulans')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.local_hospital_rounded,
              size: 72,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sistem Ambulans Tanggap Darurat',
              style: Theme.of(context).textTheme.displayMedium
                  ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih peran aktor atau masuk dengan kredensial:',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Daftar 6 Peran Aktor
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: UserRole.values.map((role) {
                return Chip(
                  avatar: const Icon(Icons.person, size: 16),
                  label: Text(role.label),
                  backgroundColor: AppColors.primaryLight.withValues(
                    alpha: 0.4,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email / Username',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Masuk')),
          ],
        ),
      ),
    );
  }
}
