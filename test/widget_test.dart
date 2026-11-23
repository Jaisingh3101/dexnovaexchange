import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dexnova/main.dart';
import 'package:dexnova/theme.dart';
import 'package:dexnova/screens/more_screen.dart';
import 'package:dexnova/screens/create_wallet_screen.dart';
import 'package:dexnova/screens/onboarding_screen.dart';
import 'package:dexnova/screens/send_receive_screen.dart';
import 'package:dexnova/screens/swap_bridge_screen.dart';
import 'package:dexnova/screens/nft_gallery_screen.dart';
import 'package:dexnova/screens/token_manager_screen.dart';

void main() {
  for (final mode in const [ThemeMode.dark, ThemeMode.light]) {
    for (final size in const [Size(1080, 2340), Size(720, 1480)]) {
      testWidgets(
        'Splash + Onboarding + all Web3 screens render in ${mode.name} at ${size.width}x${size.height}',
        (tester) async {
          themeNotifier.value = mode;
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = size.width / 360;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(const DexNovaApp(showSplash: true));
          await tester.pump();
          expect(find.text('DexNova'), findsOneWidget);

          // Test PIN Lock mode on Splash, then switch back to Welcome
          await tester.tap(find.text('PIN Lock'));
          await tester.pump();
          await tester.tap(find.text('Welcome'));
          await tester.pump();

          // Open Onboarding Tour, step through all 4 slides, and enter app
          await tester.tap(find.text('Onboarding Tour'));
          await tester.pumpAndSettle();
          for (var i = 0; i < 3; i++) {
            await tester.tap(find.text('Next'));
            await tester.pumpAndSettle();
          }
          await tester.tap(find.text('Enter DexNova Exchange'));
          await tester.pumpAndSettle();

          for (final tab in ['Markets', 'Trade', 'Wallet', 'More', 'Home']) {
            await tester.tap(find.text(tab).last);
            await tester.pump();
          }

          // Open every screen from moreItems()
          final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
          for (final item in moreItems()) {
            nav.push(MaterialPageRoute(builder: (_) => item.$4));
            await tester.pumpAndSettle();
            nav.pop();
            await tester.pumpAndSettle();
          }

          // Verify Onboarding preview
          nav.push(
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(isPreview: true),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Skip'));
          await tester.pumpAndSettle();

          // Verify Onboarding preview
          nav.push(MaterialPageRoute(builder: (_) => const OnboardingScreen(isPreview: true)));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Skip'));
          await tester.pumpAndSettle();

          // Verify Create & Recover tabs
          nav.push(MaterialPageRoute(builder: (_) => const CreateWalletScreen(initialTab: 0)));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Recover Wallet'));
          await tester.pumpAndSettle();
          nav.pop();
          await tester.pumpAndSettle();

          // Verify Send & Receive tabs
          nav.push(MaterialPageRoute(builder: (_) => const SendReceiveScreen(initialTab: 0)));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Receive').last);
          await tester.pumpAndSettle();
          nav.pop();
          await tester.pumpAndSettle();

          // Verify Swap & Bridge tabs
          nav.push(MaterialPageRoute(builder: (_) => const SwapBridgeScreen()));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cross-Chain Bridge'));
          await tester.pumpAndSettle();
          nav.pop();
          await tester.pumpAndSettle();

          // Verify NFT & DeFi tabs
          nav.push(MaterialPageRoute(builder: (_) => const NftGalleryScreen()));
          await tester.pumpAndSettle();
          await tester.tap(find.text('DeFi Positions (4)'));
          await tester.pumpAndSettle();
          nav.pop();
          await tester.pumpAndSettle();

          // Verify Token Manager tabs
          nav.push(MaterialPageRoute(builder: (_) => const TokenManagerScreen()));
          await tester.pumpAndSettle();
          await tester.tap(find.text('+ Custom Token'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Networks & Gas'));
          await tester.pumpAndSettle();
          nav.pop();
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
