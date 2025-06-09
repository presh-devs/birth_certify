class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    this.error,
  });

  factory AuthState.initial() => AuthState(
        isLoading: false,
        isLoggedIn: false,
        error: null,
      );

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error,
    );
  }
}
