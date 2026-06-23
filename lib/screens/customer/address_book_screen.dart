import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final _service = AddressService();
  List<AddressModel> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getSavedAddresses();
      setState(() => _addresses = data.map(AddressModel.fromJson).toList());
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _setDefault(AddressModel addr) async {
    try {
      await _service.setDefaultAddress(addr.id);
      await _load();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _delete(AddressModel addr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Delete Address',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        content: Text('Remove "${addr.label}"?',
            style: GoogleFonts.inter(
                fontSize: 15, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: AppColors.textTertiary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: GoogleFonts.inter(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deleteAddress(addr.id);
        await _load();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg.replaceAll('Exception: ', '')),
      backgroundColor: AppColors.error,
    ));
  }

  void _showAddSheet() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool isDefault = false;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.separator,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add Address',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              _Field(label: 'Label (e.g. Home, Work)', controller: labelCtrl),
              const SizedBox(height: 14),
              _Field(label: 'Full Address', controller: addressCtrl),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setSheet(() => isDefault = !isDefault),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isDefault
                            ? AppColors.accent
                            : Colors.transparent,
                        border: Border.all(
                            color: isDefault
                                ? AppColors.accent
                                : AppColors.separator,
                            width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isDefault
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text('Set as default sender address',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (labelCtrl.text.trim().isEmpty ||
                              addressCtrl.text.trim().isEmpty) {
                            _showError('Label and address are required');
                            return;
                          }
                          setSheet(() => saving = true);
                          try {
                            await _service.addAddress(
                              label: labelCtrl.text.trim(),
                              address: addressCtrl.text.trim(),
                              isDefault: isDefault,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            await _load();
                          } catch (e) {
                            setSheet(() => saving = false);
                            _showError(e.toString());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('Save Address',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        title: Text('Address Book',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: AppColors.accent, size: 26),
            onPressed: _showAddSheet,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.import_contacts_rounded,
                          size: 56, color: AppColors.textQuaternary),
                      const SizedBox(height: 12),
                      Text('No saved addresses',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textTertiary)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showAddSheet,
                        child: Text('Add one now',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final addr = _addresses[i];
                      return Container(
                        decoration: AppColors.cardDecoration(),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: AppColors.accent, size: 20),
                          ),
                          title: Row(
                            children: [
                              Text(addr.label,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('Default',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accent)),
                                ),
                              ]
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(addr.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textTertiary)),
                          ),
                          trailing: PopupMenuButton<String>(
                            color: AppColors.bgPrimary,
                            icon: const Icon(Icons.more_vert_rounded,
                                color: AppColors.textQuaternary),
                            onSelected: (v) {
                              if (v == 'default') _setDefault(addr);
                              if (v == 'delete') _delete(addr);
                            },
                            itemBuilder: (_) => [
                              if (!addr.isDefault)
                                PopupMenuItem(
                                  value: 'default',
                                  child: Row(children: [
                                    const Icon(Icons.star_rounded,
                                        size: 18, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Text('Set as Default',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.textPrimary)),
                                  ]),
                                ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  const Icon(Icons.delete_outline_rounded,
                                      size: 18, color: AppColors.error),
                                  const SizedBox(width: 8),
                                  Text('Delete',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.error)),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _Field({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(autocorrect: false, enableSuggestions: false, 
          controller: controller,
          style: GoogleFonts.inter(
              fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgSecondary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
