import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              'User not found',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              'Wrong Credentials',
            );
          } else if (state.exception is GenericAuthException) {
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
        body: Column(
          children: [
            TextField(
              controller: _emailcontroller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter a valid email address',
              ),
            ),
            TextField(
              controller: _passwordcontroller,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter a valid password',
              ),
            ),
            TextButton(
              onPressed: () async {
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
              },
              child: const Text('Loggin'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventShouldRegister(),
                    );
              },
              child: const Text('Yet not registered, please register'),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:noteapp/services/auth/auth_exceptions.dart';
// import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
// import 'package:noteapp/services/auth/bloc/auth_event.dart';
// import 'package:noteapp/services/auth/bloc/auth_state.dart';
// import 'package:noteapp/utilities/dialogs/error_dialog.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({Key? key}) : super(key: key);

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   late final TextEditingController _email;
//   late final TextEditingController _password;

//   @override
//   void initState() {
//     _email = TextEditingController();
//     _password = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) async {
//         if (state is AuthStateLoggedOut) {
//           if (state.exception is UserNotFoundAuthException) {
//             await showErrorDialog(context, 'User not found');
//           } else if (state.exception is WrongPasswordAuthException) {
//             await showErrorDialog(context, 'Wrong credentials');
//           } else if (state.exception is GenericAuthException) {
//             await showErrorDialog(context, 'Authentication error');
//           }
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Login'),
//         ),
//         body: Column(
//           children: [
//             TextField(
//               controller: _email,
//               enableSuggestions: false,
//               autocorrect: false,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your email here',
//               ),
//             ),
//             TextField(
//               controller: _password,
//               obscureText: true,
//               enableSuggestions: false,
//               autocorrect: false,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your password here',
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 final email = _email.text;
//                 final password = _password.text;
//                 context.read<AuthBloc>().add(
//                       AuthEventLogin(
//                         email,
//                         password,
//                       ),
//                     );
//               },
//               child: const Text('Login'),
//             ),
//             TextButton(
//               onPressed: () {
//                 context.read<AuthBloc>().add(
//                       const AuthEventShouldRegister(),
//                     );
//               },
//               child: const Text('Not registered yet? Register here!'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
