import 'package:flutter/material.dart';
import '../../core/sistema_state.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaRecessos extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaRecessos({super.key, required this.onNavegar});
  @override
  State<PaginaRecessos> createState() => _PaginaRecessosState();
}

class _PaginaRecessosState extends State<PaginaRecessos> {
  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/recessos', titulo: 'Recessos e Feriados',
      subtitulo: 'Dias sem atividade letiva cadastrados no calendário',
      icone: Icons.event_busy, onNavegar: widget.onNavegar,
      child: CardPainel(
        child: state.recessos.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Nenhum recesso cadastrado.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [DataColumn(label: Text('NOME')), DataColumn(label: Text('INÍCIO')), DataColumn(label: Text('FIM')), DataColumn(label: Text('TIPO'))],
                  rows: state.recessos.map((r) => DataRow(cells: [
                    DataCell(Text((r['nome_recesso'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(Text((r['data_inicio'] ?? '').toString())),
                    DataCell(Text((r['data_fim'] ?? '').toString())),
                    DataCell(Text((r['tipo'] ?? '').toString())),
                  ])).toList(),
                ),
              ),
      ),
    );
  }
}