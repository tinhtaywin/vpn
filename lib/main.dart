import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/vpn_provider.dart';
import 'providers/settings_provider.dart';
import 'services/vpn_service.dart';
import 'services/storage_service.dart';
import 'services/permission_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => PermissionService()),
        ProxyProvider2<StorageService, PermissionService, VpnService>(
          update: (context, storageService, permissionService, _) =>
              VpnService(),
        ),
        ChangeNotifierProxyProvider<VpnService, VpnProvider>(
          create: null,
          update: (context, vpnService, previous) =>
              previous ?? VpnProvider(vpnService, context.read<StorageService>(), context.read<PermissionService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(context.read<StorageService>()),
        ),
      ],
      child: const VpnApp(),
    ),
  );
}

class VpnApp extends StatelessWidget {
  const VpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLESS VPN',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/server-config': (context) => const ServerConfigScreen(),
        '/split-tunneling': (context) => const SplitTunnelingScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate to home screen after splash
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: child,
                );
              },
              child: AppTheme.buildGlowingText(
                'VLESS VPN',
                style: AppTheme.neonTitle.copyWith(fontSize: 48),
                glowColor: AppTheme.primaryColor,
                glowRadius: 30,
              ),
            ),
            const SizedBox(height: 16),
            AppTheme.buildGlowingText(
              'Secure • Fast • Neon',
              style: AppTheme.neonSecondary,
              glowColor: AppTheme.secondaryColor,
              glowRadius: 10,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}