import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaSalas extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaSalas({super.key, required this.onNavegar});
  @override
  State<PaginaSalas> createState() => _PaginaSalasState();
}

class _PaginaSalasState extends State<PaginaSalas> {
  void _novaSala() {
    final numCtrl = TextEditingController();
    final tipoCtrl = TextEditingController(text: 'Sala Aula');
    final capCtrl = TextEditingController(text: '30');
    final andarCtrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cadastrar Sala'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: numCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Número da Sala')),
              TextField(controller: tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo')),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacidade')),
              TextField(controller: andarCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Andar')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final num = int.tryParse(numCtrl.text);
              final cap = int.tryParse(capCtrl.text);
              final andar = int.tryParse(andarCtrl.text) ?? 1;
              if (num == null || cap == null) return;
              final ok = await state.criarSala(numero: num, tipo: tipoCtrl.text.trim().isEmpty ? 'Sala Aula' : tipoCtrl.text.trim(), capacidade: cap, andar: andar);
              if (context.mounted) Navigator.pop(context);
              if (ok && mounted) setState(() {});
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salasUnidade = state.idUnidadeAtiva == null ? state.salas : state.salas.where((s) => s['id_unidade'] == state.idUnidadeAtiva).toList();

    return ShellLayout(
      rotaAtiva: '/salas', titulo: 'Salas e Ambientes',
      subtitulo: 'Ambientes cadastrados na ${state.nomeUnidadeAtiva}',
      icone: Icons.door_front_door, onNavegar: widget.onNavegar,
      acoesHeader: [
        ElevatedButton.icon(onPressed: _novaSala, icon: const Icon(Icons.add, size: 16), label: const Text('Nova Sala'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
      ],
      child: CardPainel(
        child: salasUnidade.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Nenhuma sala cadastrada nesta unidade.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [DataColumn(label: Text('SALA')), DataColumn(label: Text('TIPO')), DataColumn(label: Text('CAPACIDADE')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('EXCLUIR'))],
                  rows: salasUnidade.map((s) {
                    return DataRow(cells: [
                      DataCell(Text('Sala ${s['numero_sala']} (Andar ${s['andar_sala']})', style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text((s['tipo_sala'] ?? '').toString())),
                      DataCell(Text('${s['capacidade_sala']} lugares')),
                      DataCell(Text((s['status_sala'] ?? '').toString().toUpperCase())),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.danger, size: 18),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir sala?'),
                              content: Text('Deseja excluir a sala ${s['numero_sala']}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirm == true) { await state.deletarSala(s['id_sala'] as int); if (mounted) setState(() {}); }
                        },
                      )),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}