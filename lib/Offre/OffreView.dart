import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../App/Manager.dart';
import '../Shared/Models.dart';

class OffreView extends StatefulWidget {
  const OffreView({super.key, required this.manager});
  final Manager manager;

  @override
  State<OffreView> createState() => _OffreViewState();
}

class _OffreViewState extends State<OffreView> {
  late final _serviceManager = widget.manager.serviceManager;
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  final categories = [
    'Coiffure',
    'Ongles',
    'Maquillage',
    'Massage',
    'Épilation',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    _serviceManager.searchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('kBeauty')),
      body: ListenableBuilder(
        listenable: _serviceManager,
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF7C3AED),
                child: Column(
                  children: [
                    const Text(
                      'Trouvez une beauticienne près de vous',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => _performSearch(),
                      decoration: InputDecoration(
                        hintText: 'Chercher un service...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        onSelected: (selected) {
                          setState(
                              () => _selectedCategory = selected ? cat : null);
                          _performSearch();
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: const Color(0xFF7C3AED),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Services List
              if (_serviceManager.isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ))
              else if (_serviceManager.services.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                        _serviceManager.lastError ?? 'Aucun service trouvé'),
                  ),
                )
              else
                Column(
                  children: _serviceManager.services.map((service) {
                    return _ServiceCard(
                      service: service,
                      onTap: () {
                        context.pushNamed('service_detail', pathParameters: {
                          'id': service.id,
                        });
                      },
                    );
                  }).toList(),
                ),

              if (_serviceManager.hasMore)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _serviceManager.loadMore(),
                    child: const Text('Charger plus'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    _serviceManager.searchServices(
      query: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      category: _selectedCategory,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: service.images.isNotEmpty
                  ? Image.network(
                      service.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    service.beautician.fullName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${service.durationMinutes} min',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
