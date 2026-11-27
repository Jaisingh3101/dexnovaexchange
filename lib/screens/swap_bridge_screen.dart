import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import '../widgets/hyper_header.dart';
import '../widgets/wallet_switcher.dart';

class SwapBridgeScreen extends StatelessWidget {
  const SwapBridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert & Instant Swap'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: const ConvertSwapBody(),
    );
  }
}

class ConvertTabScreen extends StatelessWidget {
  final ValueChanged<DexPair>? onOpenPair;
  final VoidCallback? onOpenTrade;
  const ConvertTabScreen({super.key, this.onOpenPair, this.onOpenTrade});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          HyperTopBar(onSelectPair: onOpenPair),
          Expanded(child: ConvertSwapBody(onOpenTrade: onOpenTrade)),
        ],
      ),
    );
  }
}

class ConvertSwapBody extends StatefulWidget {
  final VoidCallback? onOpenTrade;
  const ConvertSwapBody({super.key, this.onOpenTrade});

  @override
  State<ConvertSwapBody> createState() => _ConvertSwapBodyState();
}

class _ConvertSwapBodyState extends State<ConvertSwapBody> {
  String? _pickedChainSlug;
  DexPair? selectedPair;
  bool isBuy = true;
  final fromCtrl = TextEditingController();
  String? _swapError;
  String? _swapStep;
  bool _submitting = false;
  String? _lastBalKey;

  @override
  void initState() {
    super.initState();
    final market = context.read<MarketProvider>();
    selectedPair =
        market.activePair ??
        (market.visibleMarketRows.isNotEmpty
            ? market.visibleMarketRows.first
            : null);
    _pickedChainSlug = selectedPair?.chain;
  }

  @override
  void dispose() {
    fromCtrl.dispose();
    super.dispose();
  }

  double get _inAmt =>
      double.tryParse(fromCtrl.text.replaceAll(',', '').trim()) ?? 0;

  double _outAmtFor(DexPair? p) {
    if (p == null || p.price <= 0 || _inAmt <= 0) return 0;
    const feeMul = 0.999; // 0.10% DEX protocol fee
    return isBuy ? (_inAmt * feeMul) / p.price : _inAmt * p.price * feeMul;
  }

  double _quoteUsd(DexPair pair, MarketProvider market) {
    final sym = pair.quote.symbol.toUpperCase();
    const stables = {
      'USDT',
      'USDC',
      'BUSD',
      'DAI',
      'USDE',
      'FDUSD',
      'TUSD',
      'USD1',
      'USD',
    };
    if (stables.contains(sym)) return 1.0;
    final native = market.nativeUsdPrice(sym);
    if (native > 0) return native;
    if (pair.priceNative > 0 && pair.price > 0) {
      return pair.price / pair.priceNative;
    }
    return 1.0;
  }

  void _schedulePairBalIfNeeded(DexPair? pair, WalletAccount? wallet) {
    if (pair == null || wallet == null) {
      _lastBalKey = null;
      return;
    }
    final walletAddr = wallet.ethAddress;
    final key = '${walletAddr.toLowerCase()}:${pair.key}';
    if (_lastBalKey == key) return;
    _lastBalKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PortfolioProvider>().refreshPairBalances(
        walletAddress: walletAddr,
        pair: pair,
      );
    });
  }

  Future<void> _pickChain() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.pal.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final c in kDexChains.values)
              ListTile(
                leading: ChainBadge(c.slug, size: 22),
                title: Text('${c.name} (${c.symbol})'),
                onTap: () => Navigator.pop(ctx, c.slug),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _pickedChainSlug = chosen);
  }

  Future<void> _executeConvert(DexPair? pair, MarketProvider market) async {
    final wallet = context.read<WalletProvider>().activeWallet;
    if (wallet == null) {
      setState(() {
        _swapError =
            '✕ Please connect your Web3 wallet first to execute a conversion.';
      });
      showWalletSwitcherSheet(context);
      return;
    }
    if (pair == null) {
      setState(() => _swapError = '✕ Select a token first.');
      return;
    }
    if (_inAmt <= 0) {
      setState(() => _swapError = '✕ Enter a valid amount greater than 0.');
      return;
    }

    final ci = chainInfoFor(pair.chain);
    setState(() {
      _swapError = null;
      _submitting = true;
      _swapStep = 'Step 1/2: Checking live wallet balance on ${ci.name}…';
    });

    final liveBal = await context.read<PortfolioProvider>().refreshPairBalances(
      walletAddress: wallet.ethAddress,
      pair: pair,
    );
    if (!mounted) return;

    final quoteUsd = _quoteUsd(pair, market);
    final nativeUsd = market.nativeUsdPrice(ci.symbol);

    if (isBuy) {
      final reqQuote = _inAmt;
      final reqUsd = reqQuote * quoteUsd;
      final hasQuote = liveBal.quoteBalance >= reqQuote;
      final hasNative =
          nativeUsd > 0 && (liveBal.nativeBalance * nativeUsd) >= reqUsd;
      if (!hasQuote && !hasNative) {
        setState(() {
          _submitting = false;
          _swapStep = null;
          _swapError =
              '✕ Insufficient ${pair.quote.symbol} Balance in Wallet!\n'
              'Required: ${reqQuote.toStringAsFixed(4)} ${pair.quote.symbol} (${fmtCompactUsd(reqUsd)})\n'
              'Your Wallet: ${liveBal.quoteBalance.toStringAsFixed(4)} ${pair.quote.symbol} & '
              '${liveBal.nativeBalance.toStringAsFixed(5)} ${ci.symbol} (${fmtCompactUsd(liveBal.nativeBalance * nativeUsd)}).';
        });
        return;
      }
    } else {
      if (liveBal.baseBalance < _inAmt) {
        setState(() {
          _submitting = false;
          _swapStep = null;
          _swapError =
              '✕ Insufficient ${pair.base.symbol} Balance in Wallet!\n'
              'Required: ${fmtCompactNum(_inAmt)} ${pair.base.symbol} (${fmtCompactUsd(_inAmt * pair.price)})\n'
              'Your Wallet Holding: ${fmtCompactNum(liveBal.baseBalance)} ${pair.base.symbol}.';
        });
        return;
      }
    }

    final out = _outAmtFor(pair);
    final tokenAmt = isBuy ? out : _inAmt;
    context.read<PortfolioProvider>().placeOrder(
      pair: pair,
      isBuy: isBuy,
      orderType: 'Convert',
      price: pair.price,
      amount: tokenAmt,
    );
    final msg = isBuy
        ? 'Converted ${fmtCompactUsd(_inAmt * quoteUsd)} → ${fmtCompactNum(out)} ${pair.base.symbol}'
        : 'Converted ${fmtCompactNum(_inAmt)} ${pair.base.symbol} → ${fmtCompactUsd(out * quoteUsd)}';
    showToast(context, msg);
    fromCtrl.clear();
    setState(() {
      _submitting = false;
      _swapStep = null;
      _swapError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final wallet = context.watch<WalletProvider>().activeWallet;
    final pair =
        selectedPair ??
        market.activePair ??
        (market.visibleMarketRows.isNotEmpty
            ? market.visibleMarketRows.first
            : null);
    _schedulePairBalIfNeeded(pair, wallet);
    final chainSlug = _pickedChainSlug ?? pair?.chain ?? kDexChains.keys.first;
    final ci = chainInfoFor(chainSlug);
    final tokSym = pair?.base.symbol ?? 'TOKEN';
    final quoteSym = pair?.quote.symbol ?? 'USDT';
    final fromSym = isBuy ? quoteSym : tokSym;
    final toSym = isBuy ? tokSym : quoteSym;
    final outAmt = _outAmtFor(pair);
    final livePairBal = pair != null
        ? portfolio.pairBalancesFor(wallet?.ethAddress, pair.key)
        : const PairWalletBalances();
    final chainBal = livePairBal.loaded
        ? livePairBal.nativeBalance
        : (portfolio.onChainBalances[chainSlug] ?? 0.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 20),
      children: [
        if (wallet != null) ...[
          const ActiveWalletStrip(),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const FIcon(
                              Flaticons.trade,
                              size: 16,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Convert & Instant Swap',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: p.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Zero-slippage instant conversion or direct on-chain DEX router swap',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '0.10%\nFee',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Network',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: _pickChain,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: p.field,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    children: [
                      ChainBadge(chainSlug, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${ci.name} (${ci.symbol})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                      ),
                      FIcon(
                        Flaticons.chevronDown,
                        size: 14,
                        color: p.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: p.field,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'From (Pay)',
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            wallet == null
                                ? 'Wallet: Not connected'
                                : (isBuy
                                      ? 'Bal: ${livePairBal.quoteBalance.toStringAsFixed(4)} $quoteSym · ${chainBal.toStringAsFixed(4)} ${ci.symbol}'
                                      : 'Holding: ${fmtCompactNum(livePairBal.baseBalance)} $tokSym'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromCtrl,
                            onChanged: (_) => setState(() => _swapError = null),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: numStyle(fontSize: 20, color: p.text),
                            decoration: const InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: '0.00',
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!isBuy) {
                              showLivePairPickerSheet(context, (picked) {
                                setState(() {
                                  selectedPair = picked;
                                  _pickedChainSlug = picked.chain;
                                });
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: p.cardAlt,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: p.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  fromSym,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.text,
                                  ),
                                ),
                                if (!isBuy) ...[
                                  const SizedBox(width: 4),
                                  FIcon(
                                    Flaticons.chevronDown,
                                    size: 12,
                                    color: p.textMuted,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isBuy = !isBuy;
                      _swapError = null;
                      _swapStep = null;
                    }),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.cardAlt,
                        border: Border.all(color: p.border, width: 1.5),
                      ),
                      child: Center(
                        child: FIcon(Flaticons.trade, size: 14, color: p.text),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -8),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: p.field,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: p.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'To (Receive Estimated)',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: p.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                pair != null
                                    ? '1 ${pair.base.symbol} ≈ ${fmtDexPrice(pair.price)}'
                                    : 'Select Token',
                                style: numStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showLivePairPickerSheet(context, (picked) {
                            setState(() {
                              selectedPair = picked;
                              _pickedChainSlug = picked.chain;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: p.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pair != null
                                      ? '${pair.base.symbol} (${shortHex(pair.base.address)})'
                                      : 'Choose live pool token…',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: p.text,
                                  ),
                                ),
                              ),
                              FIcon(
                                Flaticons.chevronDown,
                                size: 12,
                                color: p.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              outAmt > 0 ? fmtCompactNum(outAmt) : '0.00',
                              style: numStyle(fontSize: 20, color: p.text),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showLivePairPickerSheet(context, (picked) {
                                setState(() {
                                  selectedPair = picked;
                                  _pickedChainSlug = picked.chain;
                                });
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: p.cardAlt,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: p.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (pair != null && isBuy) ...[
                                    TokenAvatar(
                                      symbol: pair.base.symbol,
                                      imageUrl: pair.base.image,
                                      fallbackColor: ci.color,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                  Text(
                                    toSym,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.text,
                                    ),
                                  ),
                                  if (isBuy) ...[
                                    const SizedBox(width: 4),
                                    FIcon(
                                      Flaticons.chevronDown,
                                      size: 12,
                                      color: p.textMuted,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (pair != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: p.field,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.border),
                  ),
                  child: Column(
                    children: [
                      _metaRow(p, 'Live Pool', pair.pairLabel),
                      const SizedBox(height: 4),
                      _metaRow(
                        p,
                        'DEX & Liquidity',
                        '${pair.dex.toUpperCase()} · ${fmtCompactUsd(pair.liquidity, decimals: 1)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_swapError != null) ...[
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Text(
                    _swapError!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      color: p.isDark
                          ? const Color(0xFFFF6B7A)
                          : const Color(0xFFC81E2B),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_swapStep != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _swapStep!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: p.isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              GradientButton(
                label: _submitting ? 'Checking Wallet…' : 'Instant Convert Now',
                icon: Flaticons.trade,
                height: 42,
                onPressed: _submitting
                    ? null
                    : () => _executeConvert(pair, market),
              ),
              if (widget.onOpenTrade != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: widget.onOpenTrade,
                    child: const Text(
                      'Open Full Spot Trading Terminal & Chart →',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaRow(AppPalette p, String k, String v) => Row(
    children: [
      Text(k, style: TextStyle(fontSize: 11, color: p.textMuted)),
      const Spacer(),
      Flexible(
        child: Text(
          v,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: numStyle(fontSize: 11, color: p.text),
        ),
      ),
    ],
  );
}
