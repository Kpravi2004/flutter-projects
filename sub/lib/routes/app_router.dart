import 'package:go_router/go_router.dart';

import '../core/widgets/bottom_nav_bar.dart';

import '../features/auth/screens/login_page.dart';
import '../features/auth/screens/register_page.dart';

import '../features/services/models/service_model.dart';
import '../features/services/screens/service_list_page.dart';
import '../features/services/screens/service_details_page.dart';

import '../features/booking/screens/select_worker_page.dart';
import '../features/booking/screens/booking_summary_page.dart';
import '../features/booking/screens/booking_confirmed_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/login",
    routes: [

      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: "/register",
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: "/home",
        builder: (context, state) => const BottomNavBar(),
      ),

      GoRoute(
        path: "/services/:category",
        builder: (context, state) {
          final category = state.pathParameters["category"]!;
          return ServiceListPage(category: category);
        },
      ),

      GoRoute(
        path: "/service-details",
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          return ServiceDetailsPage(service: service);
        },
      ),

      GoRoute(
        path: "/select-worker",
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          return SelectWorkerPage(service: service);
        },
      ),

      GoRoute(
        path: "/booking-summary",
        builder: (context, state) {
          final booking = state.extra as Map<String, dynamic>;
          return BookingSummaryPage(booking: booking);
        },
      ),

      GoRoute(
        path: "/booking-confirmed",
        builder: (context, state) {
          final booking = state.extra as Map<String, dynamic>;
          return BookingConfirmedPage(booking: booking);
        },
      ),
    ],
  );
}
