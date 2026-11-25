import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/sistema_state.dart';
import '../widgets/card_painel.dart';
import '../widgets/shell_layout.dart';

class PaginaMapaSalas extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaMapaSalas({super.key, required this.onNavegar});
  @override
  State<PaginaMapaSalas> createState() => _PaginaMapaSalasState();
}

class _PaginaMapaSalasState extends State<PaginaMapaSalas> {
  @override
  Widget build(BuildContext context) {
    final salasUnidade = state.idUnidadeAtiva == null ? state.salas : state.salas.where((s) => s['id_unidade'] == state.idUnidadeAtiva).toList();

    return ShellLayout(
      rotaAtiva: '/mapa', titulo: 'Mapa de Salas (Dia)',
      subtitulo: 'Ocupação em tempo real e registro de manutenção',
      icone: Icons.map, onNavegar: widget.onNavegar,
      child: salasUnidade.isEmpty
          ? const CardPainel(child: Padding(padding: EdgeInsets.all(24), child: Text('Nenhuma sala cadastrada nesta unidade.')))
          : Wrap(
              spacing: 20, runSpacing: 20,
              children: salasUnidade.map((s) {
                final status = (s['status_sala'] ?? '').toString();
                Color cor = status == 'disponivel' ? AppColors.success : (status == 'ocupada' ? AppColors.primary : (status == 'manutencao' ? AppColors.warning : AppColors.danger));
                String label = status == 'disponivel' ? 'DISPONÍVEL' : (status == 'ocupada' ? 'EM AULA' : (status == 'manutencao' ? 'MANUTENÇÃO' : 'INATIVA'));

                return Container(
                  width: 260, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: cor, width: 1.5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sala ${s['numero_sala']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: cor.withOpacity(0.15), borderRadius: BorderRadius.circular(60)),
                            child: Text(label, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text((s['tipo_sala'] ?? '').toString(), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text('Capacidade: ${s['capacidade_sala']} alunos', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final novo = status == 'manutencao' ? 'disponivel' : 'manutencao';
                            await state.atualizarStatusSala(s['id_sala'] as int, novo);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.build, size: 15),
                          label: Text(status == 'manutencao' ? 'Liberar Sala' : 'Registrar Manutenção'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}