import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyTheme.dart';
import '../../Shared/KBeautyWidgets.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key, required this.manager});

  final Manager manager;

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subcategory = TextEditingController();
  final _price = TextEditingController();
  final _imageUrl = TextEditingController();
  String _category = 'Coiffure';
  int _duration = 60;

  static const categories = [
    'Coiffure',
    'Ongles',
    'Maquillage',
    'Massage',
    'Épilation',
  ];
  static const durations = [30, 45, 60, 75, 90, 120, 150, 180];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subcategory.dispose();
    _price.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.manager.serviceManager;
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) => KBeautyPage(
        manager: widget.manager,
        title: 'Publier une prestation',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'Nouvelle prestation',
                subtitle:
                    'Présentez clairement votre service pour aider les clientes à réserver.',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;
                  final main = _mainForm();
                  final details = _detailsForm();
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: main),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: details),
                          ],
                        )
                      : Column(
                          children: [main, const SizedBox(height: 16), details],
                        );
                },
              ),
              if (manager.lastError != null) ...[
                const SizedBox(height: 16),
                KBeautyErrorBanner(message: manager.lastError!),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: manager.isSaving ? null : _submit,
                  icon: manager.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.publish_outlined),
                  label: Text(
                    manager.isSaving
                        ? 'Publication en cours...'
                        : 'Publier la prestation',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainForm() {
    return KBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KBeautySectionTitle(title: 'Présentation'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _title,
            validator: _required,
            decoration: const InputDecoration(
              labelText: 'Titre de la prestation',
              prefixIcon: Icon(Icons.spa_outlined),
            ),
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: _description,
            validator: _required,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Description détaillée',
              hintText:
                  'Décrivez le déroulement, les produits et le résultat...',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: _imageUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL de la photo principale',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.image_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsForm() {
    return KBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KBeautySectionTitle(title: 'Tarif et catégorie'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: categories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                setState(() => _category = value ?? _category),
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: _subcategory,
            decoration: const InputDecoration(
              labelText: 'Sous-catégorie',
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final price =
                  double.tryParse((value ?? '').replaceAll(',', '.').trim());
              return price == null || price <= 0 ? 'Prix invalide.' : null;
            },
            decoration: const InputDecoration(
              labelText: 'Prix en euros',
              prefixIcon: Icon(Icons.euro_rounded),
            ),
          ),
          const SizedBox(height: 13),
          DropdownButtonFormField<int>(
            initialValue: _duration,
            items: durations
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text('$item minutes'),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _duration = value ?? _duration),
            decoration: const InputDecoration(
              labelText: 'Durée',
              prefixIcon: Icon(Icons.schedule_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const KBeautyStatusChip(
            label: 'Visible immédiatement après publication',
            color: KBeautyTheme.success,
            icon: Icons.visibility_outlined,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final image = _imageUrl.text.trim();
    final id = await widget.manager.serviceManager.createService(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      subcategory:
          _subcategory.text.trim().isEmpty ? null : _subcategory.text.trim(),
      price: double.parse(_price.text.replaceAll(',', '.').trim()),
      durationMinutes: _duration,
      images: image.isEmpty ? const [] : [image],
    );
    if (id == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Votre prestation est publiée.')),
    );
    context.go('/beautician/services');
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Ce champ est requis.' : null;
}
