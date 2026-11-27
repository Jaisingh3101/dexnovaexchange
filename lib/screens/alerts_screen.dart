import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class AlertsScreen extends StatelessWidget {
  final ValueChanged<DexPair>? onOpenPair;
  const AlertsScreen({super.key, this.onOpenPair});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final portfolio = context.watch<PortfolioProvider>();
    final list = portfolio.alerts;
    final hasTriggered = portfolio.hasTriggeredAlerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        actions: [
          IconButton(
            tooltip: 'New Alert',
            onPressed: () {
              final cur = context.read<MarketProvider>().activePair;
              if (cur != null) {
                showPriceAlertDialog(context, cur);
              } else {
                showLivePairPickerSheet(
                  context,
                  (pair) => showPriceAlertDialog(context, pair),
                );
              }
            },
            icon: const FIcon(
              Flaticons.addWallet,
              size: 18,
              color: AppColors.primaryLight,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PortfolioProvider>().checkAlerts(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: '+ New Price Alert',
                    icon: Flaticons.bell,
                    height: 36,
                    onPressed: () => showLivePairPickerSheet(
                      context,
                      (pair) => showPriceAlertDialog(context, pair),
                    ),
                  ),
                ),
                if (hasTriggered) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: GradientButton(
                      label: 'Clear Triggered',
                      icon: Flaticons.closeCircle,
                      outlined: true,
                      height: 36,
                      onPressed: () {
                        context
                            .read<PortfolioProvider>()
                            .clearTriggeredAlerts();
                        showToast(context, 'Cleared triggered alerts');
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const FBadgeIcon(
                      Flaticons.bell,
                      color: AppColors.primaryLight,
                      size: 42,
                      iconSize: 20,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No Price Alerts Yet',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "+ New Price Alert" or the bell icon on any pair to get notified when targets hit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: p.textMuted),
                    ),
                  ],
                ),
              )
            else
              for (final a in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    onTap: () async {
                      final mp = context.read<MarketProvider>();
                      await mp.selectPairByKey(a.chain, a.pair);
                      if (mp.activePair != null) {
                        onOpenPair?.call(mp.activePair!);
                      }
                    },
                    child: Row(
                      children: [
                        ChainBadge(a.chain, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.symbol,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: p.text,
                                ),
                              ),
                              Text(
                                '${a.above ? '▲ Goes above' : '▼ Goes below'} ${fmtDexPrice(a.target)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: a.above
                                      ? AppColors.green
                                      : AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (a.triggered
                                        ? AppColors.primary
                                        : AppColors.green)
                                    .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a.triggered
                                ? 'Triggered ${a.firedPrice != null ? fmtDexPrice(a.firedPrice!) : ''}'
                                : 'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: a.triggered
                                  ? AppColors.primaryLight
                                  : AppColors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => context
                              .read<PortfolioProvider>()
                              .removeAlert(a.id),
                          child: FIcon(
                            Flaticons.closeCircle,
                            size: 16,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
