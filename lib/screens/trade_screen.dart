import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});
  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  bool buy = true;
  Coin coin = coins[1];
  final priceCtrl = TextEditingController(
    text: coins[1].price.toStringAsFixed(2),
  );
  final amtCtrl = TextEditingController();

  @override
  void dispose() {
    priceCtrl.dispose();
    amtCtrl.dispose();
    super.dispose();
  }

  double get total =>
      (double.tryParse(priceCtrl.text) ?? 0) *
      (double.tryParse(amtCtrl.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final color = buy ? AppColors.green : AppColors.red;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final c = await pickCoin(context);
                  if (c != null && c.symbol != 'USDT') {
                    setState(() {
                      coin = c;
                      priceCtrl.text = c.price.toStringAsFixed(2);
                    });
                  }
                },
                child: Row(
                  children: [
                    CoinIcon(coin, size: 24),
                    const SizedBox(width: 7),
                    Text(
                      '${coin.symbol}/USDT',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FIcon(Flaticons.chevronDown, size: 15, color: p.text),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ChangeText(coin.change, size: 12),
              const Spacer(),
              const ThemeToggleButton(compact: true),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [_side(p, 'Buy', true), _side(p, 'Sell', false)],
            ),
          ),
          const FieldLabel('Price (USDT)'),
          TextField(
            controller: priceCtrl,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          FieldLabel('Amount (${coin.symbol})'),
          TextField(
            controller: amtCtrl,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: '0.00'),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 12, color: p.textMuted),
                ),
                const Spacer(),
                Text(
                  '${fmtUsd(total)} USDT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (total <= 0) {
                  showToast(context, 'Enter amount');
                  return;
                }
                showToast(
                  context,
                  '${buy ? 'Buy' : 'Sell'} order placed: ${amtCtrl.text} ${coin.symbol}',
                );
                amtCtrl.clear();
                setState(() {});
              },
              child: Text(
                '${buy ? 'Buy' : 'Sell'} ${coin.symbol}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Order Book',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 6),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 5; i++)
                  _bookRow(
                    p,
                    coin.price * (1 + (5 - i) * 0.0004),
                    0.1 + i * 0.07,
                    AppColors.red,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    fmtUsd(coin.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ),
                for (var i = 0; i < 5; i++)
                  _bookRow(
                    p,
                    coin.price * (1 - (i + 1) * 0.0004),
                    0.4 - i * 0.05,
                    AppColors.green,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _side(AppPalette p, String label, bool isBuy) {
    final sel = buy == isBuy;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => buy = isBuy),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel
                ? (isBuy ? AppColors.green : AppColors.red)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : p.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookRow(AppPalette p, double price, double qty, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      children: [
        Text(
          fmtUsd(price),
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          qty.toStringAsFixed(4),
          style: TextStyle(fontSize: 12, color: p.text),
        ),
      ],
    ),
  );
}
