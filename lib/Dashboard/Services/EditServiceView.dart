import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyWidgets.dart';
import '../../Shared/Models.dart';

class EditServiceView extends StatefulWidget {
  const EditServiceView({
    super.key,
    required this.manager,
    required this.serviceId,
  });

  final Manager manager;
  final String serviceId;

  @override
  State<EditServiceView> createState() => _EditServiceViewState();
}

class _EditServiceViewState extends State<EditServiceView> {
  static const _categories = [
    'Coiffure',
    'Ongles',
    'Maquillage',
    'Massage',
    'Épilation',
  ];
  static const _durations = [30, 45, 60, 75, 90, 120, 150, 180];
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subcategory = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController();
  String _category = _categories.first;
  int _duration = 60;
  bool _hydrated = false;
  late final _manager = widget.manager.serviceManager;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_manager.ownServices.isEmpty) await _manager.listMine();
    if (mounted) setState(_hydrate);
  }

  ServiceModel? get _service {
    for (final service in _manager.ownServices) {
      if (service.id == widget.serviceId) return service;
    }
    return null;
  }

  void _hydrate() {
    final service = _service;
    if (_hydrated || service == null) return;
    _title.text = service.title;
    _description.text = service.description;
    _subcategory.text = service.subcategory ?? '';
    _price.text = service.price.toStringAsFixed(2);
    _image.text = service.images.isEmpty ? '' : service.images.first;
    _category = _categories.contains(service.category)
        ? service.category
        : _categories.first;
    _duration = _durations.contains(service.durationMinutes)
        ? service.durationMinutes
        : 60;
    _hydrated = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subcategory.dispose();
    _price.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) {
        _hydrate();
        final service = _service;
        return KBeautyPage(
          manager: widget.manager,
          title: 'Modifier la prestation',
          child: service == null
              ? _manager.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const KBeautyEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Prestation introuvable',
                      message:
                          'Cette prestation ne fait pas partie de votre compte.',
                    )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const KBeautySectionTitle(
                        title: 'Modifier la prestation',
                        subtitle:
                            'Les changements seront visibles immédiatement.',
                      ),
                      const SizedBox(height: 18),
                      KBeautyCard(
                        child: Column(
                          children: [
                            _field(_title, 'Titre'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _description,
                              minLines: 5,
                              maxLines: 8,
                              validator: _required,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _field(_image, 'URL de la photo', required: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      KBeautyCard(
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              items: _categories
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => _category = value ?? _category),
                              decoration:
                                  const InputDecoration(labelText: 'Catégorie'),
                            ),
                            const SizedBox(height: 12),
                            _field(_subcategory, 'Sous-catégorie',
                                required: false),
                            const SizedBox(height: 12),
                            _field(
                              _price,
                              'Prix en euros',
                              keyboard: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              initialValue: _duration,
                              items: _durations
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text('$item minutes'),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => _duration = value ?? _duration),
                              decoration:
                                  const InputDecoration(labelText: 'Durée'),
                            ),
                          ],
                        ),
                      ),
                      if (_manager.lastError != null) ...[
                        const SizedBox(height: 14),
                        KBeautyErrorBanner(message: _manager.lastError!),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _manager.isSaving ? null : _save,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Enregistrer les modifications'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboard,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: required ? _required : null,
        decoration: InputDecoration(labelText: label),
      );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    if (price == null || price <= 0) return;
    final image = _image.text.trim();
    final ok = await _manager.updateService(
      id: widget.serviceId,
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      subcategory: _subcategory.text.trim(),
      price: price,
      durationMinutes: _duration,
      images: image.isEmpty ? [] : [image],
    );
    if (ok && mounted) context.go('/beautician/services');
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Ce champ est requis.' : null;
}
