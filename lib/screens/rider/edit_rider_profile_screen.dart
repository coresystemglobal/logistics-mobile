import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
import '../../providers/auth_provider.dart';

class EditRiderProfileScreen extends ConsumerStatefulWidget {
  const EditRiderProfileScreen({super.key});

  @override
  ConsumerState<EditRiderProfileScreen> createState() =>
      _EditRiderProfileScreenState();
}

class _EditRiderProfileScreenState
    extends ConsumerState<EditRiderProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = ref.read(authProvider).user;
      if (mounted) {
        setState(() {
          _firstNameCtrl.text = user?.firstName ?? '';
          _surnameCtrl.text = user?.surname ?? '';
          _phoneCtrl.text = user?.phone ?? '';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _surnameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updates = <String, dynamic>{};
      if (_firstNameCtrl.text.trim().isNotEmpty) {
        updates['first_name'] = _firstNameCtrl.text.trim();
      }
      if (_surnameCtrl.text.trim().isNotEmpty) {
        updates['surname'] = _surnameCtrl.text.trim();
      }
      if (_phoneCtrl.text.trim().isNotEmpty) {
        updates['phone'] = _phoneCtrl.text.trim();
      }

      await ApiClient.instance.patch(ApiEndpoints.updateMe, data: updates);
      await ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
        title: Text('Edit Profile',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.of(context).padding.bottom + 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('Personal Info'),
                    const SizedBox(height: 10),
                    _card([
                      Row(children: [
                        Expanded(
                          child: _field('First Name', _firstNameCtrl,
                              hint: 'John',
                              action: TextInputAction.next),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field('Surname', _surnameCtrl,
                              hint: 'Doe',
                              action: TextInputAction.next),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      _field('Phone Number', _phoneCtrl,
                          hint: '+234 800 000 0000',
                          type: TextInputType.phone,
                          action: TextInputAction.done),
                    ]),
                    const SizedBox(height: 24),
                    _section('Vehicle Info'),
                    const SizedBox(height: 10),
                    _card([
                      // Vehicle type and plate are set at registration — contact support to change
                      Row(children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.textTertiary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vehicle type and plate can only be changed by support. Contact us to update.',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textTertiary,
                                height: 1.4),
                          ),
                        ),
                      ]),
                    ]),
                    const SizedBox(height: 32),
                    TrakaButton(
                      label: 'Save Changes',
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 0.5)),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    TextInputType type = TextInputType.text,
    TextInputAction action = TextInputAction.next,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TrakaInput(
            hint: hint,
            controller: ctrl,
            keyboardType: type,
            textInputAction: action,
          ),
        ],
      );
}

