import 'package:flutter/foundation.dart';

class WalletAccount {
  final String id;
  final int accountIndex;
  final double balanceUsd;
  final String name;
  final String ethAddress;
  final String btcAddress;
  final String solAddress;
  final String tronAddress;
  final List<String>? mnemonic;
  final String derivationPath;
  final String source; // 'Created', 'HD Account', 'Recovered', 'Private Key'

  const WalletAccount({
    required this.id,
    this.accountIndex = 0,
    required this.balanceUsd,
    required this.name,
    required this.ethAddress,
    required this.btcAddress,
    required this.solAddress,
    required this.tronAddress,
    this.mnemonic,
    this.derivationPath = "m/44'/60'/0'/0/0",
    required this.source,
  });

  String shortAddress(String addr) {
    if (addr.length <= 12) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  String get shortEth => shortAddress(ethAddress);
  String get shortBtc => shortAddress(btcAddress);

  String addressFor(String symbol, [String? network]) {
    final s = symbol.toUpperCase();
    final n = (network ?? '').toLowerCase();
    if (s == 'BTC' || n.contains('bitcoin')) return btcAddress;
    if (s == 'SOL' || n.contains('sol')) return solAddress;
    if (s == 'TRX' || n.contains('trc') || n.contains('tron')) {
      return tronAddress;
    }
    return ethAddress;
  }

  String shortAddressFor(String symbol, [String? network]) =>
      shortAddress(addressFor(symbol, network));
}

int _fnvMix(String input, int seed) {
  var h = seed & 0xFFFFFFFF;
  for (final code in input.codeUnits) {
    h ^= code;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  return h;
}

String _hexFromSeed(String seedMaterial, int bytes) {
  final buf = StringBuffer();
  var ctr = 0;
  while (buf.length < bytes * 2) {
    final h = _fnvMix('$seedMaterial:$ctr', 0x811c9dc5 + ctr * 31);
    buf.write(h.toRadixString(16).padLeft(8, '0'));
    ctr++;
  }
  return buf.toString().substring(0, bytes * 2);
}

String _alphabetFromSeed(String seedMaterial, String alphabet, int length) {
  final buf = StringBuffer();
  var ctr = 0;
  while (buf.length < length) {
    var h = _fnvMix('$seedMaterial#$ctr', 0x9e3779b9 + ctr * 97);
    for (var i = 0; i < 6 && buf.length < length; i++) {
      buf.write(alphabet[h % alphabet.length]);
      h = (h ~/ alphabet.length) ^ ((h + 7) * 13);
      if (h < 0) h = -h;
    }
    ctr++;
  }
  return buf.toString();
}

({String eth, String btc, String sol, String tron}) deriveMultiChainAddresses(
  String seedMaterial,
) {
  const bech32 = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
  const base58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  final clean = seedMaterial.trim().toLowerCase();
  final ethHex = _hexFromSeed('eth:$clean', 20);
  final btcBody = _alphabetFromSeed('btc:$clean', bech32, 38);
  final solAddr = _alphabetFromSeed('sol:$clean', base58, 44);
  final tronBody = _alphabetFromSeed('trx:$clean', base58, 33);
  return (
    eth: '0x$ethHex',
    btc: 'bc1q$btcBody',
    sol: solAddr,
    tron: 'T$tronBody',
  );
}

class WalletProvider extends ChangeNotifier {
  final List<WalletAccount> _wallets = [];
  WalletAccount? _activeWallet;
  int _nextWalletCounter = 1;

  List<WalletAccount> get wallets => List.unmodifiable(_wallets);
  WalletAccount? get activeWallet => _activeWallet;
  bool get isConnected => _activeWallet != null;
  bool get hasMnemonic => _wallets.any((w) => w.mnemonic != null);

  WalletAccount _addAndActivate(WalletAccount acct) {
    _wallets.add(acct);
    _activeWallet = acct;
    notifyListeners();
    return acct;
  }

  WalletAccount createAndActivateWallet({
    required String name,
    required List<String> words,
  }) {
    final cleanName = name.trim().isEmpty
        ? 'DexNova Vault ${_wallets.length + 1}'
        : name.trim();
    final seed = words.join(' ');
    final addr = deriveMultiChainAddresses(seed);
    return _addAndActivate(
      WalletAccount(
        id: 'w_${_nextWalletCounter++}',
        accountIndex: 0,
        balanceUsd: 0.0,
        name: cleanName,
        ethAddress: addr.eth,
        btcAddress: addr.btc,
        solAddress: addr.sol,
        tronAddress: addr.tron,
        mnemonic: List.unmodifiable(words),
        source: 'Created',
      ),
    );
  }

  WalletAccount recoverAndActivateWallet({
    required String name,
    required String seedOrKey,
    required bool isPrivateKey,
  }) {
    final clean = seedOrKey.trim().replaceAll(RegExp(r'\s+'), ' ');
    final cleanName = name.trim().isEmpty
        ? 'Recovered Vault ${_wallets.length + 1}'
        : name.trim();
    final addr = deriveMultiChainAddresses(clean);
    return _addAndActivate(
      WalletAccount(
        id: 'w_${_nextWalletCounter++}',
        accountIndex: 0,
        balanceUsd: 0.0,
        name: cleanName,
        ethAddress: addr.eth,
        btcAddress: addr.btc,
        solAddress: addr.sol,
        tronAddress: addr.tron,
        mnemonic: isPrivateKey ? null : clean.split(' '),
        source: isPrivateKey ? 'Private Key' : 'Recovered',
      ),
    );
  }

  WalletAccount? addDerivedHdAccount() {
    final base = (_activeWallet?.mnemonic != null)
        ? _activeWallet!
        : _wallets.cast<WalletAccount?>().firstWhere(
            (w) => w?.mnemonic != null,
            orElse: () => null,
          );
    if (base == null || base.mnemonic == null) return null;

    final nextIdx =
        _wallets.fold<int>(
          0,
          (m, w) => w.accountIndex > m ? w.accountIndex : m,
        ) +
        1;
    final material = '${base.mnemonic!.join(' ')}/acct/$nextIdx';
    final addr = deriveMultiChainAddresses(material);
    return _addAndActivate(
      WalletAccount(
        id: 'w_${_nextWalletCounter++}',
        accountIndex: nextIdx,
        balanceUsd: 0.0,
        name: 'Account #${nextIdx + 1}',
        ethAddress: addr.eth,
        btcAddress: addr.btc,
        solAddress: addr.sol,
        tronAddress: addr.tron,
        mnemonic: base.mnemonic,
        derivationPath: "m/44'/60'/0'/0/$nextIdx",
        source: 'HD Account',
      ),
    );
  }

  void switchWallet(String id) {
    for (final w in _wallets) {
      if (w.id == id) {
        _activeWallet = w;
        notifyListeners();
        return;
      }
    }
  }

  void removeWallet(String id) {
    _wallets.removeWhere((w) => w.id == id);
    if (_activeWallet?.id == id) {
      _activeWallet = _wallets.isNotEmpty ? _wallets.first : null;
    }
    notifyListeners();
  }

  void disconnectWallet() {
    if (_activeWallet == null) return;
    _activeWallet = null;
    notifyListeners();
  }

  void clearAllWallets() {
    _wallets.clear();
    _activeWallet = null;
    _nextWalletCounter = 1;
    notifyListeners();
  }
}
