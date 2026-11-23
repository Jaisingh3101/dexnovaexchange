import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class SendReceiveScreen extends StatefulWidget {
  final int initialTab; // 0 = Send, 1 = Receive
  const SendReceiveScreen({super.key, this.initialTab = 0});

  @override
  State<SendReceiveScreen> createState() => _SendReceiveScreenState();
}

class _SendReceiveScreenState extends State<SendReceiveScreen> {
  late int tab = widget.initialTab;
  Coin coin = coins[1];
  String network = networks[0];
  final addrCtrl = TextEditingController();
  final amtCtrl = TextEditingController();

  static const _recent = [
    ('Main Vault', '0x7a9E...3b2F'),
    ('Cold Ledger', 'bc1qxy...0wlh'),
    ('Tron Pool', 'TD7fKc...9hF8'),
  ];

  @override
  void dispose() {
    addrCtrl.dispose();
    amtCtrl.dispose();
    super.dispose();
  }

  double get _amt => double.tryParse(amtCtrl.text) ?? 0;
  double get _fee =>
      coin.symbol == 'BTC' ? 0.0002 : (coin.symbol == 'USDT' ? 1.0 : 0.002);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send & Receive'),
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
          _tabs(p),
          const SizedBox(height: 10),
          _selectors(p),
          const SizedBox(height: 8),
          if (tab == 0) ..._send(p) else ..._receive(p),
        ],
      ),
    );
  }

  Widget _tabs(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          _tabBtn(p, 0, 'Send', Flaticons.send),
          _tabBtn(p, 1, 'Receive', Flaticons.receive),
        ],
      ),
    );
  }

  Widget _tabBtn(AppPalette p, int i, String label, Flaticons icon) {
    final sel = i == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: sel ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FIcon(icon, size: 15, color: sel ? Colors.white : p.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectors(AppPalette p) {
    return Row(
      children: [
        Expanded(
          child: SelectorTile(
            leading: CoinIcon(coin, size: 22),
            title: coin.symbol,
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
            leading: const FIcon(
              Flaticons.network,
              size: 18,
              color: AppColors.primaryLight,
            ),
            title: network,
            onTap: () async {
              final n = await pickNetwork(context);
              if (n != null) setState(() => network = n);
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _send(AppPalette p) {
    final usdVal = _amt * coin.price;
    final total = (_amt + _fee).clamp(0, double.infinity);
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: p.cardAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: p.border),
        ),
        child: Row(
          children: [
            Text(
              'Available:',
              style: TextStyle(fontSize: 11.5, color: p.textMuted),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${coin.holding.toStringAsFixed(4)} ${coin.symbol} ≈ \$${fmtUsd(coin.value)}',
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
            ),
          ],
        ),
      ),
      const FieldLabel('Recipient Address'),
      TextField(
        controller: addrCtrl,
        style: TextStyle(fontSize: 12.5, color: p.text),
        decoration: InputDecoration(
          hintText: 'Enter or paste wallet address',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final d = await Clipboard.getData('text/plain');
                  if (d?.text != null && d!.text!.isNotEmpty) {
                    setState(() => addrCtrl.text = d.text!);
                  } else {
                    if (mounted) showToast(context, 'Clipboard empty');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Paste',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: FIcon(Flaticons.qrScan, size: 17, color: p.textSecondary),
                onPressed: () => showToast(context, 'QR Scanner coming soon'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        height: 26,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _recent.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() => addrCtrl.text = _recent[i].$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: p.border),
              ),
              child: Center(
                child: Text(
                  '${_recent[i].$1} • ${_recent[i].$2}',
                  style: TextStyle(fontSize: 10.5, color: p.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
      const FieldLabel('Amount'),
      TextField(
        controller: amtCtrl,
        onChanged: (_) => setState(() {}),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                coin.symbol,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: p.textMuted,
                ),
              ),
              TextButton(
                onPressed: () => setState(
                  () => amtCtrl.text = coin.holding.toStringAsFixed(4),
                ),
                child: const Text(
                  'MAX',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          '≈ \$${fmtUsd(usdVal)} USD',
          style: TextStyle(fontSize: 11, color: p.textMuted),
        ),
      ),
      Row(
        children: [25, 50, 75, 100].map((pct) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: pct == 100 ? 0 : 6),
              child: GestureDetector(
                onTap: () => setState(
                  () => amtCtrl.text = (coin.holding * pct / 100)
                      .toStringAsFixed(4),
                ),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.border),
                  ),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _infoRow(
              p,
              'Network Fee',
              '${_fee.toStringAsFixed(4)} ${coin.symbol}',
            ),
            const SizedBox(height: 6),
            _infoRow(p, 'Est. Arrival', '~15 seconds'),
            const SizedBox(height: 6),
            _infoRow(
              p,
              'Total Deducted',
              '${(_amt > 0 ? total : 0).toStringAsFixed(4)} ${coin.symbol}',
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GradientButton(
        label: 'Send ${coin.symbol}',
        icon: Flaticons.send,
        onPressed: () {
          if (addrCtrl.text.trim().isEmpty || _amt <= 0) {
            showToast(context, 'Enter recipient address and valid amount');
            return;
          }
          showToast(
            context,
            'Sent ${amtCtrl.text} ${coin.symbol} on ${network.split(' ').first}',
          );
          Navigator.pop(context);
        },
      ),
      const SizedBox(height: 8),
      GlassCard(
        onTap: () => setState(() => tab = 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            const FBadgeIcon(Flaticons.receive, size: 28, iconSize: 14),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Switch to Receive',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  Text(
                    'Show QR Code & wallet address',
                    style: TextStyle(fontSize: 11, color: p.textMuted),
                  ),
                ],
              ),
            ),
            FIcon(Flaticons.chevronRight, size: 16, color: p.textSecondary),
          ],
        ),
      ),
    ];
  }

  List<Widget> _receive(AppPalette p) {
    final address = coin.symbol == 'BTC'
        ? 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
        : 'TD7fKc8sXq2LmN4pR9vW1yZ3aB6eH5j9hF8';
    return [
      GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CoinIcon(coin, size: 22),
                const SizedBox(width: 6),
                Text(
                  '${coin.symbol} (${network.split(' ').first})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FakeQr(data: address + coin.symbol + network, size: 128),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: p.field,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.border),
              ),
              child: SelectableText(
                address,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: GradientButton(
              label: 'Copy Address',
              icon: Flaticons.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address));
                showToast(context, 'Address copied');
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GradientButton(
              label: 'Share QR',
              icon: Flaticons.share,
              outlined: true,
              onPressed: () =>
                  showToast(context, '${coin.symbol} receive address shared'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _infoRow(p, 'Minimum Receive', '0.0001 ${coin.symbol}'),
            const SizedBox(height: 6),
            _infoRow(p, 'Network Confirmations', '1 confirmation'),
            const SizedBox(height: 6),
            _infoRow(p, 'Est. Arrival', '~1 minute'),
          ],
        ),
      ),
    ];
  }

  Widget _infoRow(AppPalette p, String l, String r) => Row(
    children: [
      Expanded(
        child: Text(l, style: TextStyle(fontSize: 11.5, color: p.textMuted)),
      ),
      Text(
        r,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
      ),
    ],
  );
}
