import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'create_wallet_screen.dart';
import 'dapp_browser_screen.dart';
import 'deposit_screen.dart';
import 'nft_gallery_screen.dart';
import 'recovery_phrase_screen.dart';
import 'security_screen.dart';
import 'send_receive_screen.dart';
import 'swap_bridge_screen.dart';
import 'token_manager_screen.dart';
import 'withdraw_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int tab = 0;
  bool hidden = false;

  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 2),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'My Wallet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: GestureDetector(
                    onTap: () => _push(const CreateWalletScreen(initialTab: 0)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: p.cardAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FIcon(
                              Flaticons.wallet,
                              size: 12,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Main Wallet',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                            const SizedBox(width: 2),
                            FIcon(
                              Flaticons.chevronDown,
                              size: 11,
                              color: p.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const ThemeToggleButton(compact: true),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  onPressed: () => _push(const SecurityScreen()),
                  icon: FIcon(Flaticons.shieldCheck, size: 19, color: p.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              children: [
                _balance(p),
                const SizedBox(height: 8),
                _walletManagement(p),
                const SizedBox(height: 6),
                _web3Tools(p),
                const SizedBox(height: 10),
                _tabs(p),
                const SizedBox(height: 8),
                ..._tabContent(p),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balance(AppPalette p) {
    return GlassCard(
      gradient: p.heroGradient,
      radius: 14,
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.primary.withValues(alpha: 0.35),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            width: 120,
            height: 60,
            child: SparkLine(
              values: [3, 4, 3.6, 5, 4.6, 6, 5.4, 7, 6.6, 8.5, 9],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => hidden = !hidden),
                    child: FIcon(
                      hidden ? Flaticons.eyeOff : Flaticons.eye,
                      size: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hidden ? '\$ ••••••' : '\$48,392.32',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const ChangeText(5.21, size: 12),
              const SizedBox(height: 10),
              Row(
                children: [
                  _heroBtn(
                    Flaticons.deposit,
                    'Deposit',
                    () => _push(const DepositScreen()),
                    filled: true,
                  ),
                  const SizedBox(width: 6),
                  _heroBtn(
                    Flaticons.withdraw,
                    'Withdraw',
                    () => _push(const WithdrawScreen()),
                  ),
                  const SizedBox(width: 6),
                  _heroBtn(
                    Flaticons.send,
                    'Send',
                    () => _push(const SendReceiveScreen(initialTab: 0)),
                  ),
                  const SizedBox(width: 6),
                  _heroBtn(
                    Flaticons.receive,
                    'Receive',
                    () => _push(const SendReceiveScreen(initialTab: 1)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBtn(
    Flaticons icon,
    String label,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.primaryGradient : null,
            color: filled ? null : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: filled
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FIcon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletManagement(AppPalette p) {
    final items = [
      (
        Flaticons.addWallet,
        'Create Wallet',
        AppColors.primary,
        () => _push(const CreateWalletScreen(initialTab: 0)),
      ),
      (
        Flaticons.recoverWallet,
        'Recover Wallet',
        AppColors.blue,
        () => _push(const CreateWalletScreen(initialTab: 1)),
      ),
      (
        Flaticons.key,
        'Backup Phrase',
        AppColors.green,
        () => _push(const RecoveryPhraseScreen()),
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              radius: 10,
              onTap: items[i].$4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FBadgeIcon(
                    items[i].$1,
                    color: items[i].$3,
                    size: 24,
                    iconSize: 13,
                    radius: 7,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      items[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _web3Tools(AppPalette p) {
    final tools = [
      (Flaticons.trade, 'DEX Swap', () => _push(const SwapBridgeScreen())),
      (Flaticons.network, 'DApps', () => _push(const DappBrowserScreen())),
      (Flaticons.sparkles, 'NFTs', () => _push(const NftGalleryScreen())),
      (Flaticons.settings, 'Tokens', () => _push(const TokenManagerScreen())),
    ];
    return Row(
      children: [
        for (var i = 0; i < tools.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              radius: 9,
              onTap: tools[i].$3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FIcon(tools[i].$1, size: 13, color: AppColors.primaryLight),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      tools[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tabs(AppPalette p) {
    const labels = ['Assets', 'History', 'Staking'];
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final sel = i == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  gradient: sel ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : p.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _tabContent(AppPalette p) {
    if (tab == 0) {
      return [
        ...coins.where((c) => c.holding > 0).map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              radius: 11,
              onTap: () => _push(const SendReceiveScreen(initialTab: 0)),
              child: Row(
                children: [
                  CoinIcon(c, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.symbol,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          c.name,
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        c.symbol == 'USDT'
                            ? fmtUsd(c.holding)
                            : c.holding.toStringAsFixed(4),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text(
                        '≈ \$${fmtUsd(c.value)}',
                        style: TextStyle(fontSize: 11, color: p.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          radius: 11,
          onTap: () => _push(const TokenManagerScreen(initialTab: 1)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FIcon(
                Flaticons.addWallet,
                size: 14,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Import Custom Token / Manage Networks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }
    if (tab == 1) {
      final items = [
        ('Deposit', 'USDT', '+2,000.00', true, 'Nov 20, 14:22'),
        ('Withdraw', 'BTC', '-0.0150', false, 'Nov 19, 09:10'),
        ('Buy', 'ETH', '+0.5000', true, 'Nov 18, 18:45'),
        ('Sell', 'SOL', '-1.2000', false, 'Nov 17, 11:03'),
        ('Deposit', 'BNB', '+0.5000', true, 'Nov 16, 08:30'),
      ];
      return items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                radius: 11,
                child: Row(
                  children: [
                    FBadgeIcon(
                      e.$4 ? Flaticons.receive : Flaticons.send,
                      color: e.$4 ? AppColors.green : AppColors.red,
                      size: 30,
                      iconSize: 14,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.$1} ${e.$2}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          Text(
                            e.$5,
                            style: TextStyle(fontSize: 11, color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      e.$3,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: e.$4 ? AppColors.green : AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList();
    }
    final stakes = [('ETH', 4.2), ('SOL', 6.8), ('BNB', 3.1), ('USDT', 8.0)];
    return stakes
        .map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              radius: 11,
              child: Row(
                children: [
                  CoinIcon(coinBy(s.$1), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.$1,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          'Flexible',
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${s.$2}% APY',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
