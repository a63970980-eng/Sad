import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../widgets/brand_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final raw = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    final e164 = '${AppConstants.countryDialCode}${raw.replaceFirst(RegExp(r'^0+'), '')}';

    final ok = await ref
        .read(loginControllerProvider.notifier)
        .sendCode(e164, rememberMe: _rememberMe);

    if (!mounted) return;
    if (ok) {
      context.push(AppRoutes.otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).loginFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(loginControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(child: BrandLogo(size: 92))
                    .animate()
                    .scale(curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: 28),
                Text(l.loginTitle,
                        textAlign: TextAlign.center,
                        style:
                            t.headlineSmall?.copyWith(fontWeight: FontWeight.w800))
                    .animate()
                    .fadeIn(delay: 150.ms),
                const SizedBox(height: 10),
                Text(l.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: t.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant))
                    .animate()
                    .fadeIn(delay: 250.ms),
                const SizedBox(height: 36),
                Text(l.phoneNumber,
                    style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                    decoration: InputDecoration(
                      hintText: l.phoneHint,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇾🇪', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(AppConstants.countryDialCode,
                                style: t.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    validator: (v) {
                      final value = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                      if (value.length < 9) return l.invalidPhone;
                      return null;
                    },
                  ),
                ).animate().fadeIn(delay: 350.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v),
                  title: Text(l.rememberMe, style: t.bodyMedium),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: state.loading ? null : _submit,
                  child: state.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : Text(l.continueLabel),
                ).animate().fadeIn(delay: 450.ms),
                if (AppConfig.demoMode) ...[
                  const SizedBox(height: 16),
                  _DemoHint(otp: AppConfig.demoOtp),
                ],
                const SizedBox(height: 24),
                Text(l.termsNotice,
                    textAlign: TextAlign.center,
                    style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.otp});
  final String otp;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'وضع العرض التجريبي • استخدم أي رقم ورمز التحقق $otp',
              style: t.bodySmall?.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }
}
