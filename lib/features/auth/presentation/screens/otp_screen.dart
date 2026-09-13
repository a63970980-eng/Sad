import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _seconds = AppConstants.otpResendSeconds;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = AppConstants.otpResendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    setState(() => _error = null);
    final ok = await ref.read(loginControllerProvider.notifier).verify(code);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = AppLocalizations.of(context).invalidOtp);
      _otpController.clear();
    }
  }

  Future<void> _resend() async {
    final state = ref.read(loginControllerProvider);
    await ref
        .read(loginControllerProvider.notifier)
        .sendCode(state.phone, rememberMe: true);
    if (mounted) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(loginControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined,
                    color: AppColors.primary, size: 38),
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(l.otpTitle,
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(l.otpSubtitle(state.phone),
                  textAlign: TextAlign.center,
                  style:
                      t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              Directionality(
                textDirection: TextDirection.ltr,
                child: PinCodeTextField(
                  appContext: context,
                  controller: _otpController,
                  length: AppConstants.otpLength,
                  autoFocus: true,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  enableActiveFill: true,
                  cursorColor: AppColors.primary,
                  textStyle:
                      t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: 56,
                    fieldWidth: 46,
                    activeColor: AppColors.primary,
                    selectedColor: AppColors.primary,
                    inactiveColor: scheme.outline,
                    activeFillColor: scheme.surface,
                    selectedFillColor: scheme.surface,
                    inactiveFillColor: scheme.surface,
                    errorBorderColor: AppColors.danger,
                  ),
                  onCompleted: _verify,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: t.bodySmall?.copyWith(color: AppColors.danger)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.loading
                    ? null
                    : () {
                        if (_otpController.text.length ==
                            AppConstants.otpLength) {
                          _verify(_otpController.text);
                        }
                      },
                child: state.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : Text(l.verify),
              ),
              const SizedBox(height: 18),
              Center(
                child: _seconds > 0
                    ? Text(l.resendIn(_seconds),
                        style: t.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant))
                    : TextButton(
                        onPressed: _resend,
                        child: Text(l.resendCode),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
