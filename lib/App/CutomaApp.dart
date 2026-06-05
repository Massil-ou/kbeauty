import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Auth/LoginView.dart';
import '../Auth/SignupView.dart';
import '../Account/AccountDashboardView.dart';
import '../Account/ProfileView.dart';
import '../Admin/AdminDashboardView.dart';
import '../Booking/ConfirmBookingView.dart';
import '../Booking/TimeSlotPickerView.dart';
import '../Dashboard/Appointments/BeauticianhDashboardView.dart';
import '../Dashboard/Appointments/MyAppointmentsView.dart';
import '../Dashboard/Services/ServiceDetailView.dart';
import '../Dashboard/Services/AddServiceView.dart';
import '../Dashboard/Services/EditServiceView.dart';
import '../Dashboard/Services/MyServicesView.dart';
import '../Offre/OffreView.dart';
import '../Reviews/ReviewFormView.dart';
import '../Shared/KBeautyTheme.dart';
import 'Manager.dart';

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
    refreshListenable: widget.manager,
    errorBuilder: (context, state) => OffreView(manager: widget.manager),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authenticated = widget.manager.isAuthenticated;
      final authRoute = location == '/login' || location == '/signup';
      final protected = location == '/appointments' ||
          location == '/booking/confirm' ||
          location.startsWith('/account/') ||
          location == '/admin' ||
          location.startsWith('/reviews/') ||
          location.startsWith('/beautician/');

      if (!authenticated && protected) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (authenticated && authRoute) return '/';
      if (location.startsWith('/beautician/') &&
          !widget.manager.isBeauticianhRole) {
        return '/appointments';
      }
      if (location == '/admin' && !widget.manager.isAdminRole) {
        return '/account/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => OffreView(manager: widget.manager),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginView(manager: widget.manager),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => SignupView(manager: widget.manager),
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
        path: '/account/dashboard',
        name: 'account_dashboard',
        builder: (context, state) =>
            AccountDashboardView(manager: widget.manager),
      ),
      GoRoute(
        path: '/account/profile',
        name: 'account_profile',
        builder: (context, state) => ProfileView(
          manager: widget.manager,
          initialSection: state.uri.queryParameters['section'] ?? 'personal',
        ),
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
        path: '/beautician/services',
        name: 'my_services',
        builder: (context, state) => MyServicesView(manager: widget.manager),
      ),
      GoRoute(
        path: '/beautician/services/new',
        name: 'create_service',
        builder: (context, state) => AddServiceView(manager: widget.manager),
      ),
      GoRoute(
        path: '/beautician/services/:id/edit',
        name: 'edit_service',
        builder: (context, state) => EditServiceView(
          manager: widget.manager,
          serviceId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) =>
            AdminDashboardView(manager: widget.manager),
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
      theme: KBeautyTheme.theme(),
    );
  }
}
