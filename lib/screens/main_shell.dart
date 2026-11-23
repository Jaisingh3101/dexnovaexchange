import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'home_screen.dart';
import 'markets_screen.dart';
import 'more_screen.dart';
import 'trade_screen.dart';
import 'wallet_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final pages = [
      HomeScreen(onTab: go),
      const MarketsScreen(),
      const TradeScreen(),
      const WalletScreen(),
      const MoreScreen(),
    ];
    return Scaffold(
      drawer: const _AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.bgSecondary, p.bg],
          ),
        ),
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: _BottomBar(index: index, onTap: go),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Drawer(
      backgroundColor: p.card,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          children: [
            ListTile(
              leading: const DexNovaLogo(size: 36),
              title: const Text('DexNova Wallet'),
              subtitle: const Text('UID: 84920315'),
              trailing: const ThemeToggleButton(compact: true),
            ),
            Divider(color: p.border),
            ListTile(
              leading: FBadgeIcon(
                p.isDark ? Flaticons.moon : Flaticons.sun,
                color: p.isDark ? AppColors.primaryLight : AppColors.amber,
                size: 28,
                iconSize: 14,
              ),
              title: Text(
                p.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              ),
              onTap: toggleTheme,
            ),
            Divider(color: p.border),
            for (final it in moreItems())
              ListTile(
                leading: FBadgeIcon(
                  it.$1,
                  color: it.$3,
                  size: 28,
                  iconSize: 14,
                ),
                title: Text(it.$2),
                trailing: FIcon(
                  Flaticons.chevronRight,
                  size: 14,
                  color: p.textMuted,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => it.$4),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const items = [
      (Flaticons.home, 'Home'),
      (Flaticons.markets, 'Markets'),
      (Flaticons.trade, 'Trade'),
      (Flaticons.wallet, 'Wallet'),
      (Flaticons.more, 'More'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.navBg,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              final color = selected ? AppColors.primaryLight : p.textSecondary;
              if (i == 2) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Center(
                            child: FIcon(
                              items[i].$1,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].$2,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FIcon(items[i].$1, color: color, size: 20),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: color,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
