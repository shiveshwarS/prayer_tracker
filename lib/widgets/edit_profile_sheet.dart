import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../theme/app_palette.dart';
import 'primary_button.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.controller});

  final AuthController controller;

  static Future<void> show(BuildContext context, AuthController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return EditProfileSheet(controller: controller);
      },
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final UserModel? user = widget.controller.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final bool saved = await widget.controller.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );
    if (saved && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final UserModel? user = widget.controller.user;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
              maxWidth: 620,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'YOUR PROFILE',
                                style: textTheme.labelSmall?.copyWith(
                                  color: palette.inkMuted,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Edit your details',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your profile is only stored on this device. No account or sign-in is required.',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.inkMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        counterText: '',
                      ),
                      validator: (String? value) {
                        final String name = (value ?? '').trim();
                        if (name.isEmpty) {
                          return 'Please enter your name.';
                        }
                        if (name.length < 2) {
                          return 'Your name needs at least 2 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 13),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (String? value) {
                        final String digits = (value ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        if (digits.isEmpty) {
                          return 'Please enter your phone number.';
                        }
                        if (digits.length < 6) {
                          return 'That phone number looks too short.';
                        }
                        if (digits.length > 15) {
                          return 'That phone number looks too long.';
                        }
                        return null;
                      },
                    ),
                    if (widget.controller.errorMessage != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        widget.controller.errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Save changes',
                      icon: Icons.check_rounded,
                      isLoading: widget.controller.isSaving,
                      onPressed: user == null ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
