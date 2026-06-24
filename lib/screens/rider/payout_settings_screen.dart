import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  final _accountNameCtrl = TextEditingController(text: 'John Doe');
  final _accountNumberCtrl = TextEditingController(text: '0123456789');
  String _selectedBank = 'Guaranty Trust Bank (GTB)';
  String _payoutFrequency = 'DAILY';

  static const _banks = [
    'Access Bank',
    'Fidelity Bank',
    'First Bank of Nigeria',
    'Guaranty Trust Bank (GTB)',
    'Kuda Bank',
    'Opay',
    'Palmpay',
    'Polaris Bank',
    'Stanbic IBTC Bank',
    'Sterling Bank',
    'Union Bank',
    'United Bank for Africa (UBA)',
    'Wema Bank',
    'Zenith Bank',
  ];

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payout Settings',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.warning],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Balance',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 4),
                        Text('₦24,500.00',
                            style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Next payout: Today, 6:00 PM',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _confirmWithdraw(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.accent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Withdraw',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(label: 'Bank Account'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 12,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Bank'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showBankPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_selectedBank,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: AppColors.textPrimary)),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Account Number'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _accountNumberCtrl,
                    hint: '0123456789',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Account Name'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _accountNameCtrl,
                    hint: 'Your full name',
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(label: 'Payout Schedule'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 12,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _FrequencyOption(
                    label: 'Daily',
                    subtitle: 'Earnings paid out every day at 6PM',
                    value: 'DAILY',
                    groupValue: _payoutFrequency,
                    onChanged: (v) => setState(() => _payoutFrequency = v!),
                    isFirst: true,
                  ),
                  _FrequencyOption(
                    label: 'Weekly',
                    subtitle: 'Every Friday',
                    value: 'WEEKLY',
                    groupValue: _payoutFrequency,
                    onChanged: (v) => setState(() => _payoutFrequency = v!),
                  ),
                  _FrequencyOption(
                    label: 'Instant',
                    subtitle: 'After each completed delivery',
                    value: 'INSTANT',
                    groupValue: _payoutFrequency,
                    onChanged: (v) => setState(() => _payoutFrequency = v!),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Payout settings saved'),
                    backgroundColor: AppColors.success,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save Changes',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBankPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.separator,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Select Bank',
                style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _banks.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: AppColors.separator),
                itemBuilder: (_, i) => ListTile(
                  title: Text(_banks[i],
                      style: GoogleFonts.inter(
                          fontSize: 15, color: AppColors.textPrimary)),
                  trailing: _selectedBank == _banks[i]
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.accent)
                      : null,
                  onTap: () {
                    setState(() => _selectedBank = _banks[i]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.separator,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('Withdraw Earnings',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('₦24,500.00 → $_selectedBank',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textTertiary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Withdrawal initiated successfully'),
                    backgroundColor: AppColors.success,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Confirm Withdrawal',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 0.5)),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 13, color: AppColors.textSecondary));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style:
          GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 15, color: AppColors.textQuaternary),
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final bool isFirst;
  final bool isLast;

  const _FrequencyOption({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                      Text(subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: AppColors.accent,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.separator,
              indent: 16),
      ],
    );
  }
}
