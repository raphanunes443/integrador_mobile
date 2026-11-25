import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/banner_alerta.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaCoordenador extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaCoordenador({super.key, required this.onNavegar});
  @override
  State<PaginaCoordenador> createState() => _PaginaCoordenadorState();
}

class _PaginaCoordenadorState extends State<PaginaCoordenador> {
  final Set<int> _selAtrasadas = {};
  String? _msg;

  DateTime _parseDate(dynamic v) {
    try { return DateTime.parse(v.toString()); } catch (_) { return DateTime(2000); }
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final hojeStr = hoje.toIso8601String().substring(0, 10);
    final aulasUnidade = state.idUnidadeAtiva == null ? state.aulas : state.aulas.where((a) => a['id_unidade'] == state.idUnidadeAtiva).toList();
    
    final aulasHoje = aulasUnidade.where((a) => a['data_aula'].toString().startsWith(hojeStr)).toList();
    final concluidasHoje = aulasHoje.where((a) => a['status_aula'] == 'realizada').length;
    final atrasadas = aulasUnidade.where((a) {
      if (a['status_aula'] != 'agendada') return false;
      return _parseDate(a['data_aula']).isBefore(DateTime(hoje.year, hoje.month, hoje.day));
    }).toList();
    final aguardando = aulasUnidade.where((a) => a['status_aula'] == 'aguardando_remarcacao').toList();

    return ShellLayout(
      rotaAtiva: '/coordenador', titulo: 'Painel do Coordenador',
      subtitulo: 'Gestão de Aulas e Progresso dos Cursos - ${state.nomeUnidadeAtiva}',
      icone: Icons.admin_panel_settings, onNavegar: widget.onNavegar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_msg != null) BannerAlerta(texto: _msg!, sucesso: true),
          Wrap(
            spacing: 16, runSpacing: 16,
            children: [
              _resumo('${aulasHoje.length}', 'Total Aulas Hoje', Icons.book, AppColors.primary),
              _resumo('$concluidasHoje', 'Concluídas Hoje', Icons.check_circle, AppColors.success),
              _resumo('${aulasHoje.length - concluidasHoje}', 'Pendentes Hoje', Icons.access_time, AppColors.warning),
              _resumo('${aguardando.length}', 'Aguardando Remarcação', Icons.hourglass_bottom, Colors.orange),
              _resumo('${atrasadas.length}', 'Aulas Atrasadas', Icons.warning, AppColors.danger),
            ],
          ),
          const SizedBox(height: 24),
          CardPainel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aulas de Hoje - $hojeStr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (aulasHoje.isEmpty)
                  const Padding(padding: EdgeInsets.all(12), child: Text('Nenhuma aula agendada para hoje.'))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [DataColumn(label: Text('CURSO')), DataColumn(label: Text('TURNO')), DataColumn(label: Text('INÍCIO')), DataColumn(label: Text('FIM')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('AÇÃO'))],
                      rows: aulasHoje.map((a) {
                        final ok = a['status_aula'] == 'realizada';
                        return DataRow(cells: [
                          DataCell(Text('Curso #${a['id_curso']}', style: const TextStyle(fontWeight: FontWeight.w700))),
                          DataCell(Text((a['turno'] ?? '').toString())),
                          DataCell(Text((a['horario_inicio'] ?? '').toString())),
                          DataCell(Text((a['horario_fim'] ?? '').toString())),
                          DataCell(_badge(ok ? 'Concluída' : 'Pendente', ok ? AppColors.success : AppColors.warning)),
                          DataCell(ok ? const Text('—') : TextButton(onPressed: () async { await state.marcarAulaRealizada(a['id_aula'] as int); if (mounted) setState(() {}); }, child: const Text('Concluir', style: TextStyle(color: AppColors.success)))),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          if (atrasadas.isNotEmpty)
            CardPainel(
              borda: AppColors.danger, fundo: const Color(0xFFFFF5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aulas Anteriores Não Concluídas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  const SizedBox(height: 8),
                  ...atrasadas.map((a) {
                    final idAula = a['id_aula'] as int;
                    return CheckboxListTile(
                      value: _selAtrasadas.contains(idAula),
                      onChanged: (v) => setState(() => v! ? _selAtrasadas.add(idAula) : _selAtrasadas.remove(idAula)),
                      title: Text('Curso #${a['id_curso']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Data: ${a['data_aula']} | Turno: ${a['turno']}'),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _selAtrasadas.isEmpty ? null : () async {
                      for (final id in _selAtrasadas) { await state.marcarAulaRealizada(id); }
                      if (!mounted) return;
                      setState(() { _msg = '${_selAtrasadas.length} aula(s) concluída(s)!'; _selAtrasadas.clear(); });
                    },
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Concluir Selecionadas'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          CardPainel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progresso dos Cursos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                if (state.cursos.isEmpty)
                  const Text('Nenhum curso cadastrado.')
                else
                  ...state.cursos.map((c) {
                    final total = (c['carga_horaria_curso'] ?? 0) as num;
                    final perc = (c['percentual_conclusao'] ?? 0).toDouble();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((c['nome_curso'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700)), Text('Carga: ${total}h', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))])),
                          Expanded(flex: 2, child: LinearProgressIndicator(value: (perc / 100).clamp(0.0, 1.0), minHeight: 8, borderRadius: BorderRadius.circular(4), color: perc >= 80 ? AppColors.success : AppColors.warning)),
                          const SizedBox(width: 12),
                          Text('${perc.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumo(String n, String l, IconData i, Color c) => Container(
    width: 195, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEBF0F8))),
    child: Row(
      children: [
        CircleAvatar(backgroundColor: c.withOpacity(0.15), child: Icon(i, color: c)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)), Text(l, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))])),
      ],
    ),
  );

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(60)),
    child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
  );
}