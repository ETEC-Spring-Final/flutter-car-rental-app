import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:vehicle_rental_system/core/constants/storage_keys.dart';
import 'package:vehicle_rental_system/core/errors/app_exception.dart';
import 'package:vehicle_rental_system/core/service/firebase/notification_service.dart';

import 'package:vehicle_rental_system/feature/auth/domain/entity/forgot_password_request.dart';
import 'package:vehicle_rental_system/feature/auth/domain/entity/login_request.dart';
import 'package:vehicle_rental_system/feature/auth/domain/entity/register_request.dart';
import 'package:vehicle_rental_system/feature/auth/domain/entity/reset_password_request.dart';

import 'package:vehicle_rental_system/feature/auth/domain/service/oauth2_service.dart';

import 'package:vehicle_rental_system/feature/auth/domain/usecase/forgot_password_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/login_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/register_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/reset_password_use_case.dart';

import 'package:vehicle_rental_system/feature/notification/data/model/device_register_request.dart';
import 'package:vehicle_rental_system/feature/notification/domain/usecase/register_device_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  // NEW
  final RegisterDeviceUseCase registerDeviceUseCase;

  final FlutterSecureStorage secureStorage;
  final OAuth2Service oauth2Service;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,

    // NEW
    required this.registerDeviceUseCase,

    required this.secureStorage,
    required this.oauth2Service,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogout);
    on<OAuthLoginRequested>(_onOAuthLogin);
  }

  String _getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '').trim();
    }

    return 'Something went wrong. Please try again.';
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );

      // 1. Login
      final response = await loginUseCase(request);

      // 2. Save JWT
      await secureStorage.write(key: StorageKeys.jwtKey, value: response.token);

      log('Login Successful');
      log('JWT token saved');

      // ========================================================
      // 3. GET REAL FCM TOKEN
      // ========================================================

      try {
        final fcmToken = await NotificationService.instance.getFcmToken();

        log('FCM token obtained: $fcmToken');

        // ======================================================
        // 4. REGISTER FCM TOKEN WITH BACKEND
        // ======================================================

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await registerDeviceUseCase(
            DeviceRegisterRequest(fcmToken: fcmToken, deviceType: 'ANDROID'),
          );

          log('FCM token registered successfully');
        } else {
          log('FCM token is null or empty');
        }
      } catch (e, stackTrace) {
        // FCM registration failure should NOT
        // make login fail.

        log('Failed to register FCM token', error: e, stackTrace: stackTrace);
      }

      // 5. Login completed
      emit(AuthAuthenticated());
    } catch (e, stackTrace) {
      final message = _getErrorMessage(e);

      log('Login failed: $message', error: e, stackTrace: stackTrace);

      emit(AuthFailure(message));
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final request = RegisterRequest(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        phone: event.phone,
        gender: event.gender,
      );

      final response = await registerUseCase(request);

      /*
       * If registration returns a JWT,
       * automatically authenticate the user.
       */

      if (response.token.isNotEmpty) {
        await secureStorage.write(
          key: StorageKeys.jwtKey,
          value: response.token,
        );

        log('Registration successful');
        log('JWT token saved');

        // Get FCM token after automatic login
        try {
          final fcmToken = await NotificationService.instance.getFcmToken();

          if (fcmToken != null && fcmToken.isNotEmpty) {
            await registerDeviceUseCase(
              DeviceRegisterRequest(fcmToken: fcmToken, deviceType: 'ANDROID'),
            );

            log('FCM token registered successfully');
          }
        } catch (e, stackTrace) {
          log(
            'Failed to register FCM token after registration',
            error: e,
            stackTrace: stackTrace,
          );
        }

        emit(AuthAuthenticated());
      } else {
        emit(AuthSuccess());
      }
    } catch (e, stackTrace) {
      final message = _getErrorMessage(e);

      log('Registration failed: $message', error: e, stackTrace: stackTrace);

      emit(AuthFailure(message));
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _onForgotPassword(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final request = ForgotPasswordRequest(email: event.email);

      final message = await forgotPasswordUseCase(request);

      log('Password reset link sent');

      emit(ForgotPasswordSuccess(message));
    } catch (e, stackTrace) {
      final message = _getErrorMessage(e);

      log('Forgot password failed: $message', error: e, stackTrace: stackTrace);

      emit(AuthFailure(message));
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> _onResetPassword(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final request = ResetPasswordRequest(
        token: event.token,
        newPassword: event.newPassword,
      );

      await resetPasswordUseCase(request);

      log('Password reset successful');

      emit(ResetPasswordSuccess());
    } catch (e, stackTrace) {
      final message = _getErrorMessage(e);

      log('Reset password failed: $message', error: e, stackTrace: stackTrace);

      emit(AuthFailure(message));
    }
  }

  // ============================================================
  // OAUTH LOGIN
  // ============================================================

  Future<void> _onOAuthLogin(
    OAuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await oauth2Service.authenticate(provider: event.provider);

      if (token == null || token.isEmpty) {
        emit(AuthFailure('OAuth sign-in was cancelled.'));

        return;
      }

      // Save JWT
      await secureStorage.write(key: StorageKeys.jwtKey, value: token);

      log('OAuth login successful');
      log('JWT token saved');

      // Register FCM token
      try {
        final fcmToken = await NotificationService.instance.getFcmToken();

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await registerDeviceUseCase(
            DeviceRegisterRequest(fcmToken: fcmToken, deviceType: 'ANDROID'),
          );

          log('FCM token registered successfully');
        }
      } catch (e, stackTrace) {
        log(
          'Failed to register FCM token after OAuth login',
          error: e,
          stackTrace: stackTrace,
        );
      }

      emit(AuthAuthenticated());
    } catch (e, stackTrace) {
      final message = _getErrorMessage(e);

      log('OAuth login failed: $message', error: e, stackTrace: stackTrace);

      emit(AuthFailure(message));
    }
  }

  // ============================================================
  // CHECK AUTH STATUS
  // ============================================================

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await secureStorage.read(key: StorageKeys.jwtKey);

      if (token != null && token.isNotEmpty) {
        log('Existing JWT token found');
        log('User is already authenticated');

        emit(AuthAuthenticated());
      } else {
        log('No JWT token found');
        log('User is not authenticated');

        emit(AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      final message = _getErrorMessage(e);

      log(
        'Check auth status failed: $message',
        error: e,
        stackTrace: stackTrace,
      );

      emit(AuthFailure(message));
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await secureStorage.delete(key: StorageKeys.jwtKey);

      log('JWT token deleted');
      log('Logout successful');

      emit(AuthUnauthenticated());
    } catch (e, stackTrace) {
      log('Logout failed', error: e, stackTrace: stackTrace);

      emit(AuthFailure('Unable to logout. Please try again.'));
    }
  }
}
