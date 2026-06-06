import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
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
  final _nif = TextEditingController();
  final _nis = TextEditingController();
  final _taxRegime = TextEditingController();
  final _vat = TextEditingController();
  final _bio = TextEditingController();
  final _specializations = TextEditingController();
  final _experience = TextEditingController(text: '0');
  final _professionalPhone = TextEditingController();
  final _profileImageUrl = TextEditingController();
  final _serviceCities = TextEditingController();
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
      _nif.text = p['nif_number']?.toString() ?? '';
      _nis.text = p['nis_number']?.toString() ?? '';
      _taxRegime.text = p['tax_regime']?.toString() ?? '';
      _vat.text = p['vat_number']?.toString() ?? '';
      _hydratedPro = true;
    }
    if (!_hydratedBeauty && _beauty.profile != null) {
      final p = _beauty.profile!;
      _bio.text = p.bio ?? '';
      _specializations.text = p.specializations.join(', ');
      _experience.text = p.experienceYears.toString();
      _professionalPhone.text = p.phone ?? widget.manager.currentUserPhone;
      _profileImageUrl.text = p.profileImageUrl ?? '';
      _serviceCities.text = p.serviceCities.join(', ');
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
      _nif,
      _nis,
      _taxRegime,
      _vat,
      _bio,
      _specializations,
      _experience,
      _professionalPhone,
      _profileImageUrl,
      _serviceCities,
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
              _proGuide(),
              const SizedBox(height: 18),
              KBeautySectionTitle(
                title: _account.proProfile == null
                    ? 'Devenir professionnelle'
                    : 'Mon dossier professionnel',
                subtitle: _account.proProfile == null
                    ? 'Envoyez votre dossier. Un administrateur validera ensuite votre accès.'
                    : 'Statut du dossier : ${_account.proStatus.isEmpty ? 'en attente' : _account.proStatus}.',
              ),
              if (_account.hasProProfile) ...[
                const SizedBox(height: 16),
                _proStatusBanner(),
              ],
              const SizedBox(height: 18),
              _field(
                _company,
                'Nom de l’entreprise',
                Icons.business_outlined,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _trade,
                'Nom commercial',
                Icons.storefront_outlined,
                required: false,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _companyType,
                'Forme juridique',
                Icons.account_balance_outlined,
                required: false,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _siret,
                'SIRET / identifiant',
                Icons.numbers_outlined,
                required: false,
                keyboard: TextInputType.number,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _rc,
                'Registre de commerce',
                Icons.description_outlined,
                required: false,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _nif,
                'Numéro fiscal',
                Icons.receipt_long_outlined,
                required: false,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _nis,
                'Numéro statistique',
                Icons.analytics_outlined,
                required: false,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _taxRegime,
                'Régime fiscal',
                Icons.account_balance_wallet_outlined,
                required: false,
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 12),
              _field(
                _vat,
                'TVA en pourcentage',
                Icons.percent_rounded,
                required: false,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                enabled: _account.canEditProProfile,
              ),
              const SizedBox(height: 18),
              if (_account.canEditProProfile)
                _saveButton(
                  loading: _account.isSaving,
                  label: _account.proProfile == null
                      ? 'Envoyer ma demande pro'
                      : _account.isProRejected
                          ? 'Corriger et renvoyer ma demande'
                          : 'Mettre à jour mon dossier',
                  onPressed: _savePro,
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _account.isLoading ? null : _refreshProStatus,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Actualiser le statut'),
                  ),
                ),
              if (_account.isProApproved &&
                  widget.manager.isBeauticianhRole) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/beautician/dashboard'),
                    icon: const Icon(Icons.space_dashboard_outlined),
                    label: const Text('Ouvrir mon espace partenaire'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _proGuide() {
    final status = _account.isProApproved
        ? 'Validé'
        : _account.isProRejected
            ? 'À corriger'
            : _account.isProPending
                ? 'En validation'
                : 'À démarrer';
    final color = _account.isProApproved
        ? KBeautyTheme.success
        : _account.isProRejected
            ? KBeautyTheme.danger
            : _account.isProPending
                ? KBeautyTheme.gold
                : KBeautyTheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KBeautyTheme.primarySoft.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KBeautyTheme.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: KBeautyTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comment devenir pro ?',
                      style: TextStyle(
                        color: KBeautyTheme.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Le parcours est simple et validé par l’administration.',
                      style: TextStyle(
                        color: KBeautyTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              KBeautyStatusChip(label: status, color: color),
            ],
          ),
          const SizedBox(height: 16),
          const _ProStep(
            number: '1',
            title: 'Remplir le dossier',
            text: 'Entreprise, nom commercial et informations légales.',
          ),
          _ProStep(
            number: '2',
            title: 'Validation admin',
            text: _account.isProPending
                ? 'Votre dossier est envoyé. Attendez la validation.'
                : 'Un administrateur vérifie votre demande.',
          ),
          _ProStep(
            number: '3',
            title: 'Publier vos prestations',
            text: _account.isProApproved
                ? 'Votre espace partner est actif.'
                : 'Après validation, le menu partner sera débloqué.',
            isLast: true,
          ),
        ],
      ),
    );
  }

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
              const SizedBox(height: 12),
              _field(
                _professionalPhone,
                'Téléphone professionnel',
                Icons.phone_outlined,
                required: false,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _field(
                _profileImageUrl,
                'URL de la photo de profil',
                Icons.image_outlined,
                required: false,
                keyboard: TextInputType.url,
              ),
              const SizedBox(height: 12),
              _field(
                _serviceCities,
                'Villes d’intervention séparées par des virgules',
                Icons.location_city_outlined,
              ),
              const SizedBox(height: 8),
              const Text(
                'Exemple : Paris, Boulogne-Billancourt. Les clientes ne pourront réserver que dans ces villes.',
                style: TextStyle(
                  color: KBeautyTheme.muted,
                  fontSize: 12,
                  height: 1.35,
                ),
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
    bool enabled = true,
  }) =>
      TextFormField(
        controller: controller,
        enabled: enabled,
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
      'nif_number': _nif.text.trim(),
      'nis_number': _nis.text.trim(),
      'tax_regime': _taxRegime.text.trim(),
      'vat_number': _vat.text.trim(),
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
      phone: _professionalPhone.text.trim(),
      profileImageUrl: _profileImageUrl.text.trim(),
      serviceCities: _serviceCities.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
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

  Future<void> _refreshProStatus() async {
    await _account.loadProProfile();
    if (!mounted) return;
    if (widget.manager.isBeauticianhRole) {
      await _beauty.getProfile();
      if (mounted) setState(() => _section = 'beauty');
    }
  }

  Widget _proStatusBanner() {
    final color = _account.isProApproved
        ? KBeautyTheme.success
        : _account.isProRejected
            ? KBeautyTheme.danger
            : KBeautyTheme.gold;
    final icon = _account.isProApproved
        ? Icons.verified_rounded
        : _account.isProRejected
            ? Icons.cancel_outlined
            : Icons.hourglass_top_rounded;
    final title = _account.isProApproved
        ? 'Dossier validé'
        : _account.isProRejected
            ? 'Dossier refusé'
            : 'Validation en cours';
    final message = _account.isProApproved
        ? 'Votre compte partenaire est actif. Vous pouvez gérer votre profil et publier vos prestations.'
        : _account.isProRejected
            ? 'Corrigez les informations du dossier puis envoyez une nouvelle demande.'
            : 'Un administrateur examine votre demande. Les informations sont verrouillées pendant cette étape.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(message,
                    style: const TextStyle(
                        color: KBeautyTheme.muted, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProStep extends StatelessWidget {
  const _ProStep({
    required this.number,
    required this.title,
    required this.text,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: KBeautyTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: KBeautyTheme.primary.withValues(alpha: 0.16),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: KBeautyTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: KBeautyTheme.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
