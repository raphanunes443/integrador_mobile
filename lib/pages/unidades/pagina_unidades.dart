import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaUnidades extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaUnidades({super.key, required this.onNavegar});
  @override
  State<PaginaUnidades> createState() => _PaginaUnidadesState();
}

class _PaginaUnidadesState extends State<PaginaUnidades> {
  void _novaUnidade() {
    final nomeCtrl = TextEditingController();
    final cidadeCtrl = TextEditingController();
    final estadoCtrl = TextEditingController(text: 'MG');
    final endCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cadastrar Unidade'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome da Unidade')),
              TextField(controller: cidadeCtrl, decoration: const InputDecoration(labelText: 'Cidade')),
              TextField(controller: estadoCtrl, maxLength: 2, decoration: const InputDecoration(labelText: 'UF (ex: MG)')),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Endereço')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nomeCtrl.text.isEmpty || cidadeCtrl.text.isEmpty || estadoCtrl.text.isEmpty || endCtrl.text.isEmpty) return;
              final ok = await state.criarUnidade(nome: nomeCtrl.text.trim(), cidade: cidadeCtrl.text.trim(), estado: estadoCtrl.text.trim().toUpperCase(), endereco: endCtrl.text.trim());
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
    return ShellLayout(
      rotaAtiva: '/unidades', titulo: 'Unidades',
      subtitulo: 'Gerencie as filiais e unidades da sua organização',
      icone: Icons.business, onNavegar: widget.onNavegar,
      acoesHeader: [
        ElevatedButton.icon(onPressed: _novaUnidade, icon: const Icon(Icons.add, size: 16), label: const Text('Nova Unidade'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
      ],
      child: CardPainel(
        child: state.carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [DataColumn(label: Text('UNIDADE')), DataColumn(label: Text('CIDADE / UF')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('AÇÕES'))],
                  rows: state.unidades.map((u) {
                    final ativo = u['status_unidade'] == 'ativo';
                    return DataRow(cells: [
                      DataCell(Text((u['nome_unidade'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text('${u['cidade_unidade'] ?? ''} - ${u['estado_unidade'] ?? ''}')),
                      DataCell(Text(ativo ? 'Ativa' : 'Inativa', style: TextStyle(color: ativo ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w600))),
                      DataCell(TextButton(
                        onPressed: () async { await state.toggleUnidade(u); if (mounted) setState(() {}); },
                        child: Text(ativo ? 'Inativar' : 'Ativar'),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}