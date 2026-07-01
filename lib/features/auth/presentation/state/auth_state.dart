/// UI state for the authentication flow, consumed by the login and sign-up
/// screens via [AuthNotifier].
sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
