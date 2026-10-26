import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/domain/entities/order_entity.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../../core/utils/date_formatter.dart';

class AdminDashboardPage extends StatefulWidget {
  final BookingRepository? bookingRepository;

  const AdminDashboardPage({super.key, this.bookingRepository});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late BookingRepository _repository;

  List<OrderEntity> _orders = [];

  bool _isLoadingOrders = false;

  String _validationFilter = 'Semua';

  String _selectedSidebarMenu = 'Beranda';

  final List<Map<String, dynamic>> _sidebarItems = [
    {'title': 'Beranda', 'icon': Icons.dashboard_outlined},
    {'title': 'Pesanan', 'icon': Icons.shopping_bag_outlined},
    {'title': 'Data Ambulans', 'icon': Icons.airport_shuttle_outlined},
    {'title': 'Data Sopir', 'icon': Icons.badge_outlined},
    {'title': 'Kritik dan Saran', 'icon': Icons.feedback_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _repository =
        widget.bookingRepository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl());
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoadingOrders = true);
    try {
      final orders = await _repository.getAllOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoadingOrders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingOrders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: isDesktop ? null : _buildDrawer(),
          body: Row(
            children: [
              // Sidebar for Desktop
              if (isDesktop) _buildDesktopSidebar(),

              // Main Content Area
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(isDesktop),
                      Expanded(
                        child: _selectedSidebarMenu == 'Beranda'
                            ? _buildDashboardHome(context, isDesktop)
                            : _selectedSidebarMenu == 'Validasi Pembayaran'
                            ? _buildPaymentValidationManagementView(
                                context,
                                isDesktop,
                              )
                            : _buildMenuPlaceholder(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header
  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Administrator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Jumat, 23 Oktober 2026 • Wilayah Operasional DIY',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '3 pesanan memerlukan tindakan validasi admin',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Rina',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pusat Komando',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Dashboard Home
  Widget _buildDashboardHome(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFourStatCards(isDesktop),
          const SizedBox(height: 24),

          // Status Armada Ambulans
          _buildFleetStatusCard(),
          const SizedBox(height: 24),

          // Pesanan Terbaru
          _buildActionRequiredOrdersCard(),
        ],
      ),
    );
  }

  // 4 Kartu Statistik
  // 4 Kartu Statistik dengan Layout Fleksibel (Wrap)
  Widget _buildFourStatCards(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.7 : 1.35,
      children: const [
        StatCard(
          title: 'Total Pesanan Hari Ini',
          value: '28',
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
          subtitle: '+12% dari kemarin',
        ),
        StatCard(
          title: 'Menunggu Validasi',
          value: '3',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
          subtitle: 'Perlu verifikasi bank',
        ),
        StatCard(
          title: 'Pesanan Berlangsung',
          value: '5',
          icon: Icons.moving_rounded,
          color: AppColors.secondary,
          subtitle: 'Unit di lapangan',
        ),
        StatCard(
          title: 'Ambulans Tersedia',
          value: '8 / 12',
          icon: Icons.local_hospital_outlined,
          color: AppColors.success,
          subtitle: 'Standby di pangkalan',
        ),
      ],
    );
  }

  // 3. Card Pesanan Perlu Ditindaklanjuti
  // 3. Card Pesanan Perlu Ditindaklanjuti
  Widget _buildActionRequiredOrdersCard() {
    final pendingOrders = [
      {
        'id': '#ORD-20261023-04',
        'type': 'Validasi Pembayaran',
        'patient': 'Bpk. Hendrawan',
        'route': 'Sleman -> RS Panti Rapih',
        'time': '5 mnt lalu',
        'amount': 'Rp 250.000 (Mandiri)',
        'action': 'Validasi',
      },
      {
        'id': '#ORD-20261023-05',
        'type': 'Penugasan Sopir',
        'patient': 'Ny. Wahyuni',
        'route': 'Bantul -> RS PKU Bantul',
        'time': '8 mnt lalu',
        'amount': 'Sudah Valid',
        'action': 'Tugaskan',
      },
      {
        'id': '#ORD-20261023-06',
        'type': 'Validasi Pembayaran',
        'patient': 'Bpk. Sugeng',
        'route': 'Kota -> RS Bethesda',
        'time': '14 mnt lalu',
        'amount': 'Rp 200.000 (BCA)',
        'action': 'Validasi',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Pesanan Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigasi ke Semua Pesanan (Placeholder)'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...pendingOrders.map((o) {
          final isValidation = o['type'] == 'Validasi Pembayaran';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            o['id']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(child: StatusBadge.warning(o['type']!)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${o['patient']} • ${o['route']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${o['amount']} • ${o['time']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tindakan ${o['action']} untuk ${o['id']} berhasil diproses.',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValidation
                        ? AppColors.success
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    o['action']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 4. Card Status Armada
  Widget _buildFleetStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Armada Ambulans (12 Unit)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildFleetProgressRow(
            'Tersedia (Standby)',
            8,
            12,
            AppColors.success,
          ),
          const SizedBox(height: 10),
          _buildFleetProgressRow('Sedang Bertugas', 3, 12, AppColors.primary),
          const SizedBox(height: 10),
          _buildFleetProgressRow(
            'Perawatan / Servis Rutin',
            1,
            12,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildFleetProgressRow(
    String label,
    int count,
    int total,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: count / total,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // Desktop Sidebar
  Widget _buildDesktopSidebar() {
    return Material(
      color: Colors.white,
      child: Container(
        width: 230,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ambulans Admin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: _sidebarItems.map((item) {
                  final isSelected = _selectedSidebarMenu == item['title'];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Material(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedSidebarMenu = item['title'] as String;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(width: 12),
                Text(
                  'Navigasi Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _sidebarItems.map((item) {
                return ListTile(
                  leading: Icon(item['icon'] as IconData, size: 20),
                  title: Text(item['title'] as String),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedSidebarMenu = item['title'] as String;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPlaceholder(BuildContext context) {
    String detailInfo =
        'Menu ini telah siap dihubungkan dengan API endpoint backend dan manajemen database.';

    if (_selectedSidebarMenu == 'Kritik dan Saran') {
      detailInfo = 'Daftar masukan serta ulasan dari pengguna untuk evaluasi peningkatan mutu layanan ambulans.';
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola: $_selectedSidebarMenu',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data & Pengaturan Modul "$_selectedSidebarMenu"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detailInfo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSidebarMenu = 'Beranda';
                    });
                  },
                  child: const Text('Kembali ke Ringkasan Beranda'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ALUR VALIDASI PEMBAYARAN ADMINISTRATOR ---

  void _showPaymentValidationDialog(OrderEntity order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 680),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Dialog
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Validasi Pembayaran #${order.id}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Pasien
                        _buildSectionTitle(
                          'Identitas Pasien',
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildDialogDetailRow(
                                'Nama Lengkap',
                                order.patientName ?? '-',
                              ),
                              const SizedBox(height: 6),
                              _buildDialogDetailRow(
                                'Jenis Kelamin / Umur',
                                '${order.patientGender ?? "-"} • ${order.patientAge != null ? "${order.patientAge} tahun" : "-"}',
                              ),
                              const SizedBox(height: 6),
                              _buildDialogDetailRow(
                                'Nomor Telepon',
                                order.patientPhoneNumber ?? '-',
                              ),
                              if (order.notes != null &&
                                  order.notes!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                _buildDialogDetailRow(
                                  'Catatan / Kondisi',
                                  order.notes!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card Rute & Layanan
                        _buildSectionTitle(
                          'Layanan & Rute',
                          Icons.alt_route_rounded,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildDialogDetailRow(
                                'Jenis Layanan',
                                order.serviceType ??
                                    'Ambulans Gawat Darurat (Emergency)',
                              ),
                              const SizedBox(height: 6),
                              _buildDialogDetailRow(
                                'Lokasi Jemput',
                                order.pickupAddress ?? '-',
                              ),
                              const SizedBox(height: 6),
                              _buildDialogDetailRow(
                                'RS Tujuan',
                                order.destinationAddress ?? '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card Tagihan & Metode
                        _buildSectionTitle(
                          'Rincian Pembayaran',
                          Icons.payments_outlined,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildDialogDetailRow(
                                'Metode Pembayaran',
                                order.paymentMethod ?? 'Transfer Bank BCA',
                                isBold: true,
                              ),
                              const SizedBox(height: 6),
                              _buildDialogDetailRow(
                                'Tarif Dasar',
                                DateFormatter.formatCurrency(
                                  order.basePrice ?? (order.totalPrice ?? 0),
                                ),
                              ),
                              if (order.additionalFee != null &&
                                  order.additionalFee! > 0) ...[
                                const SizedBox(height: 6),
                                _buildDialogDetailRow(
                                  'Biaya Tambahan',
                                  DateFormatter.formatCurrency(
                                    order.additionalFee!,
                                  ),
                                ),
                              ],
                              const Divider(
                                height: 14,
                                color: AppColors.divider,
                              ),
                              _buildDialogDetailRow(
                                'Total Tagihan',
                                DateFormatter.formatCurrency(
                                  order.totalPrice ?? 0,
                                ),
                                isBold: true,
                                valueColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card Bukti Pembayaran
                        _buildSectionTitle(
                          'Bukti Pembayaran yang Diunggah',
                          Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (order.paymentProofUrl ??
                                              'bukti_transfer.jpg')
                                          .split('/')
                                          .last,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Format Gambar Valid • Ukuran < 4 MB',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showProofPreviewDialog(order),
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 14,
                                ),
                                label: const Text('Buka Bukti'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  visualDensity: VisualDensity.compact,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Tombol Aksi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Tombol Tolak Pembayaran
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            _showRejectionReasonDialog(order);
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Tolak Pembayaran'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tombol Validasi Pembayaran
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(dialogCtx);
                            await _processValidation(order, true);
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Validasi Pembayaran'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProofPreviewDialog(OrderEntity order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bukti Pembayaran', style: TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 320,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Struk Transfer ${order.paymentMethod ?? "Bank"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nominal: ${DateFormatter.formatCurrency(order.totalPrice ?? 0)}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pesanan: #${order.id}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showRejectionReasonDialog(OrderEntity order) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (rejectCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tolak Pembayaran #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Berikan alasan penolakan pembayaran kepada pengguna:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Nominal transfer tidak sesuai, bukti pembayaran buram / tidak terbaca, dll.',
                      hintStyle: const TextStyle(fontSize: 12.5),
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildQuickReasonChip(
                        'Nominal kurang',
                        controller,
                        setDialogState,
                      ),
                      _buildQuickReasonChip(
                        'Bukti buram',
                        controller,
                        setDialogState,
                      ),
                      _buildQuickReasonChip(
                        'Rekening salah',
                        controller,
                        setDialogState,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(rejectCtx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final reason = controller.text.trim();
                  if (reason.isEmpty) {
                    setDialogState(() {
                      errorText = 'Alasan penolakan wajib diisi';
                    });
                    return;
                  }
                  Navigator.pop(rejectCtx);
                  await _processValidation(
                    order,
                    false,
                    rejectionReason: reason,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kirim Penolakan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickReasonChip(
    String label,
    TextEditingController controller,
    void Function(void Function()) setDialogState,
  ) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      onPressed: () {
        setDialogState(() {
          if (label == 'Nominal kurang') {
            controller.text = 'Nominal transfer yang dikirim tidak sesuai dengan total tagihan pesanan.';
          } else if (label == 'Bukti buram') {
            controller.text = 'Foto atau tangkapan layar bukti transfer buram dan tidak terbaca jelas.';
          } else if (label == 'Rekening salah') {
            controller.text = 'Transfer dikirim ke nomor rekening yang salah / bukan rekening AmbulanceCare.';
          }
        });
      },
    );
  }

  Future<void> _processValidation(
    OrderEntity order,
    bool isValid, {
    String? rejectionReason,
  }) async {
    try {
      await _repository.validatePayment(
        order.id,
        isValid,
        rejectionReason: rejectionReason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isValid
                ? 'Pembayaran pesanan #${order.id} berhasil divalidasi. Ambulans siap diberangkatkan.'
                : 'Pembayaran pesanan #${order.id} ditolak: $rejectionReason',
          ),
          backgroundColor: isValid ? AppColors.success : AppColors.error,
        ),
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses validasi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // --- HALAMAN DEDIKASI KELOLA VALIDASI PEMBAYARAN (SIDEBAR) ---
  Widget _buildPaymentValidationManagementView(
    BuildContext context,
    bool isDesktop,
  ) {
    List<OrderEntity> filteredOrders;
    if (_validationFilter == 'Menunggu Validasi') {
      filteredOrders = _orders
          .where((o) => o.status == OrderStatus.menungguValidasi)
          .toList();
    } else if (_validationFilter == 'Telah Divalidasi') {
      filteredOrders = _orders
          .where(
            (o) =>
                o.status != OrderStatus.menungguValidasi &&
                o.rejectionReason == null,
          )
          .toList();
    } else if (_validationFilter == 'Ditolak') {
      filteredOrders = _orders.where((o) => o.rejectionReason != null).toList();
    } else {
      filteredOrders = _orders;
    }

    final waitingCount = _orders
        .where((o) => o.status == OrderStatus.menungguValidasi)
        .length;

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Actions Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelola Validasi Pembayaran',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Periksa dan verifikasi pembayaran masuk sebelum armada ambulans diberangkatkan.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Segarkan Data',
                  icon: _isLoadingOrders
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  onPressed: _isLoadingOrders ? null : _loadOrders,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Menunggu Validasi',
                    badgeCount: waitingCount,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip('Semua Pesanan', badgeCount: _orders.length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Telah Divalidasi'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ditolak'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Cards List
            if (filteredOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada pesanan dalam kategori "$_validationFilter"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pesanan baru yang membutuhkan tindakan validasi akan muncul di sini.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final isPending =
                      order.status == OrderStatus.menungguValidasi;
                  final isRejected = order.rejectionReason != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isPending
                            ? AppColors.warning.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: isPending ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '#${order.id}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (isPending)
                                  StatusBadge.warning('Menunggu Validasi')
                                else if (isRejected)
                                  StatusBadge.error('Pembayaran Ditolak')
                                else
                                  StatusBadge.success('Pembayaran Valid'),
                              ],
                            ),
                            Text(
                              DateFormatter.formatCurrency(
                                order.totalPrice ?? 0,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 10),

                        // Info Baris
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.patientName ?? 'Pasien',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${order.patientGender ?? "-"} • ${order.patientAge != null ? "${order.patientAge} th" : "-"} • ${order.patientPhoneNumber ?? "-"}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.pickupAddress ?? "-"}  ➔  ${order.destinationAddress ?? "-"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Metode: ${order.paymentMethod ?? "Transfer Bank"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Layanan: ${order.serviceType ?? "Gawat Darurat"}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Alasan jika ditolak
                        if (isRejected) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Alasan Ditolak: ${order.rejectionReason}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Actions
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showProofPreviewDialog(order),
                              icon: const Icon(Icons.image_outlined, size: 15),
                              label: const Text('Bukti Transfer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                visualDensity: VisualDensity.compact,
                                side: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            if (isPending) ...[
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showRejectionReasonDialog(order),
                                icon: const Icon(Icons.close_rounded, size: 15),
                                label: const Text('Tolak'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  visualDensity: VisualDensity.compact,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showPaymentValidationDialog(order),
                                icon: const Icon(Icons.check_rounded, size: 15),
                                label: const Text('Validasi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {int? badgeCount}) {
    final isSelected = _validationFilter == label;
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (badgeCount != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _validationFilter = label;
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}
