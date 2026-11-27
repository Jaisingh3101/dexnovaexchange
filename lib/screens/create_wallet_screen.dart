import 'package:bip39_plus/bip39_plus.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'main_shell.dart';

class CreateWalletScreen extends StatefulWidget {
  final int initialTab; // 0 = Create Wallet, 1 = Recover Wallet
  final bool enterShellOnComplete;
  const CreateWalletScreen({
    super.key,
    this.initialTab = 0,
    this.enterShellOnComplete = false,
  });

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  late int tab = widget.initialTab;

  // Create tab state
  final createNameCtrl = TextEditingController(text: 'DexNova Vault');
  int wordCount = 12; // 12 or 24
  late List<String> words = _createMnemonic(wordCount);
  bool hideWords = false;
  bool backedUp = false;
  String? pick3;
  String? pick9;

  // Recover tab state
  int importMode = 0; // 0 = 12-word, 1 = 24-word, 2 = Private Key
  final recoverNameCtrl = TextEditingController(text: 'Recovered Vault');
  final phraseCtrl = TextEditingController();

  List<String> _createMnemonic(int count) =>
      bip39.generateMnemonic(strength: count == 24 ? 256 : 128).split(' ');

  @override
  void dispose() {
    createNameCtrl.dispose();
    recoverNameCtrl.dispose();
    phraseCtrl.dispose();
    super.dispose();
  }

  void _skipOrDone({String? toastMsg}) {
    if (toastMsg != null) showToast(context, toastMsg);
    if (widget.enterShellOnComplete) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _setWordCount(int count) {
    if (wordCount == count) return;
    setState(() {
      wordCount = count;
      _generateWords(silent: true);
    });
  }

  void _generateWords({bool silent = false}) {
    setState(() {
      words = _createMnemonic(wordCount);
      backedUp = false;
      pick3 = null;
      pick9 = null;
    });
    if (!silent) {
      showToast(context, 'Generated new $wordCount-word seed phrase');
    }
  }

  List<String> _choicesFor(int idx) {
    final target = words[idx];
    final decoys = words.where((w) => w != target).take(2).toList();
    final list = [target, ...decoys];
    // Deterministic order based on word hash so UI doesn't jump
    list.sort((a, b) => (a.hashCode ^ idx).compareTo(b.hashCode ^ idx));
    return list;
  }

  bool get _challengeVerified => pick3 == words[2] && pick9 == words[8];

  int get _enteredWordCount {
    final t = phraseCtrl.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  int get _expectedCount => importMode == 0 ? 12 : (importMode == 1 ? 24 : 1);

  bool get _recoverValid {
    final raw = phraseCtrl.text.trim();
    if (importMode == 2) {
      final hex = raw.startsWith('0x') ? raw.substring(2) : raw;
      return hex.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
    }
    return _enteredWordCount == _expectedCount;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 Wallet'),
        actions: [
          GestureDetector(
            onTap: () => _skipOrDone(
              toastMsg: 'Skipped — connect wallet anytime in Settings',
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: p.cardAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.border),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
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
          _tabSwitcher(p),
          const SizedBox(height: 10),
          if (tab == 0) ..._buildCreate(p) else ..._buildRecover(p),
        ],
      ),
    );
  }

  Widget _tabSwitcher(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          _tabItem(p, 0, 'Create Wallet', Flaticons.addWallet),
          _tabItem(p, 1, 'Recover Wallet', Flaticons.recoverWallet),
        ],
      ),
    );
  }

  Widget _tabItem(AppPalette p, int i, String label, Flaticons icon) {
    final sel = tab == i;
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : p.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCreate(AppPalette p) {
    final derived = deriveMultiChainAddresses(words.join(' '));
    final shortEth =
        '${derived.eth.substring(0, 6)}...${derived.eth.substring(derived.eth.length - 4)}';
    final shortBtc =
        '${derived.btc.substring(0, 7)}...${derived.btc.substring(derived.btc.length - 4)}';

    return [
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _stepDot(p, '1. Entropy', true)),
            _stepLine(p),
            Flexible(child: _stepDot(p, '2. Backup', true)),
            _stepLine(p),
            Flexible(
              child: _stepDot(p, '3. Verify', backedUp || _challengeVerified),
            ),
          ],
        ),
      ),
      const FieldLabel('Wallet Name & Seed Entropy'),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: createNameCtrl,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
              decoration: InputDecoration(
                hintText: 'Wallet name',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: FIcon(
                    Flaticons.wallet,
                    size: 15,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _entropyChip(p, 12, '12W'),
          const SizedBox(width: 4),
          _entropyChip(p, 24, '24W'),
        ],
      ),
      const SizedBox(height: 8),
      _derivedPreviewCard(
        p,
        eth: shortEth,
        btc: shortBtc,
        subtitle:
            "BIP-44 Path m/44'/60'/0'/0/0 • ${wordCount == 12 ? '128-bit' : '256-bit'}",
      ),
      const SizedBox(height: 8),
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const FIcon(
                  Flaticons.key,
                  size: 14,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$wordCount-Word Secret Phrase',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ),
                _miniIconBtn(
                  p,
                  hideWords ? Flaticons.eye : Flaticons.eyeOff,
                  hideWords ? 'Show' : 'Hide',
                  () => setState(() => hideWords = !hideWords),
                ),
                const SizedBox(width: 4),
                _miniIconBtn(
                  p,
                  Flaticons.refresh,
                  'New',
                  () => _generateWords(),
                ),
                const SizedBox(width: 4),
                _miniIconBtn(p, Flaticons.copy, 'Copy', () {
                  Clipboard.setData(ClipboardData(text: words.join(' ')));
                  showToast(context, '$wordCount-word phrase copied');
                }),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 3.1,
              children: [
                for (var i = 0; i < words.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: p.field,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: p.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${i + 1}.',
                          style: TextStyle(fontSize: 10, color: p.textMuted),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hideWords ? '••••' : words[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FIcon(
                  _challengeVerified
                      ? Flaticons.checkCircle
                      : Flaticons.shieldCheck,
                  size: 14,
                  color: _challengeVerified
                      ? AppColors.green
                      : AppColors.primaryLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Quick Backup Check (Optional or Confirm Below)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            _challengeRow(
              p,
              'Word #3',
              words[2],
              _choicesFor(2),
              pick3,
              (v) => setState(() => pick3 = v),
            ),
            const SizedBox(height: 6),
            _challengeRow(
              p,
              'Word #9',
              words[8],
              _choicesFor(8),
              pick9,
              (v) => setState(() => pick9 = v),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        onTap: () => setState(() => backedUp = !backedUp),
        child: Row(
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: backedUp ? AppColors.green : p.field,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: backedUp ? AppColors.green : p.border,
                ),
              ),
              child: backedUp
                  ? const Center(
                      child: FIcon(
                        Flaticons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I have stored my recovery phrase safely offline',
                style: TextStyle(
                  fontSize: 11.5,
                  color: p.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      GradientButton(
        label: 'Create & Activate Wallet',
        icon: Flaticons.addWallet,
        onPressed: () {
          if (createNameCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter a wallet name');
            return;
          }
          if (!backedUp && !_challengeVerified) {
            showToast(context, 'Verify Word #3 & #9 or check offline backup');
            return;
          }
          final acct = context.read<WalletProvider>().createAndActivateWallet(
            name: createNameCtrl.text,
            words: words,
          );
          _skipOrDone(toastMsg: '${acct.name} active (${acct.shortEth})');
        },
      ),
      const SizedBox(height: 6),
      Center(
        child: TextButton(
          onPressed: () => _skipOrDone(
            toastMsg: 'Skipped — connect wallet anytime in Settings',
          ),
          child: Text(
            'Skip for Now — Browse Exchange',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: p.textSecondary,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _entropyChip(AppPalette p, int count, String label) {
    final sel = wordCount == count;
    return GestureDetector(
      onTap: () => _setWordCount(count),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: sel ? AppColors.primaryGradient : null,
          color: sel ? null : p.card,
          borderRadius: BorderRadius.circular(9),
          border: sel ? null : Border.all(color: p.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: sel ? Colors.white : p.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _challengeRow(
    AppPalette p,
    String title,
    String answer,
    List<String> choices,
    String? selected,
    ValueChanged<String> onPick,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: p.textMuted,
            ),
          ),
        ),
        for (var i = 0; i < choices.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: GestureDetector(
              onTap: () => onPick(choices[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                decoration: BoxDecoration(
                  color: selected == choices[i]
                      ? (choices[i] == answer
                            ? AppColors.green.withValues(alpha: 0.16)
                            : AppColors.red.withValues(alpha: 0.16))
                      : p.field,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected == choices[i]
                        ? (choices[i] == answer
                              ? AppColors.green
                              : AppColors.red)
                        : p.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    choices[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: selected == choices[i]
                          ? (choices[i] == answer
                                ? AppColors.green
                                : AppColors.red)
                          : p.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildRecover(AppPalette p) {
    final valid = _recoverValid;
    final derived = valid
        ? deriveMultiChainAddresses(phraseCtrl.text.trim())
        : null;

    return [
      Row(
        children: [
          for (final entry in [
            (0, '12-Word Seed'),
            (1, '24-Word Seed'),
            (2, 'Private Key'),
          ])
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: entry.$1 < 2 ? 6 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => importMode = entry.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: importMode == entry.$1
                          ? AppColors.primary.withValues(alpha: 0.16)
                          : p.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: importMode == entry.$1
                            ? AppColors.primary
                            : p.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        entry.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: importMode == entry.$1
                              ? AppColors.primaryLight
                              : p.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      const FieldLabel('Wallet Name'),
      TextField(
        controller: recoverNameCtrl,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
        decoration: InputDecoration(
          hintText: 'Recovered Vault',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(9),
            child: FIcon(Flaticons.wallet, size: 16, color: p.textSecondary),
          ),
        ),
      ),
      const FieldLabel('BIP-39 Seed Phrase or Hex Private Key'),
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: phraseCtrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 12.5, color: p.text, height: 1.4),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: importMode == 2
                    ? 'Paste 64-char hex private key (with or without 0x)...'
                    : 'Enter $_expectedCount BIP-39 words separated by spaces...',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _miniIconBtn(p, Flaticons.paste, 'Paste', () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null && data!.text!.isNotEmpty) {
                            setState(() => phraseCtrl.text = data.text!);
                          } else {
                            if (mounted) showToast(context, 'Clipboard empty');
                          }
                        }),
                        const SizedBox(width: 5),
                        _miniIconBtn(p, Flaticons.closeCircle, 'Clear', () {
                          setState(() => phraseCtrl.clear());
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  importMode == 2
                      ? (valid
                            ? '✓ 64-hex'
                            : '${phraseCtrl.text.trim().length} chars')
                      : '${valid ? '✓ ' : ''}$_enteredWordCount/$_expectedCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: valid ? AppColors.green : p.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (derived != null) ...[
        const SizedBox(height: 8),
        _derivedPreviewCard(
          p,
          eth:
              '${derived.eth.substring(0, 6)}...${derived.eth.substring(derived.eth.length - 4)}',
          btc:
              '${derived.btc.substring(0, 7)}...${derived.btc.substring(derived.btc.length - 4)}',
          subtitle: "Derived Multi-Chain Vault • m/44'/60'/0'/0/0",
        ),
      ],
      const SizedBox(height: 8),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const FIcon(
              Flaticons.shieldCheck,
              size: 16,
              color: AppColors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AES-256-GCM Local Vault • BIP-39 / BIP-44 Multi-Chain',
                style: TextStyle(fontSize: 11.5, color: p.textSecondary),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GradientButton(
        label: 'Recover & Connect Wallet',
        icon: Flaticons.recoverWallet,
        onPressed: () {
          if (!valid) {
            showToast(
              context,
              importMode == 2
                  ? 'Enter a valid 64-hex private key'
                  : 'Enter $_expectedCount recovery words',
            );
            return;
          }
          final acct = context.read<WalletProvider>().recoverAndActivateWallet(
            name: recoverNameCtrl.text,
            seedOrKey: phraseCtrl.text,
            isPrivateKey: importMode == 2,
          );
          _skipOrDone(toastMsg: '${acct.name} connected (${acct.shortEth})');
        },
      ),
      const SizedBox(height: 6),
      Center(
        child: TextButton(
          onPressed: () => _skipOrDone(
            toastMsg: 'Skipped — connect wallet anytime in Settings',
          ),
          child: Text(
            'Skip for Now — Browse Exchange',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: p.textSecondary,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _derivedPreviewCard(
    AppPalette p, {
    required String eth,
    required String btc,
    required String subtitle,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FIcon(
                Flaticons.network,
                size: 13,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: p.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _addrPill(p, 'EVM', eth, AppColors.blue)),
              const SizedBox(width: 6),
              Expanded(child: _addrPill(p, 'BTC', btc, AppColors.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addrPill(AppPalette p, String tag, String addr, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: p.field,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: p.border),
    ),
    child: Row(
      children: [
        Text(
          tag,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: c,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            addr,
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
  );

  Widget _stepDot(AppPalette p, String label, bool done) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.primary : p.field,
            border: Border.all(color: done ? AppColors.primary : p.border),
          ),
          child: done
              ? const Center(
                  child: FIcon(Flaticons.check, size: 9, color: Colors.white),
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: done ? p.text : p.textMuted,
          ),
        ),
      ],
    ),
  );

  Widget _stepLine(AppPalette p) => Container(
    width: 14,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    height: 1.5,
    color: p.border,
  );

  Widget _miniIconBtn(
    AppPalette p,
    Flaticons icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: p.cardAlt,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FIcon(icon, size: 12, color: AppColors.primaryLight),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
