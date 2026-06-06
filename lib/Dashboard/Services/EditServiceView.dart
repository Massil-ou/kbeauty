import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyImageUpload.dart';
import '../../Shared/KBeautyTheme.dart';
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
  static const _durations = [30, 45, 60, 75, 90, 120, 150, 180];
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subcategory = TextEditingController();
  final _price = TextEditingController();
  String? _imageUrl;
  String? _category;
  int _duration = 60;
  bool _hydrated = false;
  bool _uploadingImage = false;
  late final _manager = widget.manager.serviceManager;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _manager.loadCategories();
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
    _imageUrl = service.images.isEmpty ? null : service.images.first;
    _category = service.category;
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
                  ? const KBeautySkeletonList(count: 1)
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
                            _imageUploader(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      KBeautyCard(
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                final categories = _categoryOptions();
                                if (_manager.isLoadingCategories &&
                                    categories.isEmpty) {
                                  return const KBeautySkeletonList(
                                    count: 1,
                                    compact: true,
                                  );
                                }
                                return DropdownButtonFormField<String>(
                                  initialValue: categories.contains(_category)
                                      ? _category
                                      : null,
                                  items: categories
                                      .map((item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ))
                                      .toList(),
                                  validator: (value) => value == null
                                      ? 'Choisissez une catégorie.'
                                      : null,
                                  onChanged: (value) =>
                                      setState(() => _category = value),
                                  decoration: const InputDecoration(
                                    labelText: 'Catégorie',
                                  ),
                                );
                              },
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

  Widget _imageUploader() {
    final imageUrl = _imageUrl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KBeautyTheme.primarySoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KBeautyTheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_outlined, color: KBeautyTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  imageUrl == null
                      ? 'Photo de la prestation'
                      : 'Photo de la prestation téléversée',
                  style: const TextStyle(
                    color: KBeautyTheme.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Text('Aperçu indisponible'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _uploadingImage ? null : _pickAndUploadImage,
              icon: _uploadingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(
                _uploadingImage
                    ? 'Téléversement...'
                    : imageUrl == null
                        ? 'Téléverser une photo'
                        : 'Changer la photo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    final category = _category;
    if (price == null || price <= 0 || category == null) return;
    final ok = await _manager.updateService(
      id: widget.serviceId,
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: category,
      subcategory: _subcategory.text.trim(),
      price: price,
      durationMinutes: _duration,
      images: _imageUrl == null ? [] : [_imageUrl!],
    );
    if (ok && mounted) context.go('/beautician/services');
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await pickKBeautyImage();
    if (picked == null) return;
    setState(() => _uploadingImage = true);
    final url = await _manager.uploadImage(
      bytes: picked.bytes,
      filename: picked.name,
      purpose: 'service',
    );
    if (!mounted) return;
    setState(() {
      _uploadingImage = false;
      if (url?.isNotEmpty == true) _imageUrl = url;
    });
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_manager.lastError ?? 'Téléversement impossible.')),
      );
    }
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Ce champ est requis.' : null;

  List<String> _categoryOptions() {
    final names = _manager.categories.map((item) => item.name).toList();
    final current = _category;
    if (current != null && current.isNotEmpty && !names.contains(current)) {
      return [current, ...names];
    }
    return names;
  }
}
