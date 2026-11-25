import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaUsuariosAdm extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaUsuariosAdm({super.key, required this.onNavegar});
  @override
  State<PaginaUsuariosAdm> createState() => _PaginaUsuariosAdmState();
}

class _PaginaUsuariosAdmState extends State<PaginaUsuariosAdm> {
  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/usuarios', titulo: 'Gestão de Usuários (ADM)',
      subtitulo: 'Aprovação, bloqueio e controle de perfis da organização',
      icone: Icons.people, onNavegar: widget.onNavegar,
      child: CardPainel(
        child: state.usuarios.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Nenhum usuário cadastrado.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [DataColumn(label: Text('USUÁRIO')), DataColumn(label: Text('E-MAIL')), DataColumn(label: Text('PERFIL')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('AÇÕES'))],
                  rows: state.usuarios.map((u) {
                    final st = (u['status_usuario'] ?? '').toString();
                    final ehEu = u['id_usuario'] == state.idUsuario;
                    return DataRow(cells: [
                      DataCell(Text((u['nome_usuario'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text((u['email_usuario'] ?? '').toString())),
                      DataCell(Text((u['tipo_usuario'] ?? '').toString())),
                      DataCell(Text(st.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, color: st == 'ativo' ? AppColors.success : (st == 'pendente' || st == 'inativo' ? AppColors.warning : AppColors.danger)))),
                      DataCell(ehEu
                        ? const Text('—')
                        : Row(
                            children: [
                              if (st == 'pendente' || st == 'inativo')
                                TextButton(onPressed: () async { await state.alterarStatusUsuario(u['id_usuario'] as int, 'ativo'); if (mounted) setState(() {}); }, child: const Text('Aprovar', style: TextStyle(color: AppColors.success))),
                              if (st == 'ativo')
                                TextButton(onPressed: () async { await state.alterarStatusUsuario(u['id_usuario'] as int, 'bloqueado'); if (mounted) setState(() {}); }, child: const Text('Bloquear', style: TextStyle(color: AppColors.danger))),
                              if (st == 'bloqueado')
                                TextButton(onPressed: () async { await state.alterarStatusUsuario(u['id_usuario'] as int, 'ativo'); if (mounted) setState(() {}); }, child: const Text('Desbloquear', style: TextStyle(color: AppColors.primary))),
                            ],
                          )),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}