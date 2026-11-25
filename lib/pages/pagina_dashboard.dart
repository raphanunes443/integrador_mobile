import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/sistema_state.dart';
import '../widgets/card_painel.dart';
import '../widgets/shell_layout.dart';

class PaginaDashboard extends StatelessWidget {
  final Function(String) onNavegar;
  const PaginaDashboard({super.key, required this.onNavegar});

  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/dashboard', titulo: 'Dashboard',
      subtitulo: 'Bem-vindo(a), ${state.nomeUsuario}! (${state.tipoUsuarioFormatado})',
      icone: Icons.pie_chart, onNavegar: onNavegar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _stat('${state.unidades.length}', 'Unidades', Icons.business)),
              const SizedBox(width: 8),
              Expanded(child: _stat('${state.cursos.length}', 'Cursos', Icons.book)),
              const SizedBox(width: 8),
              Expanded(child: _stat('${state.usuarios.length}', 'Usuários', Icons.people)),
              const SizedBox(width: 8),
              Expanded(child: _stat('${state.salas.length}', 'Salas', Icons.door_front_door)),
            ],
          ),
          const SizedBox(height: 28),
          CardPainel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.explore, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('Navegação Rápida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 15, runSpacing: 15,
                  children: [
                    _atalho('Unidades', Icons.business, () => onNavegar('/unidades')),
                    _atalho('Cursos', Icons.book, () => onNavegar('/cursos')),
                    _atalho('Salas', Icons.door_front_door, () => onNavegar('/salas')),
                    _atalho('Cronograma', Icons.calendar_month, () => onNavegar('/cronograma')),
                    _atalho('Mapa de Salas', Icons.map, () => onNavegar('/mapa')),
                    _atalho('Usuários', Icons.people, () => onNavegar('/usuarios')),
                    _atalho('Sair', Icons.logout, () { state.logout(); onNavegar('/login'); }, perigo: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String num, String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEBF0F8))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(num, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.25)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    ),
  );

  Widget _atalho(String nome, IconData icon, VoidCallback tap, {bool perigo = false}) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 145, padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: perigo ? AppColors.danger : const Color(0xFFEEF3FA))),
      child: Column(
        children: [
          Icon(icon, color: perigo ? AppColors.danger : AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(nome, style: TextStyle(fontWeight: FontWeight.w500, color: perigo ? AppColors.danger : AppColors.textBody)),
        ],
      ),
    ),
  );
}