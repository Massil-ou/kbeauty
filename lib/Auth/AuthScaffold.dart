import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Shared/KBeautyTheme.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KBeautyTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const KBeautyBackdrop(),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              14,
              MediaQuery.paddingOf(context).top + 92,
              14,
              36,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: child,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              height: MediaQuery.paddingOf(context).top + 66,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: KBeautyTheme.divider)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/icons/keauty-icon.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'keauty',
                        style: TextStyle(
                          color: KBeautyTheme.primaryDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 10,
                    child: IconButton(
                      tooltip: 'Retour',
                      onPressed: () => context.go('/'),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: KBeautyTheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: KBeautyTheme.primaryDark.withValues(alpha: 0.13),
            blurRadius: 34,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [KBeautyTheme.primary, KBeautyTheme.primaryDark],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -29),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: KBeautyTheme.primary.withValues(alpha: 0.26),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: KBeautyTheme.primary.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: KBeautyTheme.primary, size: 27),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: KBeautyTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: KBeautyTheme.muted,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KBeautyTheme.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KBeautyTheme.danger.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: KBeautyTheme.danger, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: KBeautyTheme.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

String? emailValidator(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'L’adresse e-mail est requise.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
    return 'Adresse e-mail invalide.';
  }
  return null;
}

String? passwordValidator(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return 'Le mot de passe est requis.';
  if (text.length < 8 ||
      !RegExp(r'[A-Z]').hasMatch(text) ||
      !RegExp(r'\d').hasMatch(text)) {
    return '8 caractères minimum, avec une majuscule et un chiffre.';
  }
  return null;
}

String? otpValidator(String? value) {
  if (!RegExp(r'^[A-Za-z0-9]{6}$').hasMatch((value ?? '').trim())) {
    return 'Saisissez le code à 6 caractères.';
  }
  return null;
}
