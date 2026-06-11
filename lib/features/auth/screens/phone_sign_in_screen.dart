import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';

/// Two-step phone sign-in: enter number → enter the 6-digit OTP. Backed by the
/// AuthRepository (real Firebase OTP when enabled; the mock accepts any code).
class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final _phone = TextEditingController(text: '+961 ');
  final _code = TextEditingController();
  String? _verificationId;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  String get _normalizedPhone => _phone.text.replaceAll(' ', '');

  Future<void> _sendCode() async {
    if (_normalizedPhone.length < 8) {
      setState(() => _error = AppLocalizations.of(context).invalidPhone);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(authRepositoryProvider)
          .startPhoneSignIn(_normalizedPhone);
      setState(() => _verificationId = id);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .confirmOtp(_verificationId!, _code.text.trim());
      if (mounted) Navigator.of(context).pop(); // auth gate takes over
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final codeStep = _verificationId != null;

    return Scaffold(
      appBar: AppBar(title: Text(t.phoneTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(codeStep ? t.otpBody(_normalizedPhone) : t.phoneBody,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              if (!codeStep)
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: t.phone,
                    hintText: t.phoneHint,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                )
              else
                TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(counterText: ''),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy
                    ? null
                    : codeStep
                        ? _verify
                        : _sendCode,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(codeStep ? t.verify : t.sendCode),
              ),
              if (codeStep)
                TextButton(
                  onPressed: _busy ? null : _sendCode,
                  child: Text(t.resendCode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
