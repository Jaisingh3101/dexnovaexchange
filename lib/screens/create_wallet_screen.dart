import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class CreateWalletScreen extends StatefulWidget {
  final int initialTab; // 0 = Create Wallet, 1 = Recover Wallet
  const CreateWalletScreen({super.key, this.initialTab = 0});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  late int tab = widget.initialTab;

  // Create tab state
  final createNameCtrl = TextEditingController(text: 'DexNova Main Wallet');
  late List<String> words = List.of(recoveryWords);
  bool hideWords = false;
  bool backedUp = false;

  // Recover tab state
  int importMode = 0; // 0 = 12-word, 1 = 24-word, 2 = Private Key
  final recoverNameCtrl = TextEditingController(text: 'Imported Wallet');
  final phraseCtrl = TextEditingController();

  static const _wordPool = [
    'apple',
    'tower',
    'nation',
    'galaxy',
    'flower',
    'bitter',
    'such',
    'during',
    'logic',
    'media',
    'forest',
    'random',
    'silver',
    'orbit',
    'velvet',
    'anchor',
    'quartz',
    'summit',
    'beacon',
    'cipher',
    'harbor',
    'matrix',
    'pulse',
    'zenith',
  ];

  @override
  void dispose() {
    createNameCtrl.dispose();
    recoverNameCtrl.dispose();
    phraseCtrl.dispose();
    super.dispose();
  }

  void _regenerate() {
    final r = Random();
    final pool = List.of(_wordPool)..shuffle(r);
    setState(() {
      words = pool.take(12).toList();
      backedUp = false;
    });
    showToast(context, 'Generated new 12-word phrase');
  }

  int get _enteredWordCount {
    final t = phraseCtrl.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  int get _expectedCount => importMode == 0 ? 12 : (importMode == 1 ? 24 : 1);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create / Recover Wallet'),
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
    return [
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _stepDot(p, '1. Configure', true)),
            _stepLine(p),
            Flexible(child: _stepDot(p, '2. Phrase', true)),
            _stepLine(p),
            Flexible(child: _stepDot(p, '3. Ready', backedUp)),
          ],
        ),
      ),
      const FieldLabel('Wallet Name'),
      TextField(
        controller: createNameCtrl,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
        decoration: InputDecoration(
          hintText: 'Enter wallet name',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(9),
            child: FIcon(Flaticons.wallet, size: 16, color: p.textSecondary),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Text(
            'Multi-Chain:',
            style: TextStyle(
              fontSize: 11.5,
              color: p.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in const ['BTC', 'ETH', 'SOL', 'BNB', 'TRX'])
                    Container(
                      margin: const EdgeInsets.only(right: 5),
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
                        c,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const FIcon(
                  Flaticons.key,
                  size: 15,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '12-Word Secret Phrase',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
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
                _miniIconBtn(p, Flaticons.refresh, 'New', _regenerate),
                const SizedBox(width: 4),
                _miniIconBtn(p, Flaticons.copy, 'Copy', () {
                  Clipboard.setData(ClipboardData(text: words.join(' ')));
                  showToast(context, '12-word phrase copied');
                }),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
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
                          style: TextStyle(fontSize: 10.5, color: p.textMuted),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hideWords ? '••••' : words[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        onTap: () => setState(() => backedUp = !backedUp),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
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
                        size: 13,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I have saved my recovery phrase offline',
                style: TextStyle(
                  fontSize: 12,
                  color: p.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GradientButton(
        label: 'Create New Wallet',
        icon: Flaticons.addWallet,
        onPressed: () {
          if (createNameCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter a wallet name');
            return;
          }
          if (!backedUp) {
            showToast(context, 'Please confirm phrase backup first');
            return;
          }
          showToast(context, 'Wallet "${createNameCtrl.text.trim()}" created');
          Navigator.pop(context);
        },
      ),
    ];
  }

  List<Widget> _buildRecover(AppPalette p) {
    final valid = importMode == 2
        ? phraseCtrl.text.trim().length >= 32
        : _enteredWordCount == _expectedCount;

    return [
      Row(
        children: [
          for (final entry in [
            (0, '12-Word Phrase'),
            (1, '24-Word Phrase'),
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
          hintText: 'Imported Wallet',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(9),
            child: FIcon(Flaticons.wallet, size: 16, color: p.textSecondary),
          ),
        ),
      ),
      const FieldLabel('Recovery Phrase / Key'),
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
                    ? 'Paste your hex private key (0x...)'
                    : 'Enter $_expectedCount words separated by spaces...',
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
                        _miniIconBtn(p, Flaticons.sparkles, 'Demo', () {
                          setState(() {
                            phraseCtrl.text = importMode == 2
                                ? '0x8b4dff5b21d616c784ea3943f59e0b3b82f69d6bff1234abcd5678ef90123456'
                                : importMode == 1
                                ? _wordPool.join(' ')
                                : recoveryWords.join(' ');
                          });
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
                            ? 'Key valid'
                            : '${phraseCtrl.text.trim().length} chars')
                      : '$_enteredWordCount/$_expectedCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: valid ? AppColors.green : p.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                'BIP-39 / BIP-44 Multi-Chain Derivation • Encrypted locally',
                style: TextStyle(fontSize: 11.5, color: p.textSecondary),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      GradientButton(
        label: 'Recover Wallet',
        icon: Flaticons.recoverWallet,
        onPressed: () {
          if (!valid) {
            showToast(
              context,
              importMode == 2
                  ? 'Enter a valid private key'
                  : 'Enter $_expectedCount recovery words',
            );
            return;
          }
          showToast(
            context,
            'Wallet "${recoverNameCtrl.text.trim()}" recovered',
          );
          Navigator.pop(context);
        },
      ),
    ];
  }

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
