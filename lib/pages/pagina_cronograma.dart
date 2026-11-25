import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/sistema_state.dart';
import '../widgets/card_painel.dart';
import '../widgets/shell_layout.dart';

class PaginaCronograma extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaCronograma({super.key, required this.onNavegar});
  @override
  State<PaginaCronograma> createState() => _PaginaCronogramaState();
}

class _PaginaCronogramaState extends State<PaginaCronograma> {
  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/cronograma', titulo: 'Cronograma de Aulas',
      subtitulo: 'Programação completa de horários e ensalamento',
      icone: Icons.calendar_month, onNavegar: widget.onNavegar,
      child: CardPainel(
        child: state.aulas.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Nenhuma aula agendada.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [DataColumn(label: Text('DATA')), DataColumn(label: Text('INÍCIO')), DataColumn(label: Text('FIM')), DataColumn(label: Text('TURNO')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('AÇÃO'))],
                  rows: state.aulas.map((a) {
                    final status = (a['status_aula'] ?? '').toString();
                    return DataRow(cells: [
                      DataCell(Text((a['data_aula'] ?? '').toString())),
                      DataCell(Text((a['horario_inicio'] ?? '').toString())),
                      DataCell(Text((a['horario_fim'] ?? '').toString())),
                      DataCell(Text((a['turno'] ?? '').toString())),
                      DataCell(Text(status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(status == 'agendada'
                        ? TextButton(
                            onPressed: () async { await state.marcarAulaRealizada(a['id_aula'] as int); if (mounted) setState(() {}); },
                            child: const Text('Marcar realizada', style: TextStyle(color: AppColors.success)),
                          )
                        : const Text('—')),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}