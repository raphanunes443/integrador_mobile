import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/sistema_state.dart';

class ShellLayout extends StatelessWidget {
  final String rotaAtiva, titulo, subtitulo;
  final IconData icone;
  final Function(String) onNavegar;
  final List<Widget>? acoesHeader;
  final Widget child;

  const ShellLayout({
    super.key, required this.rotaAtiva, required this.titulo, required this.subtitulo,
    required this.icone, required this.onNavegar, this.acoesHeader, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 860;
    final unidadesAtivas = state.unidades.where((u) => u['status_unidade'] == 'ativo').toList();
    final idsAtivos = unidadesAtivas.map((u) => u['id_unidade']).toList();
    final valorSel = idsAtivos.contains(state.idUnidadeAtiva)
        ? state.idUnidadeAtiva
        : (idsAtivos.isNotEmpty ? idsAtivos.first as int : null);

    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      drawer: isDesktop ? null : Drawer(child: _Sidebar(rotaAtiva: rotaAtiva, onNavegar: onNavegar)),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFE8EDF5)))),
              child: _Sidebar(rotaAtiva: rotaAtiva, onNavegar: onNavegar),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16, runSpacing: 12,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icone, color: AppColors.primary, size: 24),
                              const SizedBox(width: 10),
                              Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(subtitulo, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (valorSel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60), border: Border.all(color: AppColors.border)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: valorSel,
                                  icon: const Icon(Icons.swap_horiz, size: 18, color: AppColors.primary),
                                  items: unidadesAtivas.map((u) => DropdownMenuItem<int>(
                                    value: u['id_unidade'] as int,
                                    child: Text(u['nome_unidade'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  )).toList(),
                                  onChanged: (v) { if (v != null) state.trocarUnidade(v); },
                                ),
                              ),
                            ),
                          if (acoesHeader != null) ...[const SizedBox(width: 12), ...acoesHeader!],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String rotaAtiva;
  final Function(String) onNavegar;
  const _Sidebar({required this.rotaAtiva, required this.onNavegar});

  @override
  Widget build(BuildContext context) {
    final atrasadas = state.aulas.where((a) => a['status_aula'] == 'agendada' && DateTime.parse(a['data_aula'].toString()).isBefore(DateTime.now())).length;

    return Container(
      width: 265, color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.meeting_room, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Siga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Sistema Multi-Tenant', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: AppColors.bgMain, thickness: 2),
          Expanded(
            child: ListView(
              children: [
                _nav(context, Icons.pie_chart, 'Dashboard', '/dashboard'),
                _nav(context, Icons.admin_panel_settings, 'Painel Coordenador', '/coordenador', badge: atrasadas > 0 ? '$atrasadas' : null),
                const Padding(padding: EdgeInsets.fromLTRB(14, 14, 14, 6), child: Text('CADASTROS & AMBIENTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9AABBF)))),
                _nav(context, Icons.business, 'Unidades', '/unidades'),
                _nav(context, Icons.door_front_door, 'Salas', '/salas'),
                _nav(context, Icons.book, 'Cursos', '/cursos'),
                _nav(context, Icons.calendar_month, 'Cronograma Aulas', '/cronograma'),
                _nav(context, Icons.map, 'Mapa de Salas', '/mapa'),
                _nav(context, Icons.event_busy, 'Recessos', '/recessos'),
                const Padding(padding: EdgeInsets.fromLTRB(14, 14, 14, 6), child: Text('ADMINISTRAÇÃO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9AABBF)))),
                _nav(context, Icons.people, 'Usuários (ADM)', '/usuarios'),
                _nav(context, Icons.key, 'Alterar Senha', '/resetar-senha'),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: const Color(0xFFEEF2F9), child: Text(state.nomeUsuario.isNotEmpty ? state.nomeUsuario[0].toUpperCase() : '?')),
            title: Text(state.nomeUsuario, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(state.nomeCliente, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () { state.logout(); onNavegar('/login'); },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(BuildContext context, IconData icon, String label, String rota, {String? badge}) {
    final ativo = rotaAtiva == rota;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: () {
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) Navigator.pop(context);
          onNavegar(rota);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: ativo ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(icon, size: 18, color: ativo ? Colors.white : const Color(0xFF8A9BB5)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ativo ? Colors.white : const Color(0xFF5A6A7E)))),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(60)),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}