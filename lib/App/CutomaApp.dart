import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Manager.dart';
import '../Offre/OffreView.dart';
import '../Dashboard/Services/ServiceDetailView.dart';
import '../Booking/TimeSlotPickerView.dart';
import '../Booking/ConfirmBookingView.dart';
import '../Dashboard/Appointments/MyAppointmentsView.dart';
import '../Dashboard/Appointments/BeauticianhDashboardView.dart';
import '../Reviews/ReviewFormView.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class KBeautyApp extends StatefulWidget {
  const KBeautyApp({super.key, required this.manager});
  final Manager manager;

  @override
  State<KBeautyApp> createState() => _KBeautyAppState();
}

class _KBeautyAppState extends State<KBeautyApp> {
  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: false,
    observers: [routeObserver],
    errorBuilder: (context, state) => OffreView(manager: widget.manager),
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => OffreView(manager: widget.manager),
      ),
      GoRoute(
        path: '/services/:id',
        name: 'service_detail',
        builder: (context, state) => ServiceDetailView(
          manager: widget.manager,
          serviceId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/booking/slots/:service_id/:beautician_id',
        name: 'time_slots',
        builder: (context, state) => TimeSlotPickerView(
          manager: widget.manager,
          serviceId: state.pathParameters['service_id'] ?? '',
          beauticianhId: state.pathParameters['beautician_id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/booking/confirm',
        name: 'confirm_booking',
        builder: (context, state) =>
            ConfirmBookingView(manager: widget.manager),
      ),
      GoRoute(
        path: '/appointments',
        name: 'my_appointments',
        builder: (context, state) =>
            MyAppointmentsView(manager: widget.manager),
      ),
      GoRoute(
        path: '/beautician/dashboard',
        name: 'beautician_dashboard',
        builder: (context, state) =>
            BeauticianhDashboardView(manager: widget.manager),
      ),
      GoRoute(
        path: '/reviews/:appointment_id',
        name: 'write_review',
        builder: (context, state) => ReviewFormView(
          manager: widget.manager,
          appointmentId: state.pathParameters['appointment_id'] ?? '',
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'kBeauty',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF7C3AED), // Purple
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFF06B6D4), // Cyan
          surface: Colors.white,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F2937),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ),
    );
  }
}
