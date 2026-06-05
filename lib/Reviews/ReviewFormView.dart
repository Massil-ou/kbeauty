import 'package:flutter/material.dart';
import '../App/Manager.dart';

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
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Évaluer le service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Section
            const Text(
              'Comment trouvez-vous ce service?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (idx) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = idx + 1),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.star,
                        size: 48,
                        color: idx < _rating ? Colors.amber : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Comment Section
            const Text(
              'Commentaire (optionnel)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting || _rating == 0
                    ? null
                    : () async {
                        setState(() => _isSubmitting = true);
                        await _reviewManager.submitReview(
                          widget.appointmentId,
                          _rating,
                          _commentCtrl.text.isEmpty ? null : _commentCtrl.text,
                        );
                        if (!mounted) return;
                        setState(() => _isSubmitting = false);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Merci pour votre évaluation!'),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Soumettre l\'évaluation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }
}
