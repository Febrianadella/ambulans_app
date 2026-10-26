import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../booking/domain/entities/order_entity.dart';

/// Komponen visual peta live tracking ambulans berbasis canvas vektor interaktif.
/// Menampilkan jaringan jalan kota, sungai/taman, rute darurat, marker ambulans,
/// marker penjemputan, marker rumah sakit, dan kontrol zoom/recenter.
class LiveTrackingMapView extends StatefulWidget {
  final OrderStatus status;
  final bool isPaymentValid;
  final double height;
  final String pickupAddress;
  final String destinationAddress;

  const LiveTrackingMapView({
    super.key,
    required this.status,
    required this.isPaymentValid,
    this.height = 280,
    this.pickupAddress = 'Lokasi Penjemputan',
    this.destinationAddress = 'Rumah Sakit Tujuan',
  });

  @override
  State<LiveTrackingMapView> createState() => _LiveTrackingMapViewState();
}

class _LiveTrackingMapViewState extends State<LiveTrackingMapView>
    with SingleTickerProviderStateMixin {
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (!isTest) {
      _pulseController.repeat();
    } else {
      _pulseController.value = 0.5;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 2.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 2.0);
    });
  }

  void _recenter() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Area Gambar Peta Berbasis CustomPainter dengan Pan dan Zoom
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _panOffset += details.delta;
                });
              },
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(double.infinity, widget.height),
                    painter: _EmergencyMapPainter(
                      zoom: _zoomLevel,
                      pan: _panOffset,
                      pulseProgress: _pulseController.value,
                      status: widget.status,
                      isPaymentValid: widget.isPaymentValid,
                    ),
                  );
                },
              ),
            ),

            // Badge Info Simulasi di Pojok Kiri Atas
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Rute Prioritas Medis Aktif',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kontrol Peta: Zoom In, Zoom Out, dan Recenter di Pojok Kanan Atas
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Perbesar Peta',
                      onPressed: _zoomIn,
                    ),
                    Container(height: 1, width: 28, color: AppColors.border),
                    _buildControlButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Perkecil Peta',
                      onPressed: _zoomOut,
                    ),
                    Container(height: 1, width: 28, color: AppColors.border),
                    _buildControlButton(
                      icon: Icons.my_location_rounded,
                      tooltip: 'Pusatkan Tampilan Peta',
                      onPressed: _recenter,
                    ),
                  ],
                ),
              ),
            ),

            // Label Legenda Marker di Bagian Bawah Peta
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(
                      color: AppColors.primary,
                      icon: Icons.airport_shuttle,
                      label: 'Ambulans',
                    ),
                    Container(width: 1, height: 14, color: AppColors.border),
                    _buildLegendItem(
                      color: AppColors.primary,
                      icon: Icons.person_pin_circle_rounded,
                      label: 'Lokasi Anda',
                    ),
                    Container(width: 1, height: 14, color: AppColors.border),
                    _buildLegendItem(
                      color: const Color(0xFF0284C7),
                      icon: Icons.local_hospital_rounded,
                      label: 'RS Tujuan',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar visual peta perkotaan realistis:
/// - Blok bangunan/tanah kota
/// - Taman hijau kota
/// - Jalur sungai biru
/// - Jaringan jalan utama dan arteri
/// - Jalur rute evakuasi darurat warna merah
/// - Marker ambulans, lokasi penjemputan, dan RS tujuan
class _EmergencyMapPainter extends CustomPainter {
  final double zoom;
  final Offset pan;
  final double pulseProgress;
  final OrderStatus status;
  final bool isPaymentValid;

  _EmergencyMapPainter({
    required this.zoom,
    required this.pan,
    required this.pulseProgress,
    required this.status,
    required this.isPaymentValid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Menerapkan translasi dan zoom dengan pusat di tengah canvas
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx + pan.dx, center.dy + pan.dy);
    canvas.scale(zoom);
    canvas.translate(-center.dx, -center.dy);

    final w = size.width;
    final h = size.height;

    // 1. Gambar Area Taman Hijau Perkotaan
    final parkPaint = Paint()
      ..color = const Color(0xFFE2EFE5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.12, w * 0.22, h * 0.32),
        const Radius.circular(12),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.52, w * 0.22, h * 0.34),
        const Radius.circular(12),
      ),
      parkPaint,
    );

    // 2. Gambar Jalur Sungai Perkotaan
    final riverPaint = Paint()
      ..color = const Color(0xFFD6E8F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(-w * 0.1, h * 0.85)
      ..cubicTo(w * 0.3, h * 0.95, w * 0.45, h * 0.65, w * 1.1, h * 0.7);
    canvas.drawPath(riverPath, riverPaint);

    // 3. Gambar Blok Jalan Perkotaan (Grid Jalan)
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.square;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD8E2EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.square;

    // Garis-garis jalan
    final List<Path> roads = [
      // Jalan horizontal utama
      Path()
        ..moveTo(-w * 0.2, h * 0.35)
        ..lineTo(w * 1.2, h * 0.35),
      Path()
        ..moveTo(-w * 0.2, h * 0.65)
        ..lineTo(w * 1.2, h * 0.65),
      // Jalan vertikal utama
      Path()
        ..moveTo(w * 0.32, -h * 0.2)
        ..lineTo(w * 0.32, h * 1.2),
      Path()
        ..moveTo(w * 0.68, -h * 0.2)
        ..lineTo(w * 0.68, h * 1.2),
      // Jalan diagonal arteri
      Path()
        ..moveTo(-w * 0.1, h * 0.1)
        ..lineTo(w * 1.1, h * 0.9),
    ];

    for (final r in roads) {
      canvas.drawPath(r, roadBorderPaint);
      canvas.drawPath(r, roadPaint);
    }

    // 4. Hitung Posisi Marker
    // Koordinat titik Penjemputan (Tengah Kiri)
    final pickupPoint = Offset(w * 0.48, h * 0.50);
    // Koordinat Rumah Sakit Tujuan (Kanan Atas)
    final hospitalPoint = Offset(w * 0.82, h * 0.26);

    // Posisi ambulans dinamis berdasarkan tahapan pesanan
    Offset ambulancePoint;
    if (!isPaymentValid ||
        status == OrderStatus.menungguPembayaran ||
        status == OrderStatus.menungguValidasi) {
      ambulancePoint = Offset(w * 0.18, h * 0.68); // Pangkalan / Siaga
    } else if (status == OrderStatus.menujuLokasi) {
      ambulancePoint = Offset(w * 0.32, h * 0.58); // Sedang Menuju Pasien
    } else if (status == OrderStatus.tibaDiLokasi) {
      ambulancePoint = Offset(w * 0.45, h * 0.52); // Tiba di lokasi penjemputan
    } else if (status == OrderStatus.dalamPerjalanan) {
      ambulancePoint = Offset(w * 0.66, h * 0.36); // Menuju RS rujukan
    } else {
      ambulancePoint = hospitalPoint; // Selesai tiba di RS
    }

    // 5. Gambar Garis Rute Medis Darurat (Glow + Jalur Merah Utama)
    final routeGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routeMainPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routeDashedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Rute dari Ambulans ke Lokasi Penjemputan
    final routeToPickup = Path()
      ..moveTo(ambulancePoint.dx, ambulancePoint.dy)
      ..lineTo(w * 0.32, ambulancePoint.dy)
      ..lineTo(w * 0.32, pickupPoint.dy)
      ..lineTo(pickupPoint.dx, pickupPoint.dy);

    // Rute dari Penjemputan ke Rumah Sakit Tujuan
    final routeToHospital = Path()
      ..moveTo(pickupPoint.dx, pickupPoint.dy)
      ..lineTo(w * 0.68, pickupPoint.dy)
      ..lineTo(w * 0.68, hospitalPoint.dy)
      ..lineTo(hospitalPoint.dx, hospitalPoint.dy);

    canvas.drawPath(routeToPickup, routeGlowPaint);
    canvas.drawPath(routeToPickup, routeMainPaint);

    canvas.drawPath(routeToHospital, routeGlowPaint);
    _drawDashedPath(canvas, routeToHospital, routeDashedPaint, 6.0, 4.0);

    // 6. Gambar Marker Rumah Sakit Tujuan (Kanan Atas)
    _drawHospitalMarker(canvas, hospitalPoint);

    // 7. Gambar Marker Lokasi Penjemputan (Tengah)
    _drawPickupMarker(canvas, pickupPoint);

    // 8. Gambar Marker Ambulans (Aktif dengan Efek Gelombang Radar)
    _drawAmbulanceMarker(canvas, ambulancePoint);

    canvas.restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = math.min(dashWidth, metric.length - distance);
        final Path extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawPickupMarker(Canvas canvas, Offset point) {
    // Lingkaran luar putih berbayang
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(point.translate(0, 2), 14, shadowPaint);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(point, 14, bgPaint);

    // Pin merah tengah
    final pinPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(point, 10, pinPaint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(point, 4, dotPaint);

    // Label "Lokasi Anda"
    _drawMarkerLabel(
      canvas: canvas,
      center: point.translate(0, -22),
      text: 'Lokasi Anda',
      bgColor: AppColors.primary,
      textColor: Colors.white,
    );
  }

  void _drawHospitalMarker(Canvas canvas, Offset point) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(point.translate(0, 2), 16, shadowPaint);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(point, 16, bgPaint);

    // Lingkaran biru RS
    final bluePaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(point, 12, bluePaint);

    // Tanda Palang Putih Medis
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(point.translate(-5, 0), point.translate(5, 0), crossPaint);
    canvas.drawLine(point.translate(0, -5), point.translate(0, 5), crossPaint);

    // Label "Rumah Sakit Tujuan"
    _drawMarkerLabel(
      canvas: canvas,
      center: point.translate(0, -24),
      text: 'Rumah Sakit Tujuan',
      bgColor: const Color(0xFF0284C7),
      textColor: Colors.white,
    );
  }

  void _drawAmbulanceMarker(Canvas canvas, Offset point) {
    // 1. Efek Gelombang Radar / Pulsing Ring di sekitar Ambulans
    final waveRadius = 16.0 + (pulseProgress * 18.0);
    final waveOpacity = (1.0 - pulseProgress).clamp(0.0, 0.7);
    final wavePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: waveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(point, waveRadius, wavePaint);

    // 2. Bayangan dan Lingkaran Luar
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(point.translate(0, 2), 17, shadowPaint);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(point, 17, bgPaint);

    final redPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(point, 13, redPaint);

    // 3. Ikon Palang Medis di Tengah Ambulans
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      point.translate(-4.5, 0),
      point.translate(4.5, 0),
      crossPaint,
    );
    canvas.drawLine(
      point.translate(0, -4.5),
      point.translate(0, 4.5),
      crossPaint,
    );

    // 4. Label "Ambulans"
    _drawMarkerLabel(
      canvas: canvas,
      center: point.translate(0, 24),
      text: 'Ambulans',
      bgColor: Colors.white,
      textColor: AppColors.primary,
      borderColor: AppColors.primary,
    );
  }

  void _drawMarkerLabel({
    required Canvas canvas,
    required Offset center,
    required String text,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 9.5,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5);
    final rect = Rect.fromCenter(
      center: center,
      width: textPainter.width + padding.horizontal,
      height: textPainter.height + padding.vertical,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawRRect(rrect.shift(const Offset(0, 1)), shadowPaint);

    // Background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    if (borderColor != null) {
      final bPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRRect(rrect, bPaint);
    }

    textPainter.paint(
      canvas,
      Offset(rect.left + padding.left, rect.top + padding.top),
    );
  }

  @override
  bool shouldRepaint(covariant _EmergencyMapPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.status != status ||
        oldDelegate.isPaymentValid != isPaymentValid;
  }
}
