import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdminAmbulancePage extends StatefulWidget {
  const AdminAmbulancePage({super.key});

  @override
  State<AdminAmbulancePage> createState() => _AdminAmbulancePageState();
}

class _AdminAmbulancePageState extends State<AdminAmbulancePage> {
  // Mockup Data Unit Ambulans
  final List<Map<String, dynamic>> _ambulanceList = [
    {
      'code': 'AMB-01',
      'name': 'Ambulans Darurat Unit 01',
      'type': 'Emergency / Gawat Darurat',
      'plateNumber': 'AB 1234 XY',
      'status': 'Tersedia', // Tersedia, Bertugas, Perawatan
    },
    {
      'code': 'AMB-02',
      'name': 'Ambulans Darurat Unit 02',
      'type': 'Emergency / Gawat Darurat',
      'plateNumber': 'AB 5678 CD',
      'status': 'Bertugas',
    },
    {
      'code': 'AMB-03',
      'name': 'Ambulans Transport Unit 03',
      'type': 'Transport / Non-Emergency',
      'plateNumber': 'AB 9012 EF',
      'status': 'Tersedia',
    },
    {
      'code': 'AMB-04',
      'name': 'Ambulans Transport Unit 04',
      'type': 'Transport / Non-Emergency',
      'plateNumber': 'AB 3456 GH',
      'status': 'Tidak tersedia',
    },
    {
      'code': 'AMB-05',
      'name': 'Ambulans ICU Keliling',
      'type': 'ICU Mobile',
      'plateNumber': 'AB 7890 JK',
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
          // Header: Judul & Tombol Tambah Ambulans
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Unit Ambulans Rumah Sakit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kelola ketersediaan armada. Plotting dispatch dilakukan otomatis oleh sistem.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAmbulanceFormDialog(context, null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: const Text('Tambah Unit Baru', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabel / Daftar Card Ambulans
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                itemCount: _ambulanceList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final amb = _ambulanceList[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary),
                    ),
                    title: Row(
                      children: [
                        Text(
                          amb['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${amb['code']})',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tipe: ${amb['type']} • Plat: ${amb['plateNumber']}',
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
                            color: _getStatusColor(amb['status']).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            amb['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(amb['status']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                          onPressed: () => _showAmbulanceFormDialog(context, amb),
                          tooltip: 'Edit Data',
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.warning),
                          onPressed: () => _confirmDelete(context, amb['name']),
                          tooltip: 'Hapus Unit',
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
      case 'Perawatan':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  // Dialog Form Tambah / Edit Unit Ambulans
  void _showAmbulanceFormDialog(BuildContext context, Map<String, dynamic>? ambulanceData) {
    final bool isEdit = ambulanceData != null;
    final nameController = TextEditingController(text: ambulanceData?['name'] ?? '');
    final codeController = TextEditingController(text: ambulanceData?['code'] ?? '');
    final plateController = TextEditingController(text: ambulanceData?['plateNumber'] ?? '');
    String selectedType = ambulanceData?['type'] ?? 'Emergency / Gawat Darurat';
    String selectedStatus = ambulanceData?['status'] ?? 'Tersedia';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Data Unit Ambulans' : 'Tambah Unit Ambulans Baru',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Unit / Identitas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Ambulans Darurat Unit 01',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Kode Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: AMB-01',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Nomor Plat Kendaraan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: plateController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: AB 1234 XY',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Status Operasional', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Tersedia', 'Bertugas', 'Tidak tersedia']
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
                    ambulanceData['name'] = nameController.text;
                    ambulanceData['code'] = codeController.text;
                    ambulanceData['plateNumber'] = plateController.text;
                    ambulanceData['type'] = selectedType;
                    ambulanceData['status'] = selectedStatus;
                  } else {
                    _ambulanceList.add({
                      'code': codeController.text.isNotEmpty ? codeController.text : 'AMB-XX',
                      'name': nameController.text.isNotEmpty ? nameController.text : 'Ambulans Baru',
                      'type': selectedType,
                      'plateNumber': plateController.text.isNotEmpty ? plateController.text : 'AB 0000 XX',
                      'status': selectedStatus,
                    });
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Data unit berhasil diperbarui' : 'Unit ambulans baru ditambahkan')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Unit', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(BuildContext context, String ambulanceName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Unit Ambulans'),
        content: Text('Apakah Anda yakin ingin menghapus $ambulanceName dari sistem?'),
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
                _ambulanceList.removeWhere((item) => item['name'] == ambulanceName);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unit $ambulanceName berhasil dihapus')),
              );
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}