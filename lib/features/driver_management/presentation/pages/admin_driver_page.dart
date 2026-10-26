import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdminDriverPage extends StatefulWidget {
  const AdminDriverPage({super.key});

  @override
  State<AdminDriverPage> createState() => _AdminDriverPageState();
}

class _AdminDriverPageState extends State<AdminDriverPage> {
  // Mockup Data Sopir / Driver
  final List<Map<String, dynamic>> _driverList = [
    {
      'code': 'DRV-01',
      'name': 'Budi Santoso',
      'phone': '081234567890',
      'licenseType': 'SIM A / B1 Umum',
      'status': 'Tersedia', // Tersedia, Bertugas, Cuti
    },
    {
      'code': 'DRV-02',
      'name': 'Ahmad Fauzi',
      'phone': '082345678901',
      'licenseType': 'SIM B1 Umum',
      'status': 'Bertugas',
    },
    {
      'code': 'DRV-03',
      'name': 'Joko Prasetyo',
      'phone': '083456789012',
      'licenseType': 'SIM A',
      'status': 'Tersedia',
    },
    {
      'code': 'DRV-04',
      'name': 'Rian Hidayat',
      'phone': '084567890123',
      'licenseType': 'SIM B1 Umum',
      'status': 'Cuti',
    },
    {
      'code': 'DRV-05',
      'name': 'Eko Saputra',
      'phone': '085678901234',
      'licenseType': 'SIM A / B1',
      'status': 'Tersedia',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Judul & Tombol Tambah Sopir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola data supir yang terhubung dengan tiap unit ambulan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Data ketersediaan personel dan penugasan darurat.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showDriverFormDialog(context, null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: const Text('Tambah Sopir Baru', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabel / Daftar Card Sopir
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                itemCount: _driverList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final driver = _driverList[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_rounded, color: AppColors.primary),
                    ),
                    title: Row(
                      children: [
                        Text(
                          driver['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${driver['code']})',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Telp: ${driver['phone']} • ${driver['licenseType']}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(driver['status']).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            driver['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(driver['status']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                          onPressed: () => _showDriverFormDialog(context, driver),
                          tooltip: 'Edit Data',
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.warning),
                          onPressed: () => _confirmDelete(context, driver['name']),
                          tooltip: 'Hapus Sopir',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return AppColors.success;
      case 'Bertugas':
        return AppColors.secondary;
      case 'Cuti':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  // Dialog Form Tambah / Edit Data Sopir
  void _showDriverFormDialog(BuildContext context, Map<String, dynamic>? driverData) {
    final bool isEdit = driverData != null;
    final nameController = TextEditingController(text: driverData?['name'] ?? '');
    final codeController = TextEditingController(text: driverData?['code'] ?? '');
    final phoneController = TextEditingController(text: driverData?['phone'] ?? '');
    String selectedLicense = driverData?['licenseType'] ?? 'SIM A';
    String selectedStatus = driverData?['status'] ?? 'Tersedia';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Data Sopir' : 'Tambah Sopir Baru',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Budi Santoso',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Kode / ID Pegawai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: DRV-01',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Nomor Telepon / WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Jenis SIM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedLicense,
                    items: ['SIM A', 'SIM B1', 'SIM B1 Umum', 'SIM A / B1 Umum']
                        .map((license) => DropdownMenuItem(value: license, child: Text(license, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => selectedLicense = val!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Status Personel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Tersedia', 'Bertugas', 'Cuti']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => selectedStatus = val!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  if (isEdit) {
                    driverData['name'] = nameController.text;
                    driverData['code'] = codeController.text;
                    driverData['phone'] = phoneController.text;
                    driverData['licenseType'] = selectedLicense;
                    driverData['status'] = selectedStatus;
                  } else {
                    _driverList.add({
                      'code': codeController.text.isNotEmpty ? codeController.text : 'DRV-XX',
                      'name': nameController.text.isNotEmpty ? nameController.text : 'Sopir Baru',
                      'phone': phoneController.text.isNotEmpty ? phoneController.text : '-',
                      'licenseType': selectedLicense,
                      'status': selectedStatus,
                    });
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Data sopir berhasil diperbarui' : 'Sopir baru berhasil ditambahkan')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Sopir', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Konfirmasi Hapus Sopir
  void _confirmDelete(BuildContext context, String driverName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Sopir'),
        content: Text('Apakah Anda yakin ingin menghapus $driverName dari sistem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _driverList.removeWhere((item) => item['name'] == driverName);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sopir $driverName berhasil dihapus')),
              );
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}