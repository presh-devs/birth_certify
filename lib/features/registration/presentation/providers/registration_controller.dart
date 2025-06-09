import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegistrationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  RegistrationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  factory RegistrationState.initial() => const RegistrationState();
}

class RegistrationController extends StateNotifier<RegistrationState> {
  final Future<void> Function() onSubmit;

  RegistrationController(this.onSubmit) : super(RegistrationState.initial());
  Future<void> submit() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await onSubmit();
      state = state.copyWith(isLoading: false, isSuccess: true);

      // Optionally reset isSuccess after delay
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(isSuccess: false);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final registrationControllerProvider = StateNotifierProvider.autoDispose
    .family<RegistrationController, RegistrationState, Future<void> Function()>(
      (ref, onSubmit) {
        final link = ref.keepAlive(); // prevent disposal during async task

        final controller = RegistrationController(onSubmit);
        controller.addListener((state) {
          if (!state.isLoading) {
            link.close(); // allow disposal after loading ends
          }
        });

        return controller;
      },
    );
