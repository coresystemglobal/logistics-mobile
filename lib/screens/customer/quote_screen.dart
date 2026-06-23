import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/pricing_service.dart';
import '../../models/pricing_model.dart';

final _quoteProvider = StateNotifierProvider.autoDispose<_QuoteNotifier, _QuoteState>(
  (_) => _QuoteNotifier(),
);

class _QuoteState {
  final String pickup;
  final String delivery;
  final String size;
  final double weight;
  final bool fragile;
  final String speed;
  final PriceCalculationModel? result;
  final bool loading;
  final String? error;

  const _QuoteState({
    this.pickup = '',
    this.delivery = '',
    this.size = 'Small',
    this.weight = 2.5,
    this.fragile = false,
    this.speed = 'Express',
    this.result,
    this.loading = false,
    this.error,
  });

  _QuoteState copyWith({
    String? pickup,
    String? delivery,
    String? size,
    double? weight,
    bool? fragile,
    String? speed,
    PriceCalculationModel? result,
    bool? loading,
    String? error,
  }) =>
      _QuoteState(
        pickup: pickup ?? this.pickup,
        delivery: delivery ?? this.delivery,
        size: size ?? this.size,
        weight: weight ?? this.weight,
        fragile: fragile ?? this.fragile,
        speed: speed ?? this.speed,
        result: result ?? this.result,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}

class _QuoteNotifier extends StateNotifier<_QuoteState> {
  _QuoteNotifier() : super(const _QuoteState());

  void setPickup(String v) => state = state.copyWith(pickup: v);
  void setDelivery(String v) => state = state.copyWith(delivery: v);
  void setSize(String v) => state = state.copyWith(size: v);
  void setWeight(double v) => state = state.copyWith(weight: v);
  void setFragile(bool v) => state = state.copyWith(fragile: v);
  void setSpeed(String v) => state = state.copyWith(speed: v);

  void swapAddresses() {
    final tmp = state.pickup;
    state = state.copyWith(pickup: state.delivery, delivery: tmp);
  }

  static const _speedMap = {
    'Standard': 'STANDARD',
    'Express': 'EXPRESS',
    'Priority': 'SAME_DAY',
  };

