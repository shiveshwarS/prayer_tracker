import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/geometric_pattern.dart';
import '../../widgets/primary_button.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key, required this.controller});

  final AuthController controller;

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _consent = false;
  bool _showConsentError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final bool formValid = _formKey.currentState?.validate() ?? false;
    if (!_consent) {
      setState(() {
        _showConsentError = true;
      });
    } else if (_showConsentError) {
      setState(() {
        _showConsentError = false;
      });
    }
    if (!formValid || !_consent) {
      return;
    }
    await widget.controller.signUp(
      name: _nameController.text,
      phone: _phoneController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;

    return Scaffold(
      key: const ValueKey<String>('signup-view'),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isWide = constraints.maxWidth >= 960;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Expanded(flex: 5, child: _WelcomePanel()),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 40,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: _buildForm(context, compact: false),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const AppLogo(size: 50),
                              const SizedBox(width: 12),
                              Text(
                                'NOOR',
                                style: textTheme(
                                  context,
                                ).displaySmall?.copyWith(letterSpacing: 4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 34),
                          _buildForm(context, compact: true),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      backgroundColor: palette.canvas,
    );
  }

  TextTheme textTheme(BuildContext context) => Theme.of(context).textTheme;

  Widget _buildForm(BuildContext context, {required bool compact}) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'BEGIN YOUR JOURNEY',
            style: textTheme.labelSmall?.copyWith(
              color: palette.inkMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A quiet place\nfor prayer.',
            style: textTheme.displayMedium?.copyWith(
              fontSize: compact ? 43 : 48,
              height: 0.98,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Create a local profile to keep your daily prayers, streak, and reflection. No password, no cloud, no noise.',
            style: textTheme.bodyMedium?.copyWith(
              color: palette.inkMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          TextFormField(
            key: const ValueKey<String>('signup-name-field'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Your name',
              hintText: 'e.g. Amina',
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
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey<String>('signup-phone-field'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: 'Used only as your local identifier',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (String? value) {
              final String digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
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
          const SizedBox(height: 16),
          Semantics(
            checked: _consent,
            label:
                'I understand that my profile and prayer history are stored only on this device.',
            child: InkWell(
              onTap: () {
                setState(() {
                  _consent = !_consent;
                  if (_consent) {
                    _showConsentError = false;
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 21,
                      height: 21,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: _consent ? palette.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _consent ? palette.ink : palette.inkMuted,
                          width: 1.4,
                        ),
                      ),
                      child:
                          _consent
                              ? Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: palette.inverseInk,
                              )
                              : null,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'I understand my profile and prayer history are stored only on this device.',
                        style: textTheme.bodySmall?.copyWith(
                          color:
                              _showConsentError
                                  ? palette.error
                                  : palette.inkMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showConsentError) ...<Widget>[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(
                'Please confirm before continuing.',
                style: textTheme.bodySmall?.copyWith(color: palette.error),
              ),
            ),
          ],
          if (widget.controller.errorMessage != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.line),
              ),
              child: Text(
                widget.controller.errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: palette.error),
              ),
            ),
          ],
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Begin with Noor',
            icon: Icons.arrow_forward_rounded,
            isLoading: widget.controller.isSaving,
            onPressed: _submit,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: palette.inkMuted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Everything stays on this device.',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.inkMuted,
                    fontSize: 9,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: palette.inverse,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GeometricPattern(
              color: palette.inverseInk,
              opacity: 0.06,
              spacing: 58,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const AppLogo(size: 76),
                    const SizedBox(height: 30),
                    Text(
                      'NOOR',
                      style: textTheme.displayLarge?.copyWith(
                        fontFamily: AppTextStyles.displayFamily,
                        color: palette.inverseInk,
                        letterSpacing: 8,
                        fontSize: 54,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'A daily rhythm of prayer,\nheld with intention.',
                      style: textTheme.headlineMedium?.copyWith(
                        color: palette.inverseInk,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Container(
                      width: 44,
                      height: 1,
                      color: palette.inverseInk.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 28),
                    _WelcomePoint(
                      icon: Icons.location_off_outlined,
                      title: 'Private by default',
                      message: 'Your prayers never leave this device.',
                      color: palette.inverseInk,
                      mutedColor: palette.inverseMuted,
                    ),
                    const SizedBox(height: 18),
                    _WelcomePoint(
                      icon: Icons.wb_twilight_outlined,
                      title: 'Grounded in your day',
                      message: 'Times, Qibla, and streaks in one quiet place.',
                      color: palette.inverseInk,
                      mutedColor: palette.inverseMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePoint extends StatelessWidget {
  const _WelcomePoint({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.mutedColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: textTheme.bodySmall?.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
