import 'package:noteapp/services/auth/auth_user.dart';

// This is an abstract class wehre we define the parameters which is required for an authentication provider and hence the authentication provider we hereby use in this application will implement these parameters mentioned in the class

abstract class AuthProvider {
  AuthUser?
      get currentUser; // get is an inbuilt keyword in dart that acts as a getter and here a getter for the current user

  Future<void> initialize(); // for initialization of the provider app
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> sendEmailVerification();
}
