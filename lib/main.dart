import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_frame/device_frame.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'navigation/router.dart'; // ✅ pakai AppRouter

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Init Supabase ──────────────────────────────────
  await Supabase.initialize(
    url:     'https://zhhegvwjahymqudoztso.supabase.co',
    anonKey: 'sb_publishable_7DrOWbtShGGvjb7UOce9iA_ZmAzN7YD',
  );

  // ── Portrait only (mobile) ─────────────────────────
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
  }

  runApp(const SimoguraApp());
}

class SimoguraApp extends StatelessWidget {
  const SimoguraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Versi Web: bungkus dengan frame HP ────────────
    if (kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          body: Center(
            child: DeviceFrame(
              device: Devices.ios.iPhone13,
              isFrameVisible: true,
              screen: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.theme,
                // ✅ AppRouter cek session & role otomatis
                home: const AppRouter(),
              ),
            ),
          ),
        ),
      );
    }

    // ── Versi Mobile: langsung AppRouter ──────────────
    return MaterialApp(
      title: 'SIMOGURA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // ✅ AppRouter otomatis cek: ada session? → admin/user nav
      //    tidak ada session? → onboarding
      home: const AppRouter(),
    );
  }
}