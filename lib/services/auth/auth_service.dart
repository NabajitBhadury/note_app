import 'package:noteapp/services/auth/auth_provider.dart';
import 'package:noteapp/services/auth/auth_user.dart';
import 'package:noteapp/services/auth/firebase_auth_provider.dart';

// Here we use the AuthService class that implements the AuthProvider class to and the UI will use the functionalities of the AuthProvider class from here rather than the FirebaseAuthProvider class as if so there is no reason to make the auth provider class itself now this code will determine the provider to be which provider to use

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(
      FirebaseAuthProvider()); // Here the factory constructor takes an instance of friebaseAuthProvider class and throws it to the AuthService and by this way we use the firebase auth provider here

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) =>
      provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
