import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});
  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final list = coins
        .where(
          (c) =>
              c.symbol != 'USDT' &&
              (c.symbol.toLowerCase().contains(query.toLowerCase()) ||
                  c.name.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          const SectionTitle(
            'Markets',
            trailing: ThemeToggleButton(compact: true),
          ),
          TextField(
            onChanged: (v) => setState(() => query = v),
            style: TextStyle(fontSize: 13, color: p.text),
            decoration: InputDecoration(
              hintText: 'Search coin or pair',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(9),
                child: FIcon(Flaticons.search, size: 16, color: p.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pair',
                  style: TextStyle(color: p.textMuted, fontSize: 11),
                ),
              ),
              Text(
                'Last Price',
                style: TextStyle(color: p.textMuted, fontSize: 11),
              ),
              const SizedBox(width: 34),
              Text(
                '24h Chg',
                style: TextStyle(color: p.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final c in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                radius: 11,
                child: Row(
                  children: [
                    CoinIcon(c, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.symbol}/USDT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          Text(
                            c.name,
                            style: TextStyle(color: p.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fmtUsd(c.price),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 68,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: c.change >= 0 ? AppColors.green : AppColors.red,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${c.change >= 0 ? '+' : ''}${c.change.toStringAsFixed(2)}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
