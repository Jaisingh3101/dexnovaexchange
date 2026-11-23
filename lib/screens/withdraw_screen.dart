import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});
  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  Coin coin = coins[0];
  String network = networks[0];
  final addrCtrl = TextEditingController();
  final amtCtrl = TextEditingController();
  static const fee = 1.0;

  double get amount => double.tryParse(amtCtrl.text) ?? 0;
  double get receive => (amount - fee).clamp(0, double.infinity);

  @override
  void dispose() {
    addrCtrl.dispose();
    amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final available = coin.holding;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
        children: [
          Row(
            children: [
              Expanded(
                child: SelectorTile(
                  leading: CoinIcon(coin, size: 22),
                  title: coin.symbol,
                  trailing: Flaticons.chevronDown,
                  onTap: () async {
                    final c = await pickCoin(context);
                    if (c != null) setState(() => coin = c);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SelectorTile(
                  leading: const TronIcon(size: 22),
                  title: network,
                  onTap: () async {
                    final n = await pickNetwork(context);
                    if (n != null) setState(() => network = n);
                  },
                ),
              ),
            ],
          ),
          const FieldLabel('Withdrawal Address'),
          TextField(
            controller: addrCtrl,
            style: TextStyle(fontSize: 12.5, color: p.text),
            decoration: InputDecoration(
              hintText: 'Enter or paste address',
              suffixIcon: IconButton(
                icon: FIcon(Flaticons.qrScan, size: 17, color: p.textSecondary),
                onPressed: () => showToast(context, 'Scanner coming soon'),
              ),
            ),
          ),
          const FieldLabel('Amount'),
          TextField(
            controller: amtCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              suffixIcon: TextButton(
                onPressed: () =>
                    setState(() => amtCtrl.text = available.toStringAsFixed(2)),
                child: const Text(
                  'MAX',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Available: ${fmtUsd(available)} ${coin.symbol}',
            style: TextStyle(fontSize: 11.5, color: p.textMuted),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _row(
                  p,
                  'Network Fee',
                  '${fee.toStringAsFixed(2)} ${coin.symbol}',
                ),
                const SizedBox(height: 8),
                _row(
                  p,
                  'You will receive',
                  '${receive.toStringAsFixed(2)} ${coin.symbol}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GradientButton(
            label: 'Withdraw ${coin.symbol}',
            icon: Flaticons.withdraw,
            onPressed: () {
              if (addrCtrl.text.isEmpty) {
                showToast(context, 'Please enter withdrawal address');
              } else if (amount <= fee || amount > available) {
                showToast(context, 'Enter a valid amount');
              } else {
                showToast(
                  context,
                  'Withdrawal of ${receive.toStringAsFixed(2)} ${coin.symbol} submitted',
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _row(AppPalette p, String l, String r) => Row(
    children: [
      Expanded(
        child: Text(l, style: TextStyle(fontSize: 12, color: p.textMuted)),
      ),
      Flexible(
        child: Text(
          r,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
      ),
    ],
  );
}
