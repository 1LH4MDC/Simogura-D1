import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class UserHomeScreen extends StatelessWidget {
  final UserModel user;
  const UserHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home User — Coming Soon')),
    );
  }
}