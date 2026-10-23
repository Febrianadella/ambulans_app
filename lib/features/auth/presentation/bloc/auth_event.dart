abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedEvent({required this.email, required this.password});
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
