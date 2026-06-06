import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';
import '../Shared/Models.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({
    super.key,
    required this.manager,
    required this.bookingId,
  });

  final Manager manager;
  final String bookingId;

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final _manager = widget.manager.bookingManager;

  @override
  void initState() {
    super.initState();
    _manager.getBooking(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) {
        final booking = _manager.currentBooking?.id == widget.bookingId
            ? _manager.currentBooking
            : null;
        return KBeautyPage(
          manager: widget.manager,
          title: 'Paiement sécurisé',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 18),
              if (_manager.isLoading && booking == null)
                const KBeautySkeletonList(count: 2)
              else if (booking == null)
                KBeautyEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Réservation introuvable',
                  message: _manager.lastError ??
                      'Impossible de charger cette réservation.',
                )
              else ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final summary = _summary(booking);
                    final payment = _paymentCard(booking);
                    if (constraints.maxWidth >= 820) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: summary),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: payment),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        summary,
                        const SizedBox(height: 14),
                        payment,
                      ],
                    );
                  },
                ),
                if (_manager.lastError != null) ...[
                  const SizedBox(height: 14),
                  KBeautyErrorBanner(message: _manager.lastError!),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [KBeautyTheme.primaryDark, KBeautyTheme.primary],
          ),
          borderRadius: BorderRadius.circular(26),
          image: const DecorationImage(
            image: AssetImage('assets/images/back.png'),
            fit: BoxFit.cover,
            opacity: 0.12,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KBeautyStatusChip(
              label: 'Checkout kBeauty',
              color: Colors.white,
              icon: Icons.lock_outline_rounded,
            ),
            SizedBox(height: 14),
            Text(
              'Finalisez votre rendez-vous',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Le rendez-vous est créé uniquement après confirmation du paiement Stripe.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
      );

  Widget _summary(BookingModel booking) => KBeautyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KBeautySectionTitle(
              title: 'Récapitulatif',
              subtitle: 'Vérifiez les informations avant de payer.',
            ),
            const SizedBox(height: 18),
            _line(Icons.spa_outlined, booking.serviceTitle),
            _line(Icons.person_outline, booking.beauticianName),
            _line(
              Icons.calendar_month_outlined,
              _formatDate(booking.scheduledDateTime),
            ),
            _line(Icons.location_on_outlined, booking.locationAddress),
            const Divider(height: 28),
            Row(
              children: [
                const Text(
                  'Total à payer',
                  style: TextStyle(
                    color: KBeautyTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '${booking.totalAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: KBeautyTheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _paymentCard(BookingModel booking) => KBeautyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KBeautySectionTitle(
              title: 'Paiement par carte',
              subtitle:
                  'Vous serez redirigé vers Stripe. Vos données bancaires ne transitent pas par kBeauty.',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: KBeautyTheme.softDecoration(radius: 16),
              child: const Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: KBeautyTheme.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé Stripe',
                      style: TextStyle(
                        color: KBeautyTheme.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.lock_rounded, color: KBeautyTheme.success),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Annulation ou replanification possible jusqu’à 24 heures avant le rendez-vous. Après ce délai, le rendez-vous payé n’est plus annulable.',
              style: TextStyle(
                color: KBeautyTheme.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _manager.isSaving ? null : _pay,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Payer avec Stripe'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _manager.isVerifying ? null : _verify,
                icon: _manager.isVerifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_outlined),
                label: const Text('J’ai payé, vérifier mon paiement'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _manager.isSaving ? null : _cancel,
                child: const Text('Annuler cette réservation non payée'),
              ),
            ),
          ],
        ),
      );

  Widget _line(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: KBeautyTheme.primary, size: 18),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label.isEmpty ? '-' : label,
                style: const TextStyle(
                  color: KBeautyTheme.muted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _pay() async {
    final checkout = await _manager.createStripeCheckout(widget.bookingId);
    if (checkout == null || !mounted) return;
    final uri = Uri.tryParse(checkout.checkoutUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _toast('Impossible d’ouvrir Stripe.');
    }
  }

  Future<void> _verify() async {
    final paid = await _manager.verifyPayment(widget.bookingId);
    if (!mounted) return;
    if (paid) {
      _toast('Paiement confirmé. Votre rendez-vous est créé.');
      context.go('/appointments');
    } else {
      _toast(_manager.lastError ?? 'Paiement toujours en attente.');
    }
  }

  Future<void> _cancel() async {
    final ok = await _manager.cancelUnpaidBooking(widget.bookingId);
    if (ok && mounted) context.go('/');
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} à ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
