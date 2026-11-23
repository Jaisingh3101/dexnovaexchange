import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class TokenManagerScreen extends StatefulWidget {
  final int initialTab; // 0 = Tokens, 1 = Custom Token, 2 = Networks & Gas
  const TokenManagerScreen({super.key, this.initialTab = 0});

  @override
  State<TokenManagerScreen> createState() => _TokenManagerScreenState();
}

class _TokenManagerScreenState extends State<TokenManagerScreen> {
  late int tab = widget.initialTab;
  String query = '';
  String customNet = 'Ethereum ERC-20';
  final contractCtrl = TextEditingController();
  final symbolCtrl = TextEditingController();
  final decCtrl = TextEditingController(text: '18');

  final tokens = [
    ('USDT', 'Tether USD', 'TRC20', 'TR7NHq...Lj6t', true, Color(0xFF26A17B)),
    ('BTC', 'Bitcoin', 'Bitcoin', 'Native Coin', true, Color(0xFFF7931A)),
    ('ETH', 'Ethereum', 'ERC20', 'Native Coin', true, Color(0xFF627EEA)),
    ('BNB', 'BNB Smart Chain', 'BEP20', 'Native Coin', true, Color(0xFFF3BA2F)),
    ('SOL', 'Solana', 'SPL', 'Native Coin', true, Color(0xFF14F195)),
    ('ARB', 'Arbitrum', 'Arbitrum', '0x912C...8292', true, Color(0xFF28A0F0)),
    ('MATIC', 'Polygon', 'Polygon', '0x7D1A...290E', false, Color(0xFF8247E5)),
    ('LINK', 'Chainlink', 'ERC20', '0x5149...86CA', false, Color(0xFF2A5ADA)),
  ];

  static const _rpcs = [
    ('Ethereum Mainnet', 'Chain ID: 1', '18ms', AppColors.blue),
    ('BNB Smart Chain', 'Chain ID: 56', '22ms', AppColors.amber),
    ('Polygon PoS', 'Chain ID: 137', '14ms', AppColors.primaryLight),
    ('Arbitrum One', 'Chain ID: 42161', '11ms', AppColors.green),
    ('Solana Mainnet', 'Cluster: Beta', '16ms', AppColors.green),
  ];

  @override
  void dispose() {
    contractCtrl.dispose();
    symbolCtrl.dispose();
    decCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tokens & Web3 Networks'),
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
          if (tab == 0)
            ..._buildManage(p)
          else if (tab == 1)
            ..._buildCustom(p)
          else
            ..._buildNetworks(p),
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
          _tabItem(p, 0, 'Tokens'),
          _tabItem(p, 1, '+ Custom Token'),
          _tabItem(p, 2, 'Networks & Gas'),
        ],
      ),
    );
  }

  Widget _tabItem(AppPalette p, int i, String label) {
    final sel = tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            gradient: sel ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : p.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildManage(AppPalette p) {
    final visible = tokens
        .where(
          (t) =>
              t.$1.toLowerCase().contains(query.toLowerCase()) ||
              t.$2.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return [
      TextField(
        onChanged: (v) => setState(() => query = v),
        style: TextStyle(fontSize: 13, color: p.text),
        decoration: InputDecoration(
          hintText: 'Search token name or contract...',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(9),
            child: FIcon(Flaticons.search, size: 15, color: p.textMuted),
          ),
        ),
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < visible.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: visible[i].$6,
                  child: Text(
                    visible[i].$1[0],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            visible[i].$1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: p.cardAlt,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              visible[i].$3,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: p.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${visible[i].$2} • ${visible[i].$4}',
                        style: TextStyle(fontSize: 10.5, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: visible[i].$5,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) {
                    final idx = tokens.indexOf(visible[i]);
                    setState(() {
                      final cur = tokens[idx];
                      tokens[idx] = (cur.$1, cur.$2, cur.$3, cur.$4, v, cur.$6);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildCustom(AppPalette p) {
    return [
      const FieldLabel('Network'),
      SelectorTile(
        leading: const FIcon(
          Flaticons.network,
          size: 17,
          color: AppColors.primaryLight,
        ),
        title: customNet,
        onTap: () async {
          final n = await pickNetwork(context);
          if (n != null) setState(() => customNet = n);
        },
      ),
      const FieldLabel('Token Contract Address'),
      TextField(
        controller: contractCtrl,
        style: TextStyle(fontSize: 12.5, color: p.text),
        decoration: InputDecoration(
          hintText: '0x... token contract address',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  contractCtrl.text =
                      '0x6982508145454Ce325dDbE47a25d4ec3d2311933';
                  symbolCtrl.text = 'PEPE';
                  decCtrl.text = '18';
                }),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Demo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Token Symbol'),
                TextField(
                  controller: symbolCtrl,
                  style: TextStyle(fontSize: 12.5, color: p.text),
                  decoration: const InputDecoration(hintText: 'e.g. PEPE'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Decimals'),
                TextField(
                  controller: decCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 12.5, color: p.text),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const FIcon(Flaticons.warning, size: 15, color: AppColors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Anyone can create a token with any name. Always verify contract addresses.',
                style: TextStyle(fontSize: 11, color: p.text),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GradientButton(
        label: 'Import Custom Token',
        icon: Flaticons.addWallet,
        onPressed: () {
          final sym = symbolCtrl.text.trim().toUpperCase();
          final addr = contractCtrl.text.trim();
          if (sym.isEmpty || addr.length < 10) {
            showToast(context, 'Enter valid contract address & symbol');
            return;
          }
          setState(() {
            tokens.insert(0, (
              sym,
              '$sym Custom',
              customNet.split(' ').first,
              '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}',
              true,
              AppColors.primary,
            ));
            tab = 0;
          });
          showToast(context, '$sym imported to wallet');
        },
      ),
    ];
  }

  List<Widget> _buildNetworks(AppPalette p) {
    return [
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FIcon(
                  Flaticons.sparkles,
                  size: 15,
                  color: AppColors.green,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Live Ethereum Gas Tracker',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _gasPill(p, 'Slow', '11 Gwei', '\$0.28', AppColors.green),
                const SizedBox(width: 6),
                _gasPill(
                  p,
                  'Standard',
                  '14 Gwei',
                  '\$0.36',
                  AppColors.primaryLight,
                ),
                const SizedBox(width: 6),
                _gasPill(p, 'Fast', '19 Gwei', '\$0.49', AppColors.amber),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      for (final r in _rpcs)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                FBadgeIcon(
                  Flaticons.network,
                  color: r.$4,
                  size: 30,
                  iconSize: 15,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.$1,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text(
                        r.$2,
                        style: TextStyle(fontSize: 10.5, color: p.textMuted),
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
                    color: AppColors.green.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '● ${r.$3}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 6),
      GradientButton(
        label: '+ Add Custom RPC Network',
        outlined: true,
        height: 38,
        onPressed: () => showToast(
          context,
          'Custom EVM RPC dialog ready (${networks.length} default chains)',
        ),
      ),
    ];
  }

  Widget _gasPill(
    AppPalette p,
    String speed,
    String gwei,
    String usd,
    Color c,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      decoration: BoxDecoration(
        color: p.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Text(speed, style: TextStyle(fontSize: 10.5, color: p.textMuted)),
          const SizedBox(height: 2),
          Text(
            gwei,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
          Text(usd, style: TextStyle(fontSize: 10, color: p.textSecondary)),
        ],
      ),
    ),
  );
}
