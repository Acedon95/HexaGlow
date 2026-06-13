import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/hex_state_provider.dart';

void main() {
  runApp(const HexaGlowApp());
}

class HexaGlowApp extends StatelessWidget {
  const HexaGlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HexStateProvider()..init(),
      child: MaterialApp(
        title: 'HexaGlow',
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          useMaterial3: true,
        ),
        builder: (context, child) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/hexaglow_background_asset.png',
                fit: BoxFit.cover,
              ),
            ),
            if (child != null) child,
          ],
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HexStateProvider>();
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const HomeScreen();
  }
}