  Future<void> calculate() async {
    if (state.pickup.isEmpty || state.delivery.isEmpty) return;
    state = state.copyWith(loading: true, error: null, result: null);
    try {
      final result = await PricingService().calculatePrice(
        pickupAddress: state.pickup,
        deliveryAddress: state.delivery,
        packageSize: state.size.toUpperCase(),
        deliverySpeed: _speedMap[state.speed] ?? 'STANDARD',
        packageWeight: state.weight,
      );
      state = state.copyWith(loading: false, result: result);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  final _pickupCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '2.5');

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_quoteProvider);
    final notifier = ref.read(_quoteProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: AppColors.textPrimary,
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Get a Quote',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration(),
                      child: Column(
                        children: [
                          _AddressField(
                            controller: _pickupCtrl,
                            hint: 'Pickup Address',
                            icon: Icons.location_on_rounded,
                            iconColor: AppColors.accent,
                            onChanged: notifier.setPickup,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              child: GestureDetector(
                                onTap: () {
                                  final tmp = _pickupCtrl.text;
                                  _pickupCtrl.text = _deliveryCtrl.text;
                                  _deliveryCtrl.text = tmp;
                                  notifier.swapAddresses();
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.separator),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                          _AddressField(
                            controller: _deliveryCtrl,
                            hint: 'Delivery Address',
                            icon: Icons.flag_rounded,
                            iconColor: AppColors.iosBlue,
                            onChanged: notifier.setDelivery,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Package details card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Package Size',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          _SizeSelector(
                            selected: state.size,
                            onSelect: notifier.setSize,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Weight (kg)',
                                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    TextField(autocorrect: false, enableSuggestions: false, 
                                      controller: _weightCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (v) => notifier.setWeight(double.tryParse(v) ?? 2.5),
                                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.bgSecondary,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 19),
                                    Container(
                                      height: 52,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgSecondary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Fragile?',
                                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                                          Switch.adaptive(
                                            value: state.fragile,
                                            onChanged: notifier.setFragile,
                                            activeColor: AppColors.accent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delivery speed
                    Text('Delivery Speed',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SpeedCard(label: 'Standard', price: '₦1,200', icon: Icons.schedule_rounded,
                              selected: state.speed == 'Standard', onTap: () => notifier.setSpeed('Standard')),
                          const SizedBox(width: 12),
                          _SpeedCard(label: 'Express', price: '₦2,800', icon: Icons.bolt_rounded,
                              selected: state.speed == 'Express', onTap: () => notifier.setSpeed('Express')),
                          const SizedBox(width: 12),
                          _SpeedCard(label: 'Priority', price: '₦5,500', icon: Icons.rocket_launch_rounded,
                              selected: state.speed == 'Priority', onTap: () => notifier.setSpeed('Priority')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Map preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 180,
                        decoration: const BoxDecoration(color: Color(0xFFE8E8EE)),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 180),
                              painter: _RoutePainter(),
                            ),
                            // Gradient overlay bottom
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, AppColors.bgSecondary.withValues(alpha: 0.6)],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('Route Optimized',
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Result or error
                    if (state.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(state.error!,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.error)),
                      ),
                    if (state.result != null) _QuoteResult(result: state.result!),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          border: Border(top: BorderSide(color: AppColors.separator.withValues(alpha: 0.5))),
        ),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.loading ? null : notifier.calculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: state.loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text('Calculate Quote',
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<String> onChanged;

  const _AddressField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(autocorrect: false, enableSuggestions: false, 
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.textQuaternary),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _SizeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const sizes = ['Small', 'Medium', 'Large', 'XL'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: sizes.map((s) {
          final isSelected = selected == s;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.bgPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))]
                      : null,
                ),
                child: Text(
                  s,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.accent : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SpeedCard extends StatelessWidget {
  final String label;
  final String price;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SpeedCard({
    required this.label,
    required this.price,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.separator,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.accent : AppColors.textTertiary, size: 20),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(price,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}

class _QuoteResult extends StatelessWidget {
  final PriceCalculationModel result;
  const _QuoteResult({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Breakdown',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _PriceLine('Base Price', '₦${result.basePrice.toStringAsFixed(0)}'),
          _PriceLine('Distance Fee', '₦${result.distanceFee.toStringAsFixed(0)}'),
          _PriceLine('Weight Fee', '₦${result.weightFee.toStringAsFixed(0)}'),
          _PriceLine('Platform Fee', '₦${result.platformFee.toStringAsFixed(0)}'),
          const Divider(color: AppColors.separator, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('₦${result.totalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ],
          ),
          if (result.estimatedDistanceKm != null || result.estimatedDurationMins != null) ...[
            const SizedBox(height: 10),
            Text(
              [
                if (result.estimatedDistanceKm != null) '${result.estimatedDistanceKm!.toStringAsFixed(1)} km',
                if (result.estimatedDurationMins != null) '~${result.estimatedDurationMins} min',
              ].join(' · '),
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  const _PriceLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = const Color(0xFFD0D0DC)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    // Draw grid-like roads
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(Offset(i * size.width / 5, 0), Offset(i * size.width / 5, size.height), roadPaint);
    }
    for (var i = 0; i < 8; i++) {
      canvas.drawLine(Offset(0, i * size.height / 7), Offset(size.width, i * size.height / 7), roadPaint);
    }

    final routePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.65, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.35, size.width * 0.75, size.height * 0.15);
    canvas.drawPath(path, routePaint);

    // Pins
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 8, Paint()..color = AppColors.textPrimary);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.15), 10, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}
