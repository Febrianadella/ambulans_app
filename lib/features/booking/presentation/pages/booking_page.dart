import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/repositories/booking_repository.dart';
import 'order_confirmation_page.dart';

class BookingPage extends StatefulWidget {
  final BookingRepository? bookingRepository;

  const BookingPage({super.key, this.bookingRepository});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  late final TextEditingController _patientNameController;
  late final TextEditingController _patientAgeController;
  late final TextEditingController _patientPhoneController;
  late final TextEditingController _patientConditionController;

  late final BookingRepository _repository;

  String? _selectedGender;
  bool _isSubmitting = false;

  final List<String> _genderOptions = const ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _repository =
        widget.bookingRepository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl());

    _pickupController = TextEditingController(
      text: 'Jl. Malioboro No. 12, Sosromenduran, Kota Yogyakarta',
    );
    _destinationController = TextEditingController(
      text: 'RSUP Dr. Sardjito, Sleman, D.I. Yogyakarta',
    );
    _patientNameController = TextEditingController();
    _patientAgeController = TextEditingController();
    _patientPhoneController = TextEditingController();
    _patientConditionController = TextEditingController();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _patientPhoneController.dispose();
    _patientConditionController.dispose();
    super.dispose();
  }

  void _submitBooking() async {
    // Sembunyikan keyboard saat tombol ditekan
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi seluruh data wajib pada formulir dengan benar.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final parsedAge = int.parse(_patientAgeController.text.trim());

    // Arahkan pengguna ke Halaman Konfirmasi Pesanan dengan data formulir aktual
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationPage(
          userId: 'USR-20261023-01',
          pickupAddress: _pickupController.text.trim(),
          destinationAddress: _destinationController.text.trim(),
          pickupLatitude: -7.7956,
          pickupLongitude: 110.3695,
          patientName: _patientNameController.text.trim(),
          patientGender: _selectedGender!,
          patientAge: parsedAge,
          patientPhoneNumber: _patientPhoneController.text.trim(),
          notes: _patientConditionController.text.trim().isEmpty
              ? null
              : _patientConditionController.text.trim(),
          serviceType: 'Ambulans Gawat Darurat (Emergency)',
          basePrice: 150000.0,
          additionalFee: 50000.0,
          repository: _repository,
        ),
      ),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pemesanan Ambulans Darurat'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Peringatan Panggilan Darurat
              _buildEmergencyAlertBanner(),
              const SizedBox(height: 18),

              // 2. Lokasi Penjemputan
              _buildFieldLabel('Lokasi Penjemputan', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pickupController,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  hintText: 'Masukkan alamat atau titik jemput',
                  prefixIcon: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi penjemputan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Rumah Sakit Tujuan
              _buildFieldLabel('Rumah Sakit Tujuan', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _destinationController,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  hintText: 'Pilih atau masukkan rumah sakit rujukan',
                  prefixIcon: const Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rumah sakit tujuan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Data Pasien (Kartu Identitas Pasien)
              _buildPatientDataSection(),
              const SizedBox(height: 20),

              // 5. Kondisi Pasien / Catatan Tambahan
              _buildFieldLabel('Kondisi Pasien / Catatan Tambahan'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _patientConditionController,
                maxLines: 4,
                minLines: 3,
                textInputAction: TextInputAction.done,
                decoration: _buildInputDecoration(
                  hintText: 'Tuliskan kondisi pasien, keluhan, atau informasi penting lainnya...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 6. Tombol Kirim / Pesan Ambulans Sekarang
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.emergency_rounded, size: 22),
                  label: Text(
                    _isSubmitting
                        ? 'Memproses Pesanan...'
                        : 'Pesan Ambulans Sekarang',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Komponen Kartu Peringatan Darurat
  Widget _buildEmergencyAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Panggilan darurat ambulans akan segera diteruskan ke unit terdekat!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primaryDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Komponen Bagian Data Pasien
  Widget _buildPatientDataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Data Pasien
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Data Pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),

          // A. Nama Lengkap Pasien
          _buildFieldLabel('Nama Lengkap Pasien', isRequired: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _patientNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _buildInputDecoration(
              hintText: 'Masukkan nama lengkap pasien',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama lengkap pasien wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Nama pasien minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Baris 2: Jenis Kelamin (kiri) & Umur Pasien (kanan) Berdampingan
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 280;
              if (isVeryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGenderField(),
                    const SizedBox(height: 16),
                    _buildAgeField(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildGenderField()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildAgeField()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // D. Nomor Telepon yang Bisa Dihubungi
          _buildFieldLabel(
            'Nomor Telepon yang Bisa Dihubungi',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _patientPhoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]')),
            ],
            decoration: _buildInputDecoration(
              hintText: 'Masukkan nomor telepon aktif',
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nomor telepon yang bisa dihubungi wajib diisi';
              }
              final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (digitsOnly.length < 9 || digitsOnly.length > 15) {
                return 'Format nomor telepon tidak valid (minimal 9-15 digit)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Komponen Input Jenis Kelamin (Dropdown Pilihan: Laki-laki / Perempuan)
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Jenis Kelamin', isRequired: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          isExpanded: true,
          decoration: _buildInputDecoration(
            hintText: 'Pilih jenis kelamin',
            prefixIcon: const Icon(
              Icons.wc_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          items: _genderOptions.map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(
                gender,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jenis kelamin wajib dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Komponen Input Umur Pasien (Input Angka, Ikon Identitas Profesional, Satuan "tahun", Non-negatif)
  Widget _buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Umur Pasien', isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _patientAgeController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _buildInputDecoration(
            hintText: 'Masukkan umur pasien',
            prefixIcon: const Icon(
              Icons.badge_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            suffix: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Text(
                'tahun',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Umur pasien wajib diisi';
            }
            final age = int.tryParse(value.trim());
            if (age == null) {
              return 'Umur pasien harus berupa angka yang valid';
            }
            if (age < 0) {
              return 'Umur pasien tidak boleh bernilai negatif';
            }
            if (age > 150) {
              return 'Umur pasien tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Helper Label Input Field
  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  // Helper Dekorasi Input
  InputDecoration _buildInputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      prefixIcon: prefixIcon,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
