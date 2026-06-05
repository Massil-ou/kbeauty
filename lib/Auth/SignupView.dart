import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import 'AuthScaffold.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key, required this.manager});

  final Manager manager;

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpStep = false;
  bool _obscure = true;
  bool _accepted = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions.')),
      );
      return;
    }
    final result = await widget.manager.authManager.register(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
    );
    if (result.success && mounted) setState(() => _otpStep = true);
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result = await widget.manager.authManager.verifyRegistration(
      email: _email.text,
      password: _password.text,
      otp: _otp.text,
    );
    if (result.success && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListenableBuilder(
        listenable: widget.manager.authManager,
        builder: (context, _) {
          final auth = widget.manager.authManager;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _otpStep
                ? _otpCard(auth.isLoading, auth.lastError)
                : _infoCard(auth.isLoading, auth.lastError),
          );
        },
      ),
    );
  }

  Widget _infoCard(bool loading, String? error) {
    return AuthCard(
      key: const ValueKey('signup'),
      icon: Icons.person_add_alt_1_rounded,
      title: 'Créer mon compte',
      subtitle:
          'Réservez vos prestations beauté et retrouvez tous vos rendez-vous.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstName,
                    textCapitalization: TextCapitalization.words,
                    validator: _required,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _lastName,
                    textCapitalization: TextCapitalization.words,
                    validator: _required,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: _required,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              validator: passwordValidator,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _accepted,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: KBeautyTheme.primary,
              onChanged: (value) => setState(() => _accepted = value ?? false),
              title: const Text(
                'J’accepte les conditions générales d’utilisation.',
                style: TextStyle(color: KBeautyTheme.muted, fontSize: 13),
              ),
            ),
            if (error != null) ...[
              AuthErrorBanner(message: error),
              const SizedBox(height: 14),
            ],
            AuthPrimaryButton(
              label: 'Créer mon compte',
              loading: loading,
              onPressed: _register,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Déjà inscrite ?',
                  style: TextStyle(color: KBeautyTheme.muted, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpCard(bool loading, String? error) {
    return AuthCard(
      key: const ValueKey('signupOtp'),
      icon: Icons.verified_user_rounded,
      title: 'Vérifiez votre compte',
      subtitle:
          'Saisissez le code envoyé à ${_email.text.trim().toLowerCase()}.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _otp,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(6),
              ],
              validator: otpValidator,
              decoration: const InputDecoration(
                labelText: 'Code à 6 caractères',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
            const SizedBox(height: 14),
            if (error != null) ...[
              AuthErrorBanner(message: error),
              const SizedBox(height: 14),
            ],
            AuthPrimaryButton(
              label: 'Activer mon compte',
              loading: loading,
              onPressed: _verify,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: loading
                  ? null
                  : () => widget.manager.authManager
                      .resendRegistrationOtp(_email.text),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text('Renvoyer le code'),
            ),
            TextButton.icon(
              onPressed: loading
                  ? null
                  : () {
                      widget.manager.authManager.clearError();
                      setState(() => _otpStep = false);
                    },
              icon: const Icon(Icons.arrow_back, size: 17),
              label: const Text('Modifier mes informations'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Ce champ est requis.' : null;
}
