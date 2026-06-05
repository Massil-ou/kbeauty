import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../App/Manager.dart';
import '../Shared/Models.dart';

class ServiceDetailView extends StatefulWidget {
  const ServiceDetailView({
    super.key,
    required this.manager,
    required this.serviceId,
  });
  final Manager manager;
  final String serviceId;

  @override
  State<ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<ServiceDetailView> {
  late final _serviceManager = widget.manager.serviceManager;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _serviceManager.getServiceDetail(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du service')),
      body: ListenableBuilder(
        listenable: _serviceManager,
        builder: (context, _) {
          if (_serviceManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_serviceManager.selectedService == null) {
            return Center(child: Text(_serviceManager.lastError ?? 'Service non trouvé'));
          }

          final service = _serviceManager.selectedService!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                if (service.images.isNotEmpty)
                  Stack(
                    children: [
                      PageView.builder(
                        onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                        itemCount: service.images.length,
                        itemBuilder: (_, idx) => Image.network(
                          service.images[idx],
                          fit: BoxFit.cover,
                          height: 300,
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            service.images.length,
                            (idx) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: idx == _currentImageIndex
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '€${service.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Duration
                      Text(
                        'Durée: ${service.durationMinutes} minutes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        service.description,
                        style: const TextStyle(height: 1.6),
                      ),

                      const SizedBox(height: 24),

                      // Beautician Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Beauticienne',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF7C3AED),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.beautician.fullName,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${service.beautician.rating.toStringAsFixed(1)} (${service.beautician.appointmentCount})',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (service.beautician.bio != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                service.beautician.bio!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reviews
                      if (service.images.isNotEmpty)
                        Text(
                          'Avis (${service.images.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pushNamed(
                              'time_slots',
                              pathParameters: {
                                'service_id': service.id,
                                'beautician_id': service.beautician.id,
                              },
                            );
                          },
                          child: const Text('Réserver un rendez-vous'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
