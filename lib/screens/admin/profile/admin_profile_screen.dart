import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class AdminProfileScreen extends StatelessWidget {
  final UserModel user;
  const AdminProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile — Coming Soon')),
    );
  }
}