import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'features/dashboard/presentation/pages/dokter_dashboard_page.dart';
import 'features/dashboard/presentation/pages/kepala_dashboard_page.dart';
import 'features/dashboard/presentation/pages/pengguna_dashboard_page.dart';
import 'features/dashboard/presentation/pages/perawat_dashboard_page.dart';
import 'features/dashboard/presentation/pages/sopir_dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AmbulanceBookingApp());
}

class AmbulanceBookingApp extends StatelessWidget {
  const AmbulanceBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Layanan Ambulans - LLM Analisis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainRoleSwitcherShell(),
    );
  }
}

class MainRoleSwitcherShell extends StatefulWidget {
  const MainRoleSwitcherShell({super.key});

  @override
  State<MainRoleSwitcherShell> createState() => _MainRoleSwitcherShellState();
}

class _MainRoleSwitcherShellState extends State<MainRoleSwitcherShell> {
  UserRole _activeRole = UserRole.pengguna;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(bottom: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // App Brand Logo
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ambulance System',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Simulation Selector for 6 Actors
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: UserRole.values.map((role) {
                          final isSelected = _activeRole == role;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(role.label),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _activeRole = role;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Login Screen Access Button
                  IconButton(
                    tooltip: 'Halaman Login & Hak Akses',
                    icon: const Icon(
                      Icons.login_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildActiveDashboard(),
    );
  }

  Widget _buildActiveDashboard() {
    switch (_activeRole) {
      case UserRole.pengguna:
        return const PenggunaDashboardPage();
      case UserRole.sopir:
        return const SopirDashboardPage();
      case UserRole.admin:
        return const AdminDashboardPage();
      case UserRole.kepala:
        return const KepalaDashboardPage();
      case UserRole.perawat:
        return const PerawatDashboardPage();
      case UserRole.dokter:
        return const DokterDashboardPage();
    }
  }
}
