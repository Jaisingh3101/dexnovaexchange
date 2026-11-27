import 'package:flutter/material.dart';
import '../models/dex_models.dart';
import 'home_screen.dart';

class MarketsScreen extends StatelessWidget {
  final ValueChanged<DexPair>? onOpenPair;
  const MarketsScreen({super.key, this.onOpenPair});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(onOpenPair: onOpenPair);
  }
}
