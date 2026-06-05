import 'package:flutter/material.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyWidgets.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.manager,
    this.initialSection = 'personal',
  });

  final Manager manager;
  final String initialSection;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _personalKey = GlobalKey<FormState>();
  final _proKey = GlobalKey<FormState>();
  final _beautyKey = GlobalKey<FormState>();
  late final _account = widget.manager.accountManager;
  late final _beauty = widget.manager.beauticianhProfileManager;
  late String _section = widget.initialSection;

  late final _firstName = TextEditingController(
    text: widget.manager.currentUserName.split(' ').firstOrNull ?? '',
  );
  late final _lastName = TextEditingController(
    text: widget.manager.currentUserName.split(' ').skip(1).join(' '),
  );
  late final _phone =
      TextEditingController(text: widget.manager.currentUserPhone);
  final _company = TextEditingController();
  final _trade = TextEditingController();
  final _companyType = TextEditingController();
  final _siret = TextEditingController();
  final _rc = TextEditingController();
  final _bio = TextEditingController();
  final _specializations = TextEditingController();
  final _experience = TextEditingController(text: '0');
  bool _hydratedPro = false;
  bool _hydratedBeauty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _account.loadProProfile();
    if (widget.manager.isBeauticianhRole) await _beauty.getProfile();
    if (mounted) setState(_hydrate);
  }

  void _hydrate() {
    if (!_hydratedPro && _account.proProfile != null) {
      final p = _account.proProfile!;
      _company.text = p['company_name']?.toString() ?? '';
      _trade.text = p['trade_name']?.toString() ?? '';
      _companyType.text = p['company_type']?.toString() ?? '';
      _siret.text = p['siret']?.toString() ?? '';
      _rc.text = p['rc_number']?.toString() ?? '';
      _hydratedPro = true;
    }
    if (!_hydratedBeauty && _beauty.profile != null) {
      final p = _beauty.profile!;
      _bio.text = p.bio ?? '';
      _specializations.text = p.specializations.join(', ');
      _experience.text = p.experienceYears.toString();
      _hydratedBeauty = true;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _phone,
      _company,
      _trade,
      _companyType,
      _siret,
      _rc,
      _bio,
      _specializations,
      _experience,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_account, _beauty]),
      builder: (context, _) {
        final sections = <({String id, String label, IconData icon})>[
          (id: 'personal', label: 'Profil', icon: Icons.person_outline),
          (
            id: 'pro',
            label: 'Compte pro',
            icon: Icons.workspace_premium_outlined
          ),
          if (widget.manager.isBeauticianhRole)
            (id: 'beauty', label: 'Profil beauté', icon: Icons.spa_outlined),
        ];
        if (!sections.any((item) => item.id == _section)) {
          _section = 'personal';
        }
        return KBeautyPage(
          manager: widget.manager,
          title: 'Mon profil',
          child: Column(
            children: [
              _sectionPicker(sections),
              const SizedBox(height: 18),
              if (_account.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: KBeautyErrorBanner(message: _account.lastError!),
                ),
              if (_section == 'personal') _personalForm(),
              if (_section == 'pro') _proForm(),
              if (_section == 'beauty') _beautyForm(),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionPicker(
      List<({String id, String label, IconData icon})> items) {
    return KBeautyCard(
      padding: const EdgeInsets.all(6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map(
              (item) => ChoiceChip(
                selected: _section == item.id,
                onSelected: (_) => setState(() => _section = item.id),
                avatar: Icon(item.icon, size: 17),
                label: Text(item.label),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _personalForm() => Form(
        key: _personalKey,
        child: KBeautyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'Informations personnelles',
                subtitle:
                    'Ces informations sont utilisées pour vos réservations.',
              ),
              const SizedBox(height: 18),
              _field(_firstName, 'Prénom', Icons.person_outline),
              const SizedBox(height: 12),
              _field(_lastName, 'Nom', Icons.badge_outlined),
              const SizedBox(height: 12),
              _field(
                _phone,
                'Téléphone',
                Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: widget.manager.currentUserEmail,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 18),
              _saveButton(
                loading: _account.isSaving,
                label: 'Enregistrer mon profil',
                onPressed: _savePersonal,
              ),
            ],
          ),
        ),
      );

  Widget _proForm() => Form(
        key: _proKey,
        child: KBeautyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KBeautySectionTitle(
                title: _account.proProfile == null
                    ? 'Devenir professionnelle'
                    : 'Mon dossier professionnel',
                subtitle: _account.proProfile == null
                    ? 'Envoyez votre dossier. Un administrateur validera ensuite votre accès.'
                    : 'Statut du dossier : ${_account.proStatus.isEmpty ? 'en attente' : _account.proStatus}.',
              ),
              const SizedBox(height: 18),
              _field(_company, 'Nom de l’entreprise', Icons.business_outlined),
              const SizedBox(height: 12),
              _field(_trade, 'Nom commercial', Icons.storefront_outlined,
                  required: false),
              const SizedBox(height: 12),
              _field(_companyType, 'Forme juridique',
                  Icons.account_balance_outlined,
                  required: false),
              const SizedBox(height: 12),
              _field(_siret, 'SIRET / identifiant', Icons.numbers_outlined,
                  required: false),
              const SizedBox(height: 12),
              _field(_rc, 'Registre de commerce', Icons.description_outlined,
                  required: false),
              const SizedBox(height: 18),
              _saveButton(
                loading: _account.isSaving,
                label: _account.proProfile == null
                    ? 'Envoyer ma demande pro'
                    : 'Mettre à jour mon dossier',
                onPressed: _savePro,
              ),
            ],
          ),
        ),
      );

  Widget _beautyForm() => Form(
        key: _beautyKey,
        child: KBeautyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'Présentation professionnelle',
                subtitle: 'Ces informations sont visibles par les clientes.',
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _bio,
                minLines: 4,
                maxLines: 7,
                validator: _required,
                decoration: const InputDecoration(
                  labelText: 'Biographie',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              _field(
                _specializations,
                'Spécialités séparées par des virgules',
                Icons.auto_awesome_outlined,
              ),
              const SizedBox(height: 12),
              _field(
                _experience,
                'Années d’expérience',
                Icons.history_edu_outlined,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 18),
              _saveButton(
                loading: _beauty.isSaving,
                label: 'Enregistrer mon profil beauté',
                onPressed: _saveBeauty,
              ),
            ],
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
    TextInputType? keyboard,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: required ? _required : null,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      );

  Widget _saveButton({
    required bool loading,
    required String label,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: loading
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(label),
        ),
      );

  Future<void> _savePersonal() async {
    if (!(_personalKey.currentState?.validate() ?? false)) return;
    final ok = await _account.updatePersonalProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
    );
    _toast(ok ? 'Profil mis à jour.' : _account.lastError ?? 'Erreur.');
  }

  Future<void> _savePro() async {
    if (!(_proKey.currentState?.validate() ?? false)) return;
    final ok = await _account.saveProProfile({
      'company_name': _company.text.trim(),
      'trade_name': _trade.text.trim(),
      'company_type': _companyType.text.trim(),
      'siret': _siret.text.trim(),
      'rc_number': _rc.text.trim(),
    });
    _toast(ok
        ? 'Dossier professionnel enregistré.'
        : _account.lastError ?? 'Erreur.');
  }

  Future<void> _saveBeauty() async {
    if (!(_beautyKey.currentState?.validate() ?? false)) return;
    final ok = await _beauty.updateProfile(
      bio: _bio.text.trim(),
      specializations: _specializations.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
    );
    _toast(ok ? 'Profil beauté enregistré.' : _beauty.lastError ?? 'Erreur.');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Ce champ est requis.' : null;
}
