import 'package:flutter/material.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';

class ReviewFormView extends StatefulWidget {
  const ReviewFormView({
    super.key,
    required this.manager,
    required this.appointmentId,
  });

  final Manager manager;
  final String appointmentId;

  @override
  State<ReviewFormView> createState() => _ReviewFormViewState();
}

class _ReviewFormViewState extends State<ReviewFormView> {
  late final _reviewManager = widget.manager.reviewManager;
  final _comment = TextEditingController();
  int _rating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBeauticianReview = widget.manager.isBeauticianhRole;
    final title =
        isBeauticianReview ? 'Évaluer la cliente' : 'Évaluer la prestation';
    final heading = isBeauticianReview
        ? 'Comment s’est passé ce rendez-vous ?'
        : 'Comment s’est passée votre prestation ?';
    final subtitle = isBeauticianReview
        ? 'Votre retour aide à sécuriser la communauté et à garder des rendez-vous sérieux.'
        : 'Votre avis aide les autres clientes et valorise le travail de la professionnelle.';

    return KBeautyPage(
      manager: widget.manager,
      title: title,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: KBeautyCard(
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: KBeautyTheme.goldSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_outline_rounded,
                    color: KBeautyTheme.gold,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: KBeautyTheme.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: KBeautyTheme.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () => setState(() => _rating = index + 1),
                      iconSize: 42,
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: index < _rating
                            ? KBeautyTheme.gold
                            : KBeautyTheme.divider,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _comment,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Votre commentaire',
                    hintText: isBeauticianReview
                        ? 'Ponctualité, respect du rendez-vous, communication...'
                        : 'Partagez votre expérience...',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.rate_review_outlined),
                  ),
                ),
                if (_reviewManager.lastError != null) ...[
                  const SizedBox(height: 14),
                  KBeautyErrorBanner(message: _reviewManager.lastError!),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting || _rating == 0 ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: const Text('Publier mon avis'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await _reviewManager.submitReview(
      widget.appointmentId,
      _rating,
      _comment.text.trim().isEmpty ? null : _comment.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (_reviewManager.lastError != null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Merci pour votre évaluation.')),
    );
    Navigator.pop(context);
  }
}
