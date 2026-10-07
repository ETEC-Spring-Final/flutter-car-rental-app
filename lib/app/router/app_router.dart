import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_rental_system/app/router/router_names.dart';
import 'package:vehicle_rental_system/feature/auth/presentation/view/login_screen.dart';
import 'package:vehicle_rental_system/feature/auth/presentation/view/register_screen.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/booking.dart';
import 'package:vehicle_rental_system/feature/notification/presentation/view/notification_screen.dart';

import '../../feature/home/presentation/view/main_screen.dart';
import '../../feature/onboarding/presentation/view/onboarding_screen.dart';
import '../../feature/onboarding/presentation/view/splash_screen.dart';
import '../../feature/profile/presentation/view/profile_screen.dart';
import '../../feature/rental/presentation/view/booking_screen.dart';
import '../../feature/vehicle/presentation/view/explore_screen.dart';
import '../../feature/vehicle/presentation/view/favorite_screen.dart';
import '../../feature/vehicle/presentation/view/vehicle_detail_screen.dart';
import '../../feature/payment/presentation/view/payment_screen.dart';
import '../../feature/vehicle/presentation/view/vehicle_crud_screen.dart';
import '../router/app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    // ============================================================
    // INITIAL ROUTE
    // ============================================================
    initialLocation: AppRoutes.splash,

    routes: [
      // ============================================================
      // SPLASH
      // ============================================================
      GoRoute(
        path: AppRoutes.splash,
        name: RouterNames.splash,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      // ============================================================
      // ONBOARDING
      // ============================================================
      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: RouterNames.onboarding,
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,

            child: const OnboardingScreen(),

            transitionDuration: const Duration(milliseconds: 700),
            reverseTransitionDuration: const Duration(milliseconds: 500),

            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  // Fade
                  final fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(curvedAnimation);

                  // Slide
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(curvedAnimation);

                  // Scale
                  final scaleAnimation = Tween<double>(
                    begin: 0.96,
                    end: 1.0,
                  ).animate(curvedAnimation);

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
          );
        },
      ),

      // ============================================================
      // login
      // ============================================================
      GoRoute(
        path: AppRoutes.login,
        name: RouterNames.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      // ============================================================
      // signup
      // ============================================================
      GoRoute(
        path: AppRoutes.register,
        name: RouterNames.register,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      // ============================================================
      // MAIN HOME
      // ============================================================
      GoRoute(
        path: AppRoutes.mainHome,
        name: RouterNames.main,
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,

            child: const MainScreen(index: 0),

            transitionDuration: const Duration(milliseconds: 700),

            reverseTransitionDuration: const Duration(milliseconds: 500),

            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // ----------------------------------------------------
                  // CURVE
                  // ----------------------------------------------------

                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  // ----------------------------------------------------
                  // FADE
                  // ----------------------------------------------------

                  final fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(curvedAnimation);

                  // ----------------------------------------------------
                  // SLIDE
                  // ----------------------------------------------------

                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(curvedAnimation);

                  // ----------------------------------------------------
                  // SCALE
                  // ----------------------------------------------------

                  final scaleAnimation = Tween<double>(
                    begin: 0.96,
                    end: 1.0,
                  ).animate(curvedAnimation);

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
          );
        },
      ),

      // ============================================================
      // HOME
      // ============================================================
      GoRoute(
        path: AppRoutes.home,
        name: RouterNames.home,
        builder: (context, state) {
          // `state.extra` may carry the initial tab index (e.g. 2 = Booking).
          final index = state.extra is int ? state.extra as int : 0;

          return MainScreen(index: index);
        },
      ),

      // ============================================================
      // NOTIFICATION
      // ============================================================
      GoRoute(
        path: AppRoutes.notification,
        name: RouterNames.notification,
        builder: (context, state) {
          return const NotificationScreen();
        },
      ),

      // ============================================================
      // EXPLORE
      // ============================================================
      GoRoute(
        path: AppRoutes.explore,
        name: RouterNames.explore,
        builder: (context, state) {
          return const ExploreScreen();
        },
      ),

      // ============================================================
      // BOOKING
      // ============================================================
      GoRoute(
        path: AppRoutes.booking,
        name: RouterNames.booking,
        builder: (context, state) {
          return const BookingScreen();
        },
      ),

      // ============================================================
      // FAVORITE
      // ============================================================
      GoRoute(
        path: AppRoutes.favorite,
        name: RouterNames.favorite,
        builder: (context, state) {
          return const FavoriteScreen();
        },
      ),

      // ============================================================
      // PROFILE
      // ============================================================
      GoRoute(
        path: AppRoutes.profile,
        name: RouterNames.profile,
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),

      // ============================================================
      // VEHICLE DETAIL
      // ============================================================
      GoRoute(
        path: '${AppRoutes.detail}/:id',
        name: RouterNames.detail,
        builder: (context, state) {
          final vehicle = state.extra;

          return VehicleDetailScreen(vehicle: vehicle as dynamic);
        },
      ),

      // ============================================================
      // PAYMENT
      // ============================================================
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final booking = state.extra is Booking
              ? state.extra as Booking
              : null;

          if (booking == null) {
            return const Scaffold(
              body: Center(child: Text('Booking information not found')),
            );
          }

          return PaymentScreen(
            booking: booking,
            bookingRequest: null,
            vehicle: booking.vehicle,
            rentalDays: booking.totalDays,
            pickupDate: booking.startDate,
            returnDate: booking.endDate,
            pickupLocation: booking.pickupLocation,
            returnLocation: booking.returnLocation,
            selectedServices: const {},
            paymentMethod: 'KHQR',
            totalPrice: booking.totalPrice,
          );
        },
      ),

      // ============================================================
      // VEHICLE CRUD (dev/test tool)
      // ============================================================
      GoRoute(
        path: AppRoutes.vehicleCrud,
        name: RouterNames.vehicleCrud,
        builder: (context, state) {
          return const VehicleCrudScreen();
        },
      ),
    ],
  );
}
