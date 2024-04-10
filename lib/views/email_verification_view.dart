// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/services/auth/auth_service.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text(
              'We have send you an verification email, please verify your email'),
          const Text("Haven't recieved a verification email yet?"),
          TextButton(
            onPressed: () async {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
            },
            child: const Text('Resend email verification'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              context.read<AuthBloc>().add(
                    const AuthEventLogout(),
                  );
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
