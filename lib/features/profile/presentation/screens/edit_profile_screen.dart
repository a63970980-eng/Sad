import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _national;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _name = TextEditingController(text: user?.fullName ?? '');
    _national = TextEditingController(text: user?.nationalNumber ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _national.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    final updated = user.copyWith(
      fullName: _name.text.trim(),
      nationalNumber: _national.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
    );
    await ref.read(profileControllerProvider.notifier).save(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).save),
        backgroundColor: AppColors.primary,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.personalInfo)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primarySoft,
                child: Text(user?.initials ?? '👤',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 24),
            _Label(l.fullName),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(hintText: l.fullName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            _Label(l.phoneNumber),
            TextFormField(
              initialValue: user?.phoneNumber,
              enabled: false,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 16),
            _Label(l.nationalNumber),
            TextFormField(
              controller: _national,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(hintText: l.nationalNumber),
            ),
            const SizedBox(height: 16),
            const _Label('Email'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'name@example.com'),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Icon(Icons.check_rounded),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
      );
}
