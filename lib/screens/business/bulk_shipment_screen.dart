import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class _Recipient {
  final String name;
  final String phone;
  final String address;

  const _Recipient({required this.name, required this.phone, required this.address});

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

final _bulkProvider = StateNotifierProvider.autoDispose<_BulkNotifier, _BulkState>(
  (_) => _BulkNotifier(),
);

class _BulkState {
  final int step;
  final List<_Recipient> recipients;
  final bool formExpanded;
  final String nameInput;
  final String phoneInput;
  final String addressInput;
  final bool saveToBook;

  const _BulkState({
    this.step = 0,
    this.recipients = const [],
    this.formExpanded = false,
    this.nameInput = '',
    this.phoneInput = '',
    this.addressInput = '',
    this.saveToBook = false,
  });

  _BulkState copyWith({
    int? step,
    List<_Recipient>? recipients,
    bool? formExpanded,
    String? nameInput,
    String? phoneInput,
    String? addressInput,
    bool? saveToBook,
  }) =>
      _BulkState(
        step: step ?? this.step,
        recipients: recipients ?? this.recipients,
        formExpanded: formExpanded ?? this.formExpanded,
        nameInput: nameInput ?? this.nameInput,
        phoneInput: phoneInput ?? this.phoneInput,
        addressInput: addressInput ?? this.addressInput,
        saveToBook: saveToBook ?? this.saveToBook,
      );
}

class _BulkNotifier extends StateNotifier<_BulkState> {
  _BulkNotifier() : super(const _BulkState());

  void toggleForm() => state = state.copyWith(formExpanded: !state.formExpanded);
  void setName(String v) => state = state.copyWith(nameInput: v);
  void setPhone(String v) => state = state.copyWith(phoneInput: v);
  void setAddress(String v) => state = state.copyWith(addressInput: v);
  void setSaveToBook(bool v) => state = state.copyWith(saveToBook: v);

  void addRecipient() {
    if (state.nameInput.isEmpty || state.phoneInput.isEmpty || state.addressInput.isEmpty) return;
    final r = _Recipient(name: state.nameInput, phone: state.phoneInput, address: state.addressInput);
    state = state.copyWith(
      recipients: [...state.recipients, r],
      nameInput: '',
      phoneInput: '',
      addressInput: '',
      formExpanded: false,
    );
  }

  void removeRecipient(int index) {
    final list = List<_Recipient>.from(state.recipients)..removeAt(index);
    state = state.copyWith(recipients: list);
  }

  void nextStep() => state = state.copyWith(step: state.step + 1);
}

class BulkShipmentScreen extends ConsumerStatefulWidget {
  const BulkShipmentScreen({super.key});

  @override
  ConsumerState<BulkShipmentScreen> createState() => _BulkShipmentScreenState();
}

class _BulkShipmentScreenState extends ConsumerState<BulkShipmentScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_bulkProvider);
    final notifier = ref.read(_bulkProvider.notifier);

    const steps = ['Recipients', 'Package', 'Review'];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 26, color: AppColors.iosBlue),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text('Bulk Shipment',
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Save Draft',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.iosBlue)),
                  ),
                ],
              ),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: List.generate(steps.length * 2 - 1, (i) {
                  if (i.isOdd) {
                    return Expanded(
                      child: Container(height: 1.5, color: AppColors.separator.withOpacity(0.5)),
                    );
                  }
                  final stepIndex = i ~/ 2;
                  final isActive = stepIndex == state.step;
                  return Column(
                    children: [
                      Text(
                        '${stepIndex + 1} ${steps[stepIndex]}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppColors.accent : AppColors.textQuaternary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const Divider(color: AppColors.separator, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Recipient add card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.separator.withOpacity(0.4)),
                        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          // CSV import
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload_file_rounded, size: 20),
                              label: Text('Import from CSV',
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.iosBlue,
                                side: const BorderSide(color: AppColors.iosBlue, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Supports .csv with name, phone, address columns',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textQuaternary)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.separator.withOpacity(0.5))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textQuaternary)),
                              ),
                              Expanded(child: Divider(color: AppColors.separator.withOpacity(0.5))),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Manual form toggle
                          GestureDetector(
                            onTap: notifier.toggleForm,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Add manually',
                                    style: GoogleFonts.inter(
                                        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.accent)),
                                AnimatedRotation(
                                  turns: state.formExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.expand_more_rounded, color: AppColors.accent),
                                ),
                              ],
                            ),
                          ),

                          if (state.formExpanded) ...[
                            const SizedBox(height: 14),
                            _FormField(
                              label: 'Full Name',
                              hint: 'e.g. John Doe',
                              controller: _nameCtrl,
                              onChanged: notifier.setName,
                            ),
                            const SizedBox(height: 10),
                            _FormField(
                              label: 'Phone Number',
                              hint: '+234 800 000 0000',
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              onChanged: notifier.setPhone,
                            ),
                            const SizedBox(height: 10),
                            _FormField(
                              label: 'Delivery Address',
                              hint: 'Street, City',
                              controller: _addressCtrl,
                              maxLines: 2,
                              onChanged: notifier.setAddress,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Save to Address Book',
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                                Switch.adaptive(
                                  value: state.saveToBook,
                                  onChanged: notifier.setSaveToBook,
                                  activeColor: AppColors.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  notifier.addRecipient();
                                  _nameCtrl.clear();
                                  _phoneCtrl.clear();
                                  _addressCtrl.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Add Recipient',
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Recipient list
                    ...state.recipients.asMap().entries.map((e) => _RecipientTile(
                          recipient: e.value,
                          onRemove: () => notifier.removeRecipient(e.key),
                        )),

                    // Add another
                    GestureDetector(
                      onTap: notifier.toggleForm,
                      child: Container(
                        height: 56,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_rounded, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Text('Add Another Recipient +',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.accent)),
                          ],
                        ),
                      ),
                    ),
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
          border: Border(top: BorderSide(color: AppColors.separator.withOpacity(0.4))),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.recipients.length} recipient${state.recipients.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: state.recipients.isEmpty ? null : notifier.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Continue',
                      style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textQuaternary),
            filled: true,
            fillColor: AppColors.bgSecondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  final _Recipient recipient;
  final VoidCallback onRemove;

  const _RecipientTile({required this.recipient, required this.onRemove});

  static const _colors = [Color(0xFF007AFF), Color(0xFF34C759), Color(0xFFFF6B00), AppColors.iosBlue];

  @override
  Widget build(BuildContext context) {
    final color = _colors[recipient.name.codeUnitAt(0) % _colors.length];
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.separator.withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(
              child: Text(recipient.initials,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipient.name,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                Text(recipient.address,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textQuaternary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textQuaternary),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
