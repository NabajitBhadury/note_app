import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/extensions/list/buildcontext/loc.dart';
import 'package:noteapp/services/auth/auth_exceptions.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/auth/bloc/auth_state.dart';
import 'package:noteapp/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailcontroller;
  late final TextEditingController _passwordcontroller;
  final _formKey = GlobalKey<FormState>();
  final RegExp emailValid = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  @override
  void initState() {
    _emailcontroller = TextEditingController();
    _passwordcontroller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A bloc listener is added to the widget tree to listen to the AuthBloc state changes and display the error message based on the exception type
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Cannot find a user with the entered credentials',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              'Wrong Credentials',
            );
          } else if (state.exception is GenericAuthException) {
            print('exception : $state.exception');
            await showErrorDialog(
              context,
              'Authentication failed',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please login to create notes'),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _emailcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email can't be empty";
                    } else if (!emailValid.hasMatch(value)) {
                      return "Invalid email provided";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordcontroller,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid password';
                    } else if (value.length < 6) {
                      return "Password must be at least of 6 characters";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      // minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.white60,
                      fixedSize: const Size(200, 50)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Grab the email and the password
                      final email = _emailcontroller.text;
                      final password = _passwordcontroller.text;
                      // Add the AuthEventLogin event to the AuthBloc using the add method that notifies the bloc of the event and the read function to get the AuthBloc instance
                      context.read<AuthBloc>().add(
                            AuthEventLogin(
                              email,
                              password,
                            ),
                          );
                    }
                  },
                  child: Text(context.loc.login),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: const Text('Yet not registered, please register'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(),
                        );
                  },
                  child: const Text(
                    'I forgot my password, please help me reset it',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
