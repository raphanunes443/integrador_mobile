import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BannerAlerta extends StatelessWidget {
  final String texto;
  final bool sucesso;
  const BannerAlerta({super.key, required this.texto, this.sucesso = false});

  @override
  Widget build(BuildContext context) {
    final bg = sucesso ? AppColors.successBg : AppColors.dangerBg;
    final fg = sucesso ? AppColors.successText : AppColors.dangerText;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(sucesso ? Icons.check_circle : Icons.error, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}