import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/market_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/api_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const DexNovaApp(showSplash: true));
}

class DexNovaApp extends StatelessWidget {
  final bool showSplash;
  final ApiServiceContract? apiService;
  final ThemeMode initialThemeMode;

  const DexNovaApp({
    super.key,
    this.showSplash = false,
    this.apiService,
    this.initialThemeMode = ThemeMode.light,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiServiceContract>(
          create: (_) => apiService ?? ApiService(),
          dispose: (_, svc) {
            if (apiService == null) svc.dispose();
          },
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialThemeMode),
        ),
        ChangeNotifierProvider<WalletProvider>(create: (_) => WalletProvider()),
        ChangeNotifierProvider<MarketProvider>(
          create: (ctx) => MarketProvider(ctx.read<ApiServiceContract>()),
        ),
        ChangeNotifierProvider<PortfolioProvider>(
          create: (ctx) => PortfolioProvider(ctx.read<ApiServiceContract>()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProv, _) => MaterialApp(
          title: 'HyperDEX',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeProv.mode,
          home: showSplash ? const OnboardingScreen() : const MainShell(),
        ),
      ),
    );
  }
}
