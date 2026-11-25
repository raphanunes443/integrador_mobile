import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaCursos extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaCursos({super.key, required this.onNavegar});
  @override
  State<PaginaCursos> createState() => _PaginaCursosState();
}

class _PaginaCursosState extends State<PaginaCursos> {
  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/cursos', titulo: 'Cursos',
      subtitulo: 'Grade de cursos ativos na ${state.nomeUnidadeAtiva}',
      icone: Icons.book, onNavegar: widget.onNavegar,
      child: CardPainel(
        child: state.cursos.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Nenhum curso cadastrado.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [DataColumn(label: Text('CÓDIGO')), DataColumn(label: Text('CURSO')), DataColumn(label: Text('CARGA')), DataColumn(label: Text('STATUS'))],
                  rows: state.cursos.map((c) {
                    final ativo = c['status_curso'] == 'ativo';
                    return DataRow(cells: [
                      DataCell(Text((c['numero_curso'] ?? '').toString())),
                      DataCell(Text((c['nome_curso'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text('${c['carga_horaria_curso']}h')),
                      DataCell(TextButton(
                        onPressed: () async { await state.toggleCurso(c); if (mounted) setState(() {}); },
                        child: Text(ativo ? 'Ativo (Inativar)' : 'Inativo (Ativar)'),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}