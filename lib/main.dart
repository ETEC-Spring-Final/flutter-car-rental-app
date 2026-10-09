import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_rental_system/app/app.dart';
import 'package:vehicle_rental_system/app/locale/bloc/locale_bloc.dart';
import 'package:vehicle_rental_system/app/theme/bloc/theme_bloc.dart';
import 'package:vehicle_rental_system/core/service/firebase/notification_service.dart';
import 'package:vehicle_rental_system/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:vehicle_rental_system/feature/booking/presentation/bloc/booking_bloc.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';
import 'package:vehicle_rental_system/feature/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:vehicle_rental_system/feature/notification/presentation/bloc/notification_bloc.dart';
import 'package:vehicle_rental_system/feature/payment/presentation/bloc/payment_bloc.dart';
import 'package:vehicle_rental_system/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/bloc/rental_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:vehicle_rental_system/core/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // notification service
  await NotificationService.instance.initialize();

  await configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<FavoriteBloc>(create: (_) => sl<FavoriteBloc>()),
        BlocProvider<BookingBloc>(create: (_) => sl<BookingBloc>()),
        BlocProvider<VehicleBloc>(create: (_) => sl<VehicleBloc>()),
        BlocProvider<BrandBloc>(create: (_) => sl<BrandBloc>()),
        BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<RentalBloc>(create: (_) => sl<RentalBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()),
      ],
      child: const CarRentalApp(),
    ),
  );
}
