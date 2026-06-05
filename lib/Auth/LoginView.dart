import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import 'AuthScaffold.dart';

enum _LoginStep { credentials, otp, forgot, sent }

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.manager});

  final Manager manager;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();
  final _forgotEmail = TextEditingController();
  _LoginStep _step = _LoginStep.credentials;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    _forgotEmail.dispose();
    super.dispose();
  }

  Future<void> _requestLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result = await widget.manager.authManager.requestLogin(
      email: _email.text,
      password: _password.text,
    );
    if (result.success && mounted) setState(() => _step = _LoginStep.otp);
  }

  Future<void> _verifyOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result = await widget.manager.authManager.verifyLogin(
      email: _email.text,
      password: _password.text,
      otp: _otp.text,
    );
    if (result.success && mounted) context.go('/');
  }

  Future<void> _forgotPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result =
        await widget.manager.authManager.forgotPassword(_forgotEmail.text);
    if (result.success && mounted) setState(() => _step = _LoginStep.sent);
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
            child: switch (_step) {
              _LoginStep.otp => _otpCard(auth.isLoading, auth.lastError),
              _LoginStep.forgot => _forgotCard(auth.isLoading, auth.lastError),
              _LoginStep.sent => _sentCard(),
              _ => _credentialsCard(auth.isLoading, auth.lastError),
            },
          );
        },
      ),
    );
  }

  Widget _credentialsCard(bool loading, String? error) {
    return AuthCard(
      key: const ValueKey('credentials'),
      icon: Icons.lock_open_rounded,
      title: 'Bon retour parmi nous',
      subtitle: 'Connectez-vous pour réserver et suivre vos rendez-vous.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: emailValidator,
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: loading
                    ? null
                    : () {
                        _forgotEmail.text = _email.text;
                        widget.manager.authManager.clearError();
                        setState(() => _step = _LoginStep.forgot);
                      },
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            if (error != null) ...[
              AuthErrorBanner(message: error),
              const SizedBox(height: 14),
            ],
            AuthPrimaryButton(
              label: 'Se connecter',
              loading: loading,
              onPressed: _requestLogin,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pas encore de compte ?',
                  style: TextStyle(color: KBeautyTheme.muted, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Créer un compte'),
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
      key: const ValueKey('otp'),
      icon: Icons.verified_user_rounded,
      title: 'Code de vérification',
      subtitle: 'Le code envoyé par e-mail sécurise votre connexion.',
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
              label: 'Valider et continuer',
              loading: loading,
              onPressed: _verifyOtp,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: loading
                  ? null
                  : () {
                      widget.manager.authManager.clearError();
                      setState(() => _step = _LoginStep.credentials);
                    },
              icon: const Icon(Icons.arrow_back, size: 17),
              label: const Text('Modifier mes identifiants'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _forgotCard(bool loading, String? error) {
    return AuthCard(
      key: const ValueKey('forgot'),
      icon: Icons.lock_reset_rounded,
      title: 'Mot de passe oublié',
      subtitle: 'Nous vous envoyons un lien sécurisé de réinitialisation.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _forgotEmail,
              validator: emailValidator,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),
            if (error != null) ...[
              AuthErrorBanner(message: error),
              const SizedBox(height: 14),
            ],
            AuthPrimaryButton(
              label: 'Envoyer le lien',
              loading: loading,
              onPressed: _forgotPassword,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                widget.manager.authManager.clearError();
                setState(() => _step = _LoginStep.credentials);
              },
              icon: const Icon(Icons.arrow_back, size: 17),
              label: const Text('Retour à la connexion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sentCard() {
    return AuthCard(
      key: const ValueKey('sent'),
      icon: Icons.mark_email_read_outlined,
      title: 'E-mail envoyé',
      subtitle:
          'Consultez votre boîte de réception pour créer un nouveau mot de passe.',
      child: AuthPrimaryButton(
        label: 'Retour à la connexion',
        onPressed: () => setState(() => _step = _LoginStep.credentials),
      ),
    );
  }
}
