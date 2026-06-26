import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../services/package_service.dart';
import '../../services/matching_service.dart';
import '../../models/delivery_models.dart';

class BookDeliveryScreen extends ConsumerStatefulWidget {
  const BookDeliveryScreen({super.key});

  @override
  ConsumerState<BookDeliveryScreen> createState() =>
      _BookDeliveryScreenState();
}

class _BookDeliveryScreenState extends ConsumerState<BookDeliveryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Address
  final _pickupCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  bool _sendTrackingLink = true;

  void _onAddressFieldChanged() => setState(() {});

  // Step 2: Package
  String _category = 'OTHERS';
  String _packageSize = 'SMALL';
  String _deliverySpeed = 'STANDARD';
  String _paymentMethod = 'WALLET';
  final _descriptionCtrl = TextEditingController();
  final _deliveryNotesCtrl = TextEditingController();

  // Step 3: Review
  QuoteModel? _quote;
  bool _isQuoting = false;
  bool _isSubmitting = false;

  final _matchingService = MatchingService();
  final _packageService = PackageService();

  static const _categories = [
    ('FOOD', 'Food'),
    ('DOCUMENTS', 'Documents'),
    ('CLOTHING', 'Clothing'),
    ('ELECTRONICS', 'Electronics'),
    ('SHOES', 'Shoes'),
    ('GROCERIES', 'Groceries'),
    ('HEALTH_PHARMACEUTICALS', 'Health'),
    ('JEWELRY_VALUABLES', 'Valuables'),
    ('HOUSEHOLD_ITEMS', 'Household'),
    ('OTHERS', 'Others'),
  ];
  static const _packageSizes = [
    _PackageSize('SMALL', 'Small', Icons.mail_outline_rounded, 'Included'),
    _PackageSize('MEDIUM', 'Medium', Icons.inventory_2_outlined, '+₦500'),
    _PackageSize('LARGE', 'Large', Icons.inventory_outlined, '+₦1,200'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _descriptionCtrl.dispose();
    _deliveryNotesCtrl.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _pickupCtrl.text.isNotEmpty &&
      _deliveryCtrl.text.isNotEmpty &&
      _recipientNameCtrl.text.isNotEmpty &&
      _recipientPhoneCtrl.text.isNotEmpty;

  bool get _step2Valid => _category != 'OTHERS' || _descriptionCtrl.text.trim().isNotEmpty;

  Future<void> _goToReview() async {
    setState(() {_isQuoting = true; _quote = null;});
    try {
      final quote = await _matchingService.getQuote(
        pickupAddress: _pickupCtrl.text.trim(),
        deliveryAddress: _deliveryCtrl.text.trim(),
        packageSize: _packageSize,
        deliverySpeed: _deliverySpeed,
      );
      if (mounted) {
        setState(() {
          _quote = quote;
          _isQuoting = false;
        });
        _pageController.animateToPage(2,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut);
        setState(() => _currentStep = 2);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isQuoting = false);
        _pageController.animateToPage(2,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut);
        setState(() => _currentStep = 2);
      }
    }
  }

  Future<void> _bookDelivery() async {
    setState(() => _isSubmitting = true);
    try {
      final pkg = await _packageService.createPackage(
        pickupAddress: _pickupCtrl.text.trim(),
        deliveryAddress: _deliveryCtrl.text.trim(),
        recipientName: _recipientNameCtrl.text.trim(),
        recipientPhone: _recipientPhoneCtrl.text.trim(),
        description: _category == 'OTHERS'
            ? _descriptionCtrl.text.trim()
            : _categories.firstWhere((c) => c.$1 == _category).$2,
        category: _category,
        packageSize: _packageSize,
        deliverySpeed: _deliverySpeed,
        paymentMethod: _paymentMethod,
        deliveryNotes: _deliveryNotesCtrl.text.trim().isEmpty
            ? null
            : _deliveryNotesCtrl.text.trim(),
      );
      if (!mounted) return;
      final id = pkg.id.isNotEmpty ? pkg.id : null;
      if (id == null) {
        context.go('/customer/home');
        return;
      }
      final tn = pkg.trackingNumber;
      final uri = '/customer/booking-confirm/$id';
      final params = [
        if (tn != null && tn.isNotEmpty) 'trackingNumber=$tn',
        'paymentMethod=$_paymentMethod',
      ].join('&');
      context.go('$uri?$params');
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('connection timeout') ||
          msg.contains('receive timeout') ||
          msg.contains('SocketException')) {
        msg = 'Request timed out. Please check your connection and try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 5),
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      final next = _currentStep + 1;
      if (next == 2) {
        _goToReview();
      } else {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut);
        setState(() => _currentStep = next);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentStep > 0) {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                        setState(() => _currentStep--);
                      } else {
                        context.pop();
                      }
                    },
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  Text(
                    'Book Delivery',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            // Step indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _currentStep
                                ? AppColors.accent
                                : AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Step ${_currentStep + 1} of 3: ${['Addresses', 'Package Details', 'Review & Pay'][_currentStep]}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _StepAddress(
                    pickupCtrl: _pickupCtrl,
                    deliveryCtrl: _deliveryCtrl,
                    recipientNameCtrl: _recipientNameCtrl,
                    recipientPhoneCtrl: _recipientPhoneCtrl,
                    sendTrackingLink: _sendTrackingLink,
                    onToggle: (v) => setState(() => _sendTrackingLink = v),
                    onFieldChanged: _onAddressFieldChanged,
                    onSelectPickup: (addr) {
                      setState(() => _pickupCtrl.text = addr);
                      _onAddressFieldChanged();
                    },
                    onSelectDelivery: (addr) {
                      setState(() => _deliveryCtrl.text = addr);
                      _onAddressFieldChanged();
                    },
                  ),
                  _StepPackage(
                    selectedCategory: _category,
                    selectedSize: _packageSize,
                    selectedSpeed: _deliverySpeed,
                    categories: _categories,
                    packageSizes: _packageSizes,
                    descriptionCtrl: _descriptionCtrl,
                    deliveryNotesCtrl: _deliveryNotesCtrl,
                    onCategoryChanged: (t) => setState(() => _category = t),
                    onSizeChanged: (s) => setState(() => _packageSize = s),
                    onSpeedChanged: (s) => setState(() => _deliverySpeed = s),
                    onDescriptionChanged: (_) => setState(() {}),
                  ),
                  _StepReview(
                    pickupAddress: _pickupCtrl.text,
                    deliveryAddress: _deliveryCtrl.text,
                    recipientName: _recipientNameCtrl.text,
                    recipientPhone: _recipientPhoneCtrl.text,
                    packageType: _category,
                    packageSize: _packageSize,
                    deliverySpeed: _deliverySpeed,
                    quote: _quote,
                    paymentMethod: _paymentMethod,
                    onPaymentMethodChanged: (v) => setState(() => _paymentMethod = v),
                  ),
                ],
              ),
            ),
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _currentStep == 2
                  ? TrakaButton(
                      label: 'Confirm & Pay',
                      loading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _bookDelivery,
                    )
                  : TrakaButton(
                      label: _currentStep == 1 ? 'Continue to Review' : 'Continue',
                      loading: _isQuoting,
                      onPressed: (_currentStep == 0 && !_step1Valid) ||
                          (_currentStep == 1 && !_step2Valid)
                          ? null
                          : _nextStep,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepAddress extends StatefulWidget {
  final TextEditingController pickupCtrl;
  final TextEditingController deliveryCtrl;
  final TextEditingController recipientNameCtrl;
  final TextEditingController recipientPhoneCtrl;
  final bool sendTrackingLink;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onFieldChanged;
  final ValueChanged<String> onSelectPickup;
  final ValueChanged<String> onSelectDelivery;

  const _StepAddress({
    required this.pickupCtrl,
    required this.deliveryCtrl,
    required this.recipientNameCtrl,
    required this.recipientPhoneCtrl,
    required this.sendTrackingLink,
    required this.onToggle,
    this.onFieldChanged,
    required this.onSelectPickup,
    required this.onSelectDelivery,
  });

  @override
  State<_StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<_StepAddress> {
  Future<void> _pickAddress(ValueChanged<String> onSelect) async {
    final service = AddressService();
    List<AddressModel> addresses = [];
    bool loading = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          if (loading) {
            service.getSavedAddresses().then((data) {
              if (ctx.mounted) {
                setSheet(() {
                  addresses = data.map(AddressModel.fromJson).toList();
                  loading = false;
                });
              }
            }).catchError((_) {
              if (ctx.mounted) setSheet(() => loading = false);
            });
          }
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.35,
            maxChildSize: 0.85,
            expand: false,
            builder: (_, controller) => Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.separator,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Saved Addresses',
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : addresses.isEmpty
                          ? Center(
                              child: Text('No saved addresses',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: AppColors.textTertiary)))
                          : ListView.separated(
                              controller: controller,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: addresses.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final addr = addresses[i];
                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  tileColor: AppColors.bgSecondary,
                                  leading: Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLight,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.accent, size: 18),
                                  ),
                                  title: Row(children: [
                                    Text(addr.label,
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary)),
                                    if (addr.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentLight,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text('Default',
                                            style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.accent)),
                                      ),
                                    ],
                                  ]),
                                  subtitle: Text(addr.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textTertiary)),
                                  onTap: () {
                                    onSelect(addr.address);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Address card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.separator.withValues(alpha: 0.3)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 12,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    Icons.location_on_rounded, AppColors.accent, 'PICKUP DETAILS'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TrakaInput(
                      hint: 'Pickup address',
                      controller: widget.pickupCtrl,
                      prefixIcon: const Icon(Icons.radio_button_checked,
                          color: AppColors.accent, size: 20),
                      onChanged: (_) { setState(() {}); widget.onFieldChanged?.call(); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _AddressBookButton(
                      onTap: () => _pickAddress(widget.onSelectPickup)),
                ]),
                const SizedBox(height: 16),
                const Divider(color: AppColors.separator, thickness: 0.5),
                const SizedBox(height: 16),
                _sectionHeader(
                    Icons.flag_rounded, AppColors.textPrimary, 'DELIVERY DETAILS'),
                const SizedBox(height: 10),
                TrakaInput(
                  hint: 'Recipient Name',
                  controller: widget.recipientNameCtrl,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) { setState(() {}); widget.onFieldChanged?.call(); },
                ),
                const SizedBox(height: 12),
                TrakaInput(
                  hint: 'Recipient Phone Number',
                  controller: widget.recipientPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) { setState(() {}); widget.onFieldChanged?.call(); },
                ),
                const SizedBox(height: 12),
                TrakaInput(
                  hint: 'Full Delivery Address',
                  controller: widget.deliveryCtrl,
                  maxLines: 2,
                  onChanged: (_) { setState(() {}); widget.onFieldChanged?.call(); },
                ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: _AddressBookButton(
                      onTap: () => _pickAddress(widget.onSelectDelivery)),
                ),
                const SizedBox(height: 14),
                // Tracking link toggle
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send tracking link?',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'The recipient will get SMS updates.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: widget.sendTrackingLink,
                      onChanged: widget.onToggle,
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map preview placeholder
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Route Preview',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.separator.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(Icons.map_outlined,
                      color: AppColors.textQuaternary, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _StepPackage extends StatelessWidget {
  final String selectedCategory;
  final String selectedSize;
  final String selectedSpeed;
  final List<(String, String)> categories;
  final List<_PackageSize> packageSizes;
  final TextEditingController descriptionCtrl;
  final TextEditingController deliveryNotesCtrl;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<String> onSpeedChanged;
  final ValueChanged<String> onDescriptionChanged;

  const _StepPackage({
    required this.selectedCategory,
    required this.selectedSize,
    required this.selectedSpeed,
    required this.categories,
    required this.packageSizes,
    required this.descriptionCtrl,
    required this.deliveryNotesCtrl,
    required this.onCategoryChanged,
    required this.onSizeChanged,
    required this.onSpeedChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package category
          Text('Package Category',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = cat.$1 == selectedCategory;
              return GestureDetector(
                onTap: () => onCategoryChanged(cat.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    cat.$2,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (selectedCategory == 'OTHERS') ...[
            const SizedBox(height: 16),
            Text('Describe what you\'re sending *',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TrakaInput(
              hint: 'e.g. Handmade item, custom order...',
              controller: descriptionCtrl,
              maxLines: 2,
              textInputAction: TextInputAction.next,
              onChanged: onDescriptionChanged,
            ),
          ],
          const SizedBox(height: 24),
          // Size grid
          Text('Package Size',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: packageSizes.map((s) {
              final isSelected = s.id == selectedSize;
              return GestureDetector(
                onTap: () => onSizeChanged(s.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentLight : AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.separator,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon,
                            color: isSelected ? AppColors.accent : AppColors.textTertiary,
                            size: 22),
                        const SizedBox(height: 4),
                        Text(s.label,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        Text(s.price,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Delivery Speed
          Text('Delivery Speed',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          ...[
            ('STANDARD', 'Standard', '2–3 hours', AppColors.iosBlue),
            ('EXPRESS', 'Express', 'Within the hour', AppColors.success),
            ('SAME_DAY', 'Same Day', 'By end of day', AppColors.accent),
          ].map((item) {
            final isSelected = selectedSpeed == item.$1;
            return GestureDetector(
              onTap: () => onSpeedChanged(item.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? item.$4.withValues(alpha: 0.08) : AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? item.$4 : AppColors.separator,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: item.$4, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.$2,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                    ),
                    Text(item.$3,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textTertiary)),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, color: item.$4, size: 20),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          // Delivery notes
          Text('Delivery Notes (optional)',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TrakaInput(
            hint: 'e.g. Leave at the gate, call on arrival...',
            controller: deliveryNotesCtrl,
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StepReview extends StatelessWidget {
  final String pickupAddress;
  final String deliveryAddress;
  final String recipientName;
  final String recipientPhone;
  final String packageType;
  final String packageSize;
  final String deliverySpeed;
  final QuoteModel? quote;
  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;

  const _StepReview({
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.packageType,
    required this.packageSize,
    required this.deliverySpeed,
    this.quote,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  String _fmt(double? v) => v != null ? '₦${v.toStringAsFixed(0)}' : '—';

  @override
  Widget build(BuildContext context) {
    final q = quote;
    final hasBreakdown = q != null && q.estimatedCost > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.separator.withValues(alpha: 0.3)),
              boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                _ReviewRow('Pickup', pickupAddress, Icons.radio_button_checked, AppColors.accent),
                const Divider(color: AppColors.separator, thickness: 0.5),
                _ReviewRow('Delivery to', '$recipientName\n$deliveryAddress', Icons.flag_rounded, AppColors.textPrimary),
                const Divider(color: AppColors.separator, thickness: 0.5),
                _ReviewRow('Package', '$packageType · $packageSize', Icons.inventory_2_outlined, AppColors.iosBlue),
                const Divider(color: AppColors.separator, thickness: 0.5),
                _ReviewRow('Speed', deliverySpeed.replaceAll('_', ' '), Icons.access_time_rounded, AppColors.success),
                if (q?.distanceKm != null) ...[
                  const Divider(color: AppColors.separator, thickness: 0.5),
                  _ReviewRow('Distance', '${q!.distanceKm!.toStringAsFixed(1)} km', Icons.straighten_rounded, AppColors.textTertiary),
                ],
                if (q?.deliveryEta != null) ...[
                  const Divider(color: AppColors.separator, thickness: 0.5),
                  _ReviewRow('Est. arrival', q!.deliveryEta!, Icons.schedule_rounded, AppColors.textTertiary),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.separator.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Breakdown',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                if (!hasBreakdown)
                  const _PriceLoader()
                else ...[
                  if (q.baseFee != null)
                    _PriceRow('Base fee', _fmt(q.baseFee)),
                  if (q.distanceFee != null) ...[
                    const SizedBox(height: 6),
                    _PriceRow('Distance fee', _fmt(q.distanceFee)),
                  ],
                  if (q.sizeFee != null && q.sizeFee! > 0) ...[
                    const SizedBox(height: 6),
                    _PriceRow('Size fee', _fmt(q.sizeFee)),
                  ],
                  if (q.speedFee != null && q.speedFee! > 0) ...[
                    const SizedBox(height: 6),
                    _PriceRow('Speed fee', _fmt(q.speedFee)),
                  ],
                  if (q.fuelAdjustment != null && q.fuelAdjustment! > 0) ...[
                    const SizedBox(height: 6),
                    _PriceRow('Fuel adjustment', _fmt(q.fuelAdjustment)),
                  ],
                  if (q.platformFee != null) ...[
                    const SizedBox(height: 6),
                    _PriceRow('Platform fee', _fmt(q.platformFee)),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.separator, thickness: 0.5),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(
                        '₦${q.estimatedCost.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment method
          Text('Payment Method',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _PaymentOption(
            icon: Icons.account_balance_wallet_outlined,
            title: 'TRAKA Wallet',
            subtitle: 'Deducted from wallet balance',
            selected: paymentMethod == 'WALLET',
            onTap: () => onPaymentMethodChanged('WALLET'),
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            icon: Icons.account_balance_rounded,
            title: 'Bank Transfer on Delivery',
            subtitle: 'Pay via transfer when package arrives',
            selected: paymentMethod == 'BANK_TRANSFER',
            onTap: () => onPaymentMethodChanged('BANK_TRANSFER'),
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            icon: Icons.payments_outlined,
            title: 'Cash on Delivery',
            subtitle: 'Pay the rider in cash at delivery',
            selected: paymentMethod == 'CASH',
            onTap: () => onPaymentMethodChanged('CASH'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : AppColors.bgTertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20,
                  color: selected ? Colors.white : AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
                  Text(subtitle, style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _ReviewRow(this.label, this.value, this.icon, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textTertiary)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _PackageSize {
  final String id;
  final String label;
  final IconData icon;
  final String price;
  const _PackageSize(this.id, this.label, this.icon, this.price);
}

class _PriceLoader extends StatefulWidget {
  const _PriceLoader();

  @override
  State<_PriceLoader> createState() => _PriceLoaderState();
}

class _PriceLoaderState extends State<_PriceLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounce = Tween(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _bounce,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _bounce.value),
              child: child,
            ),
            child: const Text('💰', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculating price...',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textQuaternary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressBookButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddressBookButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.import_contacts_rounded,
            color: AppColors.accent, size: 20),
      ),
    );
  }
}
