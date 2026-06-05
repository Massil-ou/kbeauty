import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import 'KBeautyAccountMenu.dart';
import 'KBeautyTheme.dart';

class KBeautyHeader extends StatelessWidget implements PreferredSizeWidget {
  const KBeautyHeader({
    super.key,
    required this.manager,
    this.title,
    this.showBack = false,
    this.onBack,
    this.actions = const [],
  });

  final Manager manager;
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) => AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 66,
        titleSpacing: 12,
        title: Row(
          children: [
            if (showBack) ...[
              IconButton(
                tooltip: 'Retour',
                onPressed: onBack ?? () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const SizedBox(width: 2),
            ],
            InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icons/kbeauty-icon.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    title ?? 'kBeauty',
                    style: const TextStyle(
                      color: KBeautyTheme.primaryDark,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ...actions,
          ..._accountActions(context),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  List<Widget> _accountActions(BuildContext context) {
    if (!manager.isAuthenticated) {
      return [
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Connexion'),
        ),
        const SizedBox(width: 4),
        ElevatedButton(
          onPressed: () => context.go('/signup'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          ),
          child: const Text('Inscription'),
        ),
      ];
    }

    return [
      _menuButton(
        context,
        showLabel: MediaQuery.sizeOf(context).width >= 720,
      ),
    ];
  }

  Widget _menuButton(BuildContext context, {bool showLabel = false}) {
    return TextButton.icon(
      onPressed: () => KBeautyAccountMenu.open(context, manager),
      icon: const Icon(Icons.menu_rounded, size: 22),
      label: showLabel
          ? Text(
              manager.currentUserName.isEmpty
                  ? 'Menu'
                  : manager.currentUserName,
            )
          : const SizedBox.shrink(),
    );
  }
}

class KBeautyPage extends StatelessWidget {
  const KBeautyPage({
    super.key,
    required this.manager,
    required this.child,
    this.title,
    this.showBack = true,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 40),
    this.actions = const [],
  });

  final Manager manager;
  final Widget child;
  final String? title;
  final bool showBack;
  final EdgeInsets padding;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KBeautyTheme.background,
      appBar: KBeautyHeader(
        manager: manager,
        title: title,
        showBack: showBack,
        actions: actions,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const KBeautyBackdrop(),
          SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KBeautyCard extends StatelessWidget {
  const KBeautyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: KBeautyTheme.cardDecoration(),
      child: child,
    );
  }
}

class KBeautySectionTitle extends StatelessWidget {
  const KBeautySectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: KBeautyTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: KBeautyTheme.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class KBeautyEmptyState extends StatelessWidget {
  const KBeautyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return KBeautyCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: KBeautyTheme.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: KBeautyTheme.primary, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KBeautyTheme.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KBeautyTheme.muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class KBeautyErrorBanner extends StatelessWidget {
  const KBeautyErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KBeautyTheme.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KBeautyTheme.danger.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: KBeautyTheme.danger, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: KBeautyTheme.danger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KBeautyStatusChip extends StatelessWidget {
  const KBeautyStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
