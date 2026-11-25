import 'package:flutter/material.dart';

class CardPainel extends StatelessWidget {
  final Widget child;
  final Color? borda, fundo;
  const CardPainel({super.key, required this.child, this.borda, this.fundo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: fundo ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borda ?? const Color(0xFFEBF0F8)),
      ),
      child: child,
    );
  }
}