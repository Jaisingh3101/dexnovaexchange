import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'send_receive_screen.dart';

class NftGalleryScreen extends StatefulWidget {
  const NftGalleryScreen({super.key});

  @override
  State<NftGalleryScreen> createState() => _NftGalleryScreenState();
}

class _NftGalleryScreenState extends State<NftGalleryScreen> {
  int tab = 0; // 0 = NFTs, 1 = DeFi Positions
  String chain = 'All';

  static const _chains = ['All', 'Ethereum', 'Solana', 'Polygon'];
  static const _nfts = [
    ('CyberApe #4821', 'Bored Lab', 'Ethereum', '1.45 ETH', Color(0xFF7B3FF2)),
    (
      'DexNova Pass #009',
      'DexNova VIP',
      'Ethereum',
      '0.82 ETH',
      Color(0xFF3B82F6),
    ),
    ('Solana Punk #1104', 'SolPunks', 'Solana', '18.5 SOL', Color(0xFF16C784)),
    ('Azuki Spirit #772', 'Azuki', 'Ethereum', '2.10 ETH', Color(0xFFEA3943)),
    (
      'Polygon Genesis #88',
      'PolyClub',
      'Polygon',
      '420 POL',
      Color(0xFF8B5CF6),
    ),
    ('Orbital Mech #312', 'StarForge', 'Solana', '9.4 SOL', Color(0xFFF59E0B)),
  ];

  static const _defi = [
    (
      'Uniswap v3 ETH/USDT LP',
      'Ethereum',
      '\$6,420.00',
      '+18.4% APY',
      AppColors.primaryLight,
    ),
    (
      'Aave v3 USDT Supply',
      'Polygon',
      '\$4,150.00',
      '+6.2% APY',
      AppColors.blue,
    ),
    (
      'Lido stETH Staking',
      'Ethereum',
      '\$3,412.67',
      '+3.4% APY',
      AppColors.green,
    ),
    (
      'Jupiter JLP Vault',
      'Solana',
      '\$1,980.00',
      '+24.1% APY',
      AppColors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final visibleNfts = _nfts
        .where((n) => chain == 'All' || n.$3 == chain)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFTs & DeFi'),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: FIcon(Flaticons.receive, size: 18, color: p.text),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SendReceiveScreen(initialTab: 1),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
        children: [
          _tabBar(p),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _chains.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final sel = chain == _chains[i];
                return GestureDetector(
                  onTap: () => setState(() => chain = _chains[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.primaryGradient : null,
                      color: sel ? null : p.card,
                      borderRadius: BorderRadius.circular(14),
                      border: sel ? null : Border.all(color: p.border),
                    ),
                    child: Center(
                      child: Text(
                        _chains[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : p.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (tab == 0)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [for (final n in visibleNfts) _nftCard(p, n)],
            )
          else
            for (final d in _defi)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      FBadgeIcon(
                        Flaticons.earn,
                        color: d.$5,
                        size: 34,
                        iconSize: 17,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: p.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${d.$2} • ${d.$4}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            d.$3,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => showToast(
                              context,
                              'Claimed yield from ${d.$1}',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Claim',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _tabBar(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          _tabBtn(p, 0, 'NFTs (${_nfts.length})'),
          _tabBtn(p, 1, 'DeFi Positions (${_defi.length})'),
        ],
      ),
    );
  }

  Widget _tabBtn(AppPalette p, int i, String label) {
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : p.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nftCard(AppPalette p, (String, String, String, String, Color) n) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    n.$5.withValues(alpha: 0.85),
                    n.$5.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: FIcon(
                      Flaticons.sparkles,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        n.$3,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  n.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: p.textMuted),
                ),
              ),
              const FIcon(
                Flaticons.checkCircle,
                size: 11,
                color: AppColors.blue,
              ),
            ],
          ),
          Text(
            n.$1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  n.$4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendReceiveScreen(initialTab: 0),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: p.cardAlt,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: p.border),
                  ),
                  child: Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
