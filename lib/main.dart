import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const GerenciadorAmbientesApp());

// ============================================================================
// PALETA DE CORES
// ============================================================================
class AppColors {
  static const Color bgMain = Color(0xFFF0F4FB);
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color textDark = Color(0xFF0E1A2B);
  static const Color textBody = Color(0xFF1A2639);
  static const Color textMuted = Color(0xFF7A8AA0);
  static const Color border = Color(0xFFE2E9F3);
  static const Color inputBg = Color(0xFFFAFCFF);
  static const Color success = Color(0xFF34A853);
  static const Color successText = Color(0xFF1E8546);
  static const Color successBg = Color(0xFFE6F7E9);
  static const Color danger = Color(0xFFDC3545);
  static const Color dangerText = Color(0xFFB33A3A);
  static const Color dangerBg = Color(0xFFFFE9E9);
  static const Color warning = Color(0xFFF9AB00);
}

// ============================================================================
// ESTADO GLOBAL EM MEMÓRIA
// ============================================================================
class SistemaState extends ChangeNotifier {
  bool logado = false;
  String nomeUsuario = 'Administrador';
  String emailUsuario = 'admin@organizacao.com.br';
  String tipoUsuario = 'admin_cliente';
  String nomeCliente = 'Organização Exemplo';
  String senhaAtual = 'Admin@123';
  int tentativasLogin = 0;

  int idUnidadeAtiva = 1;
  String? flashMsg;
  bool flashOk = true;

  final unidades = [
    <String, dynamic>{'id': 1, 'nome': 'Unidade Matriz', 'cidade': 'Belo Horizonte', 'estado': 'MG', 'ativo': true},
    <String, dynamic>{'id': 2, 'nome': 'Unidade Norte', 'cidade': 'Belo Horizonte', 'estado': 'MG', 'ativo': true},
    <String, dynamic>{'id': 3, 'nome': 'Unidade Sul', 'cidade': 'Contagem', 'estado': 'MG', 'ativo': false},
  ];

  final salas = [
    <String, dynamic>{'id': 101, 'numero': 'Lab 01', 'tipo': 'Laboratório Informática', 'capacidade': 30, 'status': 'disponivel'},
    <String, dynamic>{'id': 102, 'numero': 'Sala 204', 'tipo': 'Sala Teórica', 'capacidade': 40, 'status': 'ocupada'},
    <String, dynamic>{'id': 103, 'numero': 'Auditório A', 'tipo': 'Auditório', 'capacidade': 120, 'status': 'manutencao'},
    <String, dynamic>{'id': 104, 'numero': 'Lab 02', 'tipo': 'Laboratório Hardware', 'capacidade': 25, 'status': 'disponivel'},
  ];

  final cursos = [
    <String, dynamic>{'id': 1, 'codigo': 'TDS-01', 'nome': 'Desenvolvimento de Sistemas', 'docente': 'Carlos Silva', 'total': 40, 'realizadas': 28, 'ativo': true},
    <String, dynamic>{'id': 2, 'codigo': 'WEB-02', 'nome': 'Desenvolvimento Web & Dart', 'docente': 'Ana Souza', 'total': 20, 'realizadas': 20, 'ativo': true},
    <String, dynamic>{'id': 3, 'codigo': 'RED-03', 'nome': 'Redes de Computadores', 'docente': 'Marcos Lima', 'total': 30, 'realizadas': 12, 'ativo': true},
  ];

  final aulas = [
    <String, dynamic>{'id': 1, 'curso': 'Desenvolvimento de Sistemas', 'codigo': 'TDS-01', 'prof': 'Carlos Silva', 'sala': 'Lab 01', 'data': '18/11/2026', 'hora': '08:00 - 12:00', 'status': 'agendada', 'atrasada': false, 'diasAtraso': 0},
    <String, dynamic>{'id': 2, 'curso': 'Desenvolvimento Web & Dart', 'codigo': 'WEB-02', 'prof': 'Ana Souza', 'sala': 'Sala 204', 'data': '18/11/2026', 'hora': '13:30 - 17:30', 'status': 'realizada', 'atrasada': false, 'diasAtraso': 0},
    <String, dynamic>{'id': 3, 'curso': 'Redes de Computadores', 'codigo': 'RED-03', 'prof': 'Marcos Lima', 'sala': 'Lab 02', 'data': '18/11/2026', 'hora': '19:00 - 22:00', 'status': 'agendada', 'atrasada': false, 'diasAtraso': 0},
    <String, dynamic>{'id': 4, 'curso': 'Desenvolvimento de Sistemas', 'codigo': 'TDS-01', 'prof': 'Carlos Silva', 'sala': 'Lab 01', 'data': '15/11/2026', 'hora': '08:00 - 12:00', 'status': 'agendada', 'atrasada': true, 'diasAtraso': 3},
    <String, dynamic>{'id': 5, 'curso': 'Redes de Computadores', 'codigo': 'RED-03', 'prof': 'Marcos Lima', 'sala': 'Sala 204', 'data': '16/11/2026', 'hora': '19:00 - 22:00', 'status': 'aguardando_remarcacao', 'atrasada': false, 'diasAtraso': 0},
  ];

  final recessos = [
    <String, dynamic>{'id': 1, 'descricao': 'Proclamação da República', 'inicio': '15/11/2026', 'fim': '15/11/2026', 'tipo': 'Feriado Nacional'},
    <String, dynamic>{'id': 2, 'descricao': 'Recesso Fim de Ano', 'inicio': '23/12/2026', 'fim': '02/01/2027', 'tipo': 'Recesso Escolar'},
  ];

  final usuarios = [
    <String, dynamic>{'id': 1, 'nome': 'Administrador', 'email': 'admin@organizacao.com.br', 'tipo': 'admin_cliente', 'status': 'ativo'},
    <String, dynamic>{'id': 2, 'nome': 'Carlos Silva', 'email': 'carlos@organizacao.com.br', 'tipo': 'gerente', 'status': 'ativo'},
    <String, dynamic>{'id': 3, 'nome': 'João Pendente', 'email': 'joao@organizacao.com.br', 'tipo': 'usuario', 'status': 'inativo'},
    <String, dynamic>{'id': 4, 'nome': 'Maria Bloqueada', 'email': 'maria@organizacao.com.br', 'tipo': 'visualizador', 'status': 'bloqueado'},
  ];

  String get nomeUnidadeAtiva {
    final u = unidades.firstWhere(
      (e) => e['id'] == idUnidadeAtiva,
      orElse: () => <String, dynamic>{'nome': 'Unidade Matriz'},
    );
    return u['nome'].toString();
  }

  String get tipoUsuarioFormatado {
    switch (tipoUsuario) {
      case 'admin_cliente':
        return 'Administrador';
      case 'gerente':
        return 'Coordenador';
      case 'usuario':
        return 'Usuário';
      default:
        return 'Visualizador';
    }
  }

  void trocarUnidade(int novoId) {
    idUnidadeAtiva = novoId;
    notifyListeners();
  }

  String? login(String email, String senha) {
    if (email.isEmpty || senha.isEmpty) return 'Preencha todos os campos.';
    if (tentativasLogin >= 5) {
      return 'Muitas tentativas falhas. Entre em contato com o administrador.';
    }
    if (email == emailUsuario && senha != senhaAtual) {
      tentativasLogin++;
      return 'E-mail ou senha inválidos.';
    }
    tentativasLogin = 0;
    emailUsuario = email;
    logado = true;
    flashMsg = null;
    notifyListeners();
    return null;
  }

  void registrarOrganizacao({
    required String orgNome,
    required String adminNome,
    required String adminEmail,
    required String adminSenha,
  }) {
    nomeCliente = orgNome;
    nomeUsuario = adminNome;
    emailUsuario = adminEmail;
    senhaAtual = adminSenha;
    usuarios[0] = <String, dynamic>{
      'id': 1,
      'nome': adminNome,
      'email': adminEmail,
      'tipo': 'admin_cliente',
      'status': 'ativo',
    };
    setFlash('Cadastro realizado com sucesso! Agora você já pode acessar o sistema.', ok: true);
  }

  void logout() {
    logado = false;
    setFlash('Você saiu do sistema com sucesso.', ok: true);
  }

  void setFlash(String msg, {bool ok = true}) {
    flashMsg = msg;
    flashOk = ok;
    notifyListeners();
  }
}

final state = SistemaState();

// ============================================================================
// APP PRINCIPAL E ROTEAMENTO
// ============================================================================
class GerenciadorAmbientesApp extends StatefulWidget {
  const GerenciadorAmbientesApp({super.key});

  @override
  State<GerenciadorAmbientesApp> createState() => _GerenciadorAmbientesAppState();
}

class _GerenciadorAmbientesAppState extends State<GerenciadorAmbientesApp> {
  String _rota = '/login';

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() => setState(() {});
  void _irPara(String novaRota) => setState(() => _rota = novaRota);

  @override
  Widget build(BuildContext context) {
    Widget pagina;
    if (!state.logado && _rota != '/cadastro') {
      pagina = PaginaLogin(onNavegar: _irPara);
    } else {
      switch (_rota) {
        case '/cadastro':
          pagina = PaginaCadastro(onNavegar: _irPara);
          break;
        case '/coordenador':
          pagina = PaginaCoordenador(onNavegar: _irPara);
          break;
        case '/unidades':
          pagina = PaginaUnidades(onNavegar: _irPara);
          break;
        case '/salas':
          pagina = PaginaSalas(onNavegar: _irPara);
          break;
        case '/cursos':
          pagina = PaginaCursos(onNavegar: _irPara);
          break;
        case '/cronograma':
          pagina = PaginaCronograma(onNavegar: _irPara);
          break;
        case '/mapa':
          pagina = PaginaMapaSalas(onNavegar: _irPara);
          break;
        case '/recessos':
          pagina = PaginaRecessos(onNavegar: _irPara);
          break;
        case '/usuarios':
          pagina = PaginaUsuariosAdm(onNavegar: _irPara);
          break;
        case '/resetar-senha':
          pagina = PaginaResetarSenha(onNavegar: _irPara);
          break;
        case '/dashboard':
        default:
          pagina = PaginaDashboard(onNavegar: _irPara);
      }
    }

    return MaterialApp(
      title: 'Siga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgMain,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: pagina,
    );
  }
}

// ============================================================================
// MÁSCARAS DE INPUT (CNPJ e Telefone)
// ============================================================================
class CnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 14) d = d.substring(0, 14);
    var res = '';
    for (int i = 0; i < d.length; i++) {
      if (i == 2 || i == 5) res += '.';
      if (i == 8) res += '/';
      if (i == 12) res += '-';
      res += d[i];
    }
    return TextEditingValue(text: res, selection: TextSelection.collapsed(offset: res.length));
  }
}

class TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 11) d = d.substring(0, 11);
    var res = '';
    if (d.isNotEmpty) {
      res += '(';
      for (int i = 0; i < d.length; i++) {
        if (i == 2) res += ') ';
        if (d.length <= 10 && i == 6) res += '-';
        if (d.length == 11 && i == 7) res += '-';
        res += d[i];
      }
    }
    return TextEditingValue(text: res, selection: TextSelection.collapsed(offset: res.length));
  }
}

// ============================================================================
// LAYOUT BASE (Sidebar + Seletor de Unidade + Área Principal)
// ============================================================================
class ShellLayout extends StatelessWidget {
  final String rotaAtiva;
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Function(String) onNavegar;
  final List<Widget>? acoesHeader;
  final Widget child;

  const ShellLayout({
    super.key,
    required this.rotaAtiva,
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.onNavegar,
    this.acoesHeader,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 860;
    final unidadesAtivas = state.unidades.where((u) => u['ativo'] == true).toList();

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
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
                    spacing: 16,
                    runSpacing: 12,
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
                          if (unidadesAtivas.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: unidadesAtivas.any((u) => u['id'] == state.idUnidadeAtiva)
                                      ? state.idUnidadeAtiva
                                      : unidadesAtivas.first['id'] as int,
                                  icon: const Icon(Icons.swap_horiz, size: 18, color: AppColors.primary),
                                  items: unidadesAtivas
                                      .map((u) => DropdownMenuItem<int>(
                                            value: u['id'] as int,
                                            child: Text(u['nome'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) state.trocarUnidade(val);
                                  },
                                ),
                              ),
                            ),
                          if (acoesHeader != null) ...[
                            const SizedBox(width: 12),
                            ...acoesHeader!,
                          ],
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
    final atrasadas = state.aulas.where((a) => a['atrasada'] == true && a['status'] == 'agendada').length;

    return Container(
      width: 265,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: Text('CADASTROS & AMBIENTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9AABBF))),
                ),
                _nav(context, Icons.business, 'Unidades', '/unidades'),
                _nav(context, Icons.door_front_door, 'Salas', '/salas'),
                _nav(context, Icons.book, 'Cursos', '/cursos'),
                _nav(context, Icons.calendar_month, 'Cronograma Aulas', '/cronograma'),
                _nav(context, Icons.map, 'Mapa de Salas', '/mapa'),
                _nav(context, Icons.event_busy, 'Recessos', '/recessos'),
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: Text('ADMINISTRAÇÃO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9AABBF))),
                ),
                _nav(context, Icons.people, 'Usuários (ADM)', '/usuarios'),
                _nav(context, Icons.key, 'Alterar Senha', '/resetar-senha'),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: const Color(0xFFEEF2F9), child: Text(state.nomeUsuario[0])),
            title: Text(state.nomeUsuario, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(state.nomeCliente, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                state.logout();
                onNavegar('/login');
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
              ),
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
          decoration: BoxDecoration(
            color: ativo ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: ativo ? Colors.white : const Color(0xFF8A9BB5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ativo ? Colors.white : const Color(0xFF5A6A7E)),
                ),
              ),
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

// ============================================================================
// WIDGETS AUXILIARES (Alertas, Cards)
// ============================================================================
class BannerAlerta extends StatelessWidget {
  final String texto;
  final bool sucesso;
  const BannerAlerta({super.key, required this.texto, this.sucesso = false});

  @override
  Widget build(BuildContext context) {
    final bg = sucesso ? AppColors.successBg : AppColors.dangerBg;
    final fg = sucesso ? AppColors.successText : AppColors.dangerText;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(sucesso ? Icons.check_circle : Icons.error, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class CardPainel extends StatelessWidget {
  final Widget child;
  final Color? borda;
  final Color? fundo;
  const CardPainel({super.key, required this.child, this.borda, this.fundo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: fundo ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borda ?? const Color(0xFFEBF0F8)),
      ),
      child: child,
    );
  }
}

// ============================================================================
// 1. PÁGINA LOGIN
// ============================================================================
class PaginaLogin extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaLogin({super.key, required this.onNavegar});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final _emailCtrl = TextEditingController(text: 'admin@organizacao.com.br');
  final _senhaCtrl = TextEditingController(text: 'Admin@123');
  String? _erro;

  void _entrar() {
    final res = state.login(_emailCtrl.text.trim(), _senhaCtrl.text);
    if (res != null) {
      setState(() => _erro = res);
    } else {
      widget.onNavegar('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.door_front_door, size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text('Siga', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const Text('Gerenciamento de Ambientes', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 24),
                if (_erro != null) BannerAlerta(texto: _erro!),
                if (state.flashMsg != null) BannerAlerta(texto: state.flashMsg!, sucesso: state.flashOk),
                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  onSubmitted: (_) => _entrar(),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _entrar,
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Entrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta? ', style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => widget.onNavegar('/cadastro'),
                      child: const Text('Cadastre-se gratuitamente', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. PÁGINA CADASTRO MULTI-TENANT
// ============================================================================
class PaginaCadastro extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaCadastro({super.key, required this.onNavegar});

  @override
  State<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastro> {
  final _nomeOrg = TextEditingController();
  String _tipo = 'escola';
  final _cnpj = TextEditingController();
  final _emailOrg = TextEditingController();
  final _tel = TextEditingController();
  final _nomeAdm = TextEditingController();
  final _emailAdm = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  bool _verSenha = false;
  String? _erro;

  bool get _tamOk => _senha.text.length >= 6;
  bool get _maiOk => RegExp(r'[A-Z]').hasMatch(_senha.text);
  bool get _minOk => RegExp(r'[a-z]').hasMatch(_senha.text);
  bool get _espOk => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_senha.text);
  bool get _confOk => _confirma.text.isNotEmpty && _senha.text == _confirma.text;

  void _cadastrar() {
    if (_nomeOrg.text.isEmpty || _emailOrg.text.isEmpty || _nomeAdm.text.isEmpty || _emailAdm.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios (*).');
      return;
    }
    if (!(_tamOk && _maiOk && _minOk && _espOk && _confOk)) {
      setState(() => _erro = 'A senha não atende aos requisitos mínimos de segurança.');
      return;
    }
    state.registrarOrganizacao(
      orgNome: _nomeOrg.text.trim(),
      adminNome: _nomeAdm.text.trim(),
      adminEmail: _emailAdm.text.trim(),
      adminSenha: _senha.text,
    );
    widget.onNavegar('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add, size: 42, color: AppColors.primary),
                const SizedBox(height: 6),
                const Text('Criar Conta', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const Text('Siga - Cadastro de Organização', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 20),
                if (_erro != null) BannerAlerta(texto: _erro!),
                _campo('Nome da Organização *', _nomeOrg, 'Ex: Escola São Paulo'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _tipo,
                        decoration: _dec('Tipo'),
                        items: const [
                          DropdownMenuItem(value: 'escola', child: Text('Escola')),
                          DropdownMenuItem(value: 'salão', child: Text('Salão')),
                          DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
                          DropdownMenuItem(value: 'outro', child: Text('Outro')),
                        ],
                        onChanged: (v) => setState(() => _tipo = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _campo('CNPJ', _cnpj, '00.000.000/0000-00', fmt: [CnpjFormatter()])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _campo('E-mail Organização *', _emailOrg, 'contato@org.com')),
                    const SizedBox(width: 12),
                    Expanded(child: _campo('Telefone', _tel, '(00) 00000-0000', fmt: [TelefoneFormatter()])),
                  ],
                ),
                const Divider(height: 32),
                _campo('Nome do Administrador *', _nomeAdm, 'Seu nome completo'),
                const SizedBox(height: 12),
                _campo('E-mail do Administrador *', _emailAdm, 'admin@dominio.com'),
                const SizedBox(height: 12),
                TextField(
                  controller: _senha,
                  obscureText: !_verSenha,
                  onChanged: (_) => setState(() {}),
                  decoration: _dec('Senha *').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_verSenha ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _verSenha = !_verSenha),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    _req('6+ caracteres', _tamOk),
                    _req('Letra maiúscula', _maiOk),
                    _req('Letra minúscula', _minOk),
                    _req('Caractere especial', _espOk),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirma,
                  obscureText: !_verSenha,
                  onChanged: (_) => setState(() {}),
                  decoration: _dec('Confirmar Senha *'),
                ),
                const SizedBox(height: 6),
                _req('As senhas devem coincidir', _confOk),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _cadastrar,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Cadastrar Organização'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                  ),
                ),
                TextButton(onPressed: () => widget.onNavegar('/login'), child: const Text('Já tem uma conta? Faça login')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController c, String hint, {List<TextInputFormatter>? fmt}) =>
      TextField(controller: c, inputFormatters: fmt, decoration: _dec(label).copyWith(hintText: hint));

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _req(String t, bool ok) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check_circle : Icons.circle, size: 12, color: ok ? AppColors.successText : AppColors.dangerText),
          const SizedBox(width: 4),
          Text(t, style: TextStyle(fontSize: 12, color: ok ? AppColors.successText : AppColors.dangerText)),
        ],
      );
}

// ============================================================================
// 3. DASHBOARD (4 CARTÕES LADO A LADO)
// ============================================================================
class PaginaDashboard extends StatelessWidget {
  final Function(String) onNavegar;
  const PaginaDashboard({super.key, required this.onNavegar});

  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/dashboard',
      titulo: 'Dashboard',
      subtitulo: 'Bem-vindo(a), ${state.nomeUsuario}! (${state.tipoUsuarioFormatado})',
      icone: Icons.pie_chart,
      onNavegar: onNavegar,
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
                const Row(
                  children: [
                    Icon(Icons.explore, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('Navegação Rápida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    _atalho('Unidades', Icons.business, () => onNavegar('/unidades')),
                    _atalho('Cursos', Icons.book, () => onNavegar('/cursos')),
                    _atalho('Salas', Icons.door_front_door, () => onNavegar('/salas')),
                    _atalho('Cronograma', Icons.calendar_month, () => onNavegar('/cronograma')),
                    _atalho('Mapa de Salas', Icons.map, () => onNavegar('/mapa')),
                    _atalho('Usuários', Icons.people, () => onNavegar('/usuarios')),
                    _atalho('Sair', Icons.logout, () {
                      state.logout();
                      onNavegar('/login');
                    }, perigo: true),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEBF0F8)),
        ),
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
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      );

  Widget _atalho(String nome, IconData icon, VoidCallback tap, {bool perigo = false}) => InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 145,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: perigo ? AppColors.danger : const Color(0xFFEEF3FA)),
          ),
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

// ============================================================================
// 4. PAINEL DO COORDENADOR
// ============================================================================
class PaginaCoordenador extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaCoordenador({super.key, required this.onNavegar});

  @override
  State<PaginaCoordenador> createState() => _PaginaCoordenadorState();
}

class _PaginaCoordenadorState extends State<PaginaCoordenador> {
  final Set<int> _selHoje = {};
  final Set<int> _selAnt = {};
  String? _msg;

  @override
  Widget build(BuildContext context) {
    final aulasHoje = state.aulas.where((a) => a['data'] == '18/11/2026').toList();
    final concluidasHoje = aulasHoje.where((a) => a['status'] == 'realizada').length;
    final atrasadas = state.aulas.where((a) => a['atrasada'] == true && a['status'] == 'agendada').toList();
    final aguardando = state.aulas.where((a) => a['status'] == 'aguardando_remarcacao').toList();

    return ShellLayout(
      rotaAtiva: '/coordenador',
      titulo: 'Painel do Coordenador',
      subtitulo: 'Gestão de Aulas e Progresso dos Cursos - ${state.nomeUnidadeAtiva}',
      icone: Icons.admin_panel_settings,
      onNavegar: widget.onNavegar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_msg != null) BannerAlerta(texto: _msg!, sucesso: true),
          Wrap(
            spacing: 16,
            runSpacing: 16,
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
                const Text('Aulas do Dia - 18/11/2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('SEL.')),
                      DataColumn(label: Text('CURSO')),
                      DataColumn(label: Text('PROFESSOR')),
                      DataColumn(label: Text('SALA')),
                      DataColumn(label: Text('HORÁRIO')),
                      DataColumn(label: Text('STATUS')),
                    ],
                    rows: aulasHoje.map((a) {
                      final ok = a['status'] == 'realizada';
                      final idAula = a['id'] as int;
                      return DataRow(cells: [
                        DataCell(!ok
                            ? Checkbox(
                                value: _selHoje.contains(idAula),
                                onChanged: (v) => setState(() => v! ? _selHoje.add(idAula) : _selHoje.remove(idAula)),
                              )
                            : const SizedBox.shrink()),
                        DataCell(Text(a['curso'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text(a['prof'].toString())),
                        DataCell(Text(a['sala'].toString())),
                        DataCell(Text(a['hora'].toString())),
                        DataCell(_badge(ok ? 'Concluída' : 'Pendente', ok ? AppColors.success : AppColors.warning)),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_selHoje.isEmpty) return;
                        setState(() {
                          for (var a in state.aulas) {
                            if (_selHoje.contains(a['id'])) a['status'] = 'realizada';
                          }
                          _msg = '${_selHoje.length} aula(s) marcada(s) como concluída(s)!';
                          _selHoje.clear();
                        });
                      },
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Marcar Selecionadas'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          for (var a in aulasHoje) {
                            a['status'] = 'realizada';
                          }
                          _selHoje.clear();
                          _msg = 'Todas as aulas do dia marcadas como concluídas!';
                        });
                      },
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Marcar TODAS do Dia'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (atrasadas.isNotEmpty)
            CardPainel(
              borda: AppColors.danger,
              fundo: const Color(0xFFFFF5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aulas Anteriores Não Concluídas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  ...atrasadas.map((a) {
                    final idAula = a['id'] as int;
                    return CheckboxListTile(
                      value: _selAnt.contains(idAula),
                      onChanged: (v) => setState(() => v! ? _selAnt.add(idAula) : _selAnt.remove(idAula)),
                      title: Text('${a['curso']} - ${a['prof']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Data: ${a['data']} (-${a['diasAtraso']} dias) | ${a['hora']}'),
                    );
                  }),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selAnt.isEmpty) return;
                      setState(() {
                        for (var a in state.aulas) {
                          if (_selAnt.contains(a['id'])) {
                            a['status'] = 'realizada';
                            a['atrasada'] = false;
                          }
                        }
                        _msg = '${_selAnt.length} aula(s) atrasada(s) concluída(s)!';
                        _selAnt.clear();
                      });
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
                ...state.cursos.map((c) {
                  final perc = ((c['realizadas'] as int) / (c['total'] as int)) * 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c['nome'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('Prof. ${c['docente']} (${c['realizadas']}/${c['total']})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ]),
                        ),
                        Expanded(
                          flex: 2,
                          child: LinearProgressIndicator(
                            value: perc / 100,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: perc >= 80 ? AppColors.success : AppColors.warning,
                          ),
                        ),
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
        width: 195,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEBF0F8))),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: c.withOpacity(0.15), child: Icon(i, color: c)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                Text(l, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
            ),
          ],
        ),
      );

  Widget _badge(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(60)),
        child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
      );
}

// ============================================================================
// 5. MÓDULO UNIDADES
// ============================================================================
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cadastrar Unidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome da Unidade')),
            TextField(controller: cidadeCtrl, decoration: const InputDecoration(labelText: 'Cidade')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nomeCtrl.text.isNotEmpty) {
                setState(() {
                  state.unidades.add(<String, dynamic>{
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'nome': nomeCtrl.text,
                    'cidade': cidadeCtrl.text.isEmpty ? 'Belo Horizonte' : cidadeCtrl.text,
                    'estado': 'MG',
                    'ativo': true,
                  });
                });
              }
              Navigator.pop(context);
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
      rotaAtiva: '/unidades',
      titulo: 'Unidades',
      subtitulo: 'Gerencie as filiais e unidades da sua organização',
      icone: Icons.business,
      onNavegar: widget.onNavegar,
      acoesHeader: [
        ElevatedButton.icon(
          onPressed: _novaUnidade,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nova Unidade'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ],
      child: CardPainel(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('UNIDADE')),
              DataColumn(label: Text('CIDADE / UF')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('AÇÕES')),
            ],
            rows: state.unidades.map((u) {
              final ativo = u['ativo'] == true;
              return DataRow(cells: [
                DataCell(Text(u['nome'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text('${u['cidade']} - ${u['estado']}')),
                DataCell(Text(ativo ? 'Ativa' : 'Inativa', style: TextStyle(color: ativo ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w600))),
                DataCell(
                  TextButton(
                    onPressed: () => setState(() => u['ativo'] = !ativo),
                    child: Text(ativo ? 'Inativar' : 'Ativar'),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. MÓDULO SALAS
// ============================================================================
class PaginaSalas extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaSalas({super.key, required this.onNavegar});

  @override
  State<PaginaSalas> createState() => _PaginaSalasState();
}

class _PaginaSalasState extends State<PaginaSalas> {
  void _novaSala() {
    final numCtrl = TextEditingController();
    final tipoCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cadastrar Sala'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'Número / Nome da Sala')),
            TextField(controller: tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo (Ex: Laboratório)')),
            TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacidade')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (numCtrl.text.isNotEmpty) {
                setState(() {
                  state.salas.add(<String, dynamic>{
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'numero': numCtrl.text,
                    'tipo': tipoCtrl.text.isEmpty ? 'Sala Padrão' : tipoCtrl.text,
                    'capacidade': int.tryParse(capCtrl.text) ?? 30,
                    'status': 'disponivel',
                  });
                });
              }
              Navigator.pop(context);
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
      rotaAtiva: '/salas',
      titulo: 'Salas e Ambientes',
      subtitulo: 'Ambientes cadastrados na ${state.nomeUnidadeAtiva}',
      icone: Icons.door_front_door,
      onNavegar: widget.onNavegar,
      acoesHeader: [
        ElevatedButton.icon(
          onPressed: _novaSala,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nova Sala'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ],
      child: CardPainel(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('SALA')),
              DataColumn(label: Text('TIPO')),
              DataColumn(label: Text('CAPACIDADE')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('EXCLUIR')),
            ],
            rows: state.salas.map((s) {
              return DataRow(cells: [
                DataCell(Text(s['numero'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(s['tipo'].toString())),
                DataCell(Text('${s['capacidade']} lugares')),
                DataCell(Text(s['status'].toString().toUpperCase())),
                DataCell(IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.danger, size: 18),
                  onPressed: () => setState(() => state.salas.remove(s)),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 7. MÓDULO CURSOS
// ============================================================================
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
      rotaAtiva: '/cursos',
      titulo: 'Cursos',
      subtitulo: 'Grade de cursos ativos na ${state.nomeUnidadeAtiva}',
      icone: Icons.book,
      onNavegar: widget.onNavegar,
      child: CardPainel(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('CÓDIGO')),
              DataColumn(label: Text('CURSO')),
              DataColumn(label: Text('DOCENTE')),
              DataColumn(label: Text('CARGA')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: state.cursos.map((c) {
              final ativo = c['ativo'] == true;
              return DataRow(cells: [
                DataCell(Text(c['codigo'].toString())),
                DataCell(Text(c['nome'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(c['docente'].toString())),
                DataCell(Text('${c['realizadas']}/${c['total']} aulas')),
                DataCell(
                  TextButton(
                    onPressed: () => setState(() => c['ativo'] = !ativo),
                    child: Text(ativo ? 'Ativo (Inativar)' : 'Inativo (Ativar)'),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 8. MÓDULO CRONOGRAMA DE AULAS
// ============================================================================
class PaginaCronograma extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaCronograma({super.key, required this.onNavegar});

  @override
  State<PaginaCronograma> createState() => _PaginaCronogramaState();
}

class _PaginaCronogramaState extends State<PaginaCronograma> {
  void _agendarAula() {
    final cursoCtrl = TextEditingController(text: 'Desenvolvimento de Sistemas');
    final profCtrl = TextEditingController(text: 'Carlos Silva');
    final salaCtrl = TextEditingController(text: 'Lab 01');
    final horaCtrl = TextEditingController(text: '08:00 - 12:00');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agendar Nova Aula'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cursoCtrl, decoration: const InputDecoration(labelText: 'Curso')),
            TextField(controller: profCtrl, decoration: const InputDecoration(labelText: 'Professor')),
            TextField(controller: salaCtrl, decoration: const InputDecoration(labelText: 'Sala')),
            TextField(controller: horaCtrl, decoration: const InputDecoration(labelText: 'Horário')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                state.aulas.add(<String, dynamic>{
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'curso': cursoCtrl.text,
                  'codigo': 'NEW-01',
                  'prof': profCtrl.text,
                  'sala': salaCtrl.text,
                  'data': '18/11/2026',
                  'hora': horaCtrl.text,
                  'status': 'agendada',
                  'atrasada': false,
                  'diasAtraso': 0,
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Agendar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/cronograma',
      titulo: 'Cronograma de Aulas',
      subtitulo: 'Programação completa de horários e ensalamento',
      icone: Icons.calendar_month,
      onNavegar: widget.onNavegar,
      acoesHeader: [
        ElevatedButton.icon(
          onPressed: _agendarAula,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Agendar Aula'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ],
      child: CardPainel(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('DATA')),
              DataColumn(label: Text('HORÁRIO')),
              DataColumn(label: Text('CURSO')),
              DataColumn(label: Text('PROFESSOR')),
              DataColumn(label: Text('SALA')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: state.aulas.map((a) {
              return DataRow(cells: [
                DataCell(Text(a['data'].toString())),
                DataCell(Text(a['hora'].toString())),
                DataCell(Text(a['curso'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(a['prof'].toString())),
                DataCell(Text(a['sala'].toString())),
                DataCell(Text(a['status'].toString().toUpperCase())),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 9. MÓDULO MAPA DE SALAS
// ============================================================================
class PaginaMapaSalas extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaMapaSalas({super.key, required this.onNavegar});

  @override
  State<PaginaMapaSalas> createState() => _PaginaMapaSalasState();
}

class _PaginaMapaSalasState extends State<PaginaMapaSalas> {
  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/mapa',
      titulo: 'Mapa de Salas (Dia)',
      subtitulo: 'Ocupação em tempo real e registro de manutenção',
      icone: Icons.map,
      onNavegar: widget.onNavegar,
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: state.salas.map((s) {
          final status = s['status'].toString();
          Color cor = status == 'disponivel'
              ? AppColors.success
              : (status == 'ocupada' ? AppColors.primary : AppColors.danger);
          String label = status == 'disponivel'
              ? 'DISPONÍVEL'
              : (status == 'ocupada' ? 'EM AULA' : 'MANUTENÇÃO');

          return Container(
            width: 260,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['numero'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: cor.withOpacity(0.15), borderRadius: BorderRadius.circular(60)),
                      child: Text(label, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(s['tipo'].toString(), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                Text('Capacidade: ${s['capacidade']} alunos', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        s['status'] = status == 'manutencao' ? 'disponivel' : 'manutencao';
                      });
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

// ============================================================================
// 10. MÓDULO RECESSOS
// ============================================================================
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
      rotaAtiva: '/recessos',
      titulo: 'Recessos e Feriados',
      subtitulo: 'Dias sem atividade letiva cadastrados no calendário',
      icone: Icons.event_busy,
      onNavegar: widget.onNavegar,
      child: CardPainel(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('DESCRIÇÃO')),
              DataColumn(label: Text('INÍCIO')),
              DataColumn(label: Text('FIM')),
              DataColumn(label: Text('TIPO')),
            ],
            rows: state.recessos
                .map((r) => DataRow(cells: [
                      DataCell(Text(r['descricao'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(r['inicio'].toString())),
                      DataCell(Text(r['fim'].toString())),
                      DataCell(Text(r['tipo'].toString())),
                    ]))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 11. MÓDULO USUÁRIOS ADM
// ============================================================================
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
      rotaAtiva: '/usuarios',
      titulo: 'Gestão de Usuários (ADM)',
      subtitulo: 'Aprovação, bloqueio e controle de perfis da organização',
      icone: Icons.people,
      onNavegar: widget.onNavegar,
      child: CardPainel(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('USUÁRIO')),
              DataColumn(label: Text('E-MAIL')),
              DataColumn(label: Text('PERFIL')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('AÇÕES')),
            ],
            rows: state.usuarios.map((u) {
              final st = u['status'].toString();
              return DataRow(cells: [
                DataCell(Text(u['nome'].toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(u['email'].toString())),
                DataCell(Text(u['tipo'].toString())),
                DataCell(Text(st.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: st == 'ativo'
                            ? AppColors.success
                            : (st == 'inativo' ? AppColors.warning : AppColors.danger)))),
                DataCell(Row(
                  children: [
                    if (st == 'inativo')
                      TextButton(
                        onPressed: () => setState(() => u['status'] = 'ativo'),
                        child: const Text('Aprovar', style: TextStyle(color: AppColors.success)),
                      ),
                    if (st == 'ativo')
                      TextButton(
                        onPressed: () => setState(() => u['status'] = 'bloqueado'),
                        child: const Text('Bloquear', style: TextStyle(color: AppColors.danger)),
                      ),
                    if (st == 'bloqueado')
                      TextButton(
                        onPressed: () => setState(() => u['status'] = 'ativo'),
                        child: const Text('Desbloquear', style: TextStyle(color: AppColors.primary)),
                      ),
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

// ============================================================================
// 12. PÁGINA ALTERAR SENHA
// ============================================================================
class PaginaResetarSenha extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaResetarSenha({super.key, required this.onNavegar});

  @override
  State<PaginaResetarSenha> createState() => _PaginaResetarSenhaState();
}

class _PaginaResetarSenhaState extends State<PaginaResetarSenha> {
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _conf = TextEditingController();
  String? _erro;
  String? _sucesso;

  void _salvar() {
    setState(() {
      _erro = null;
      _sucesso = null;
    });
    if (_atual.text.isEmpty || _nova.text.isEmpty || _conf.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    if (_atual.text != state.senhaAtual) {
      setState(() => _erro = 'A senha atual está incorreta.');
      return;
    }
    final s = _nova.text;
    if (s.length < 6 ||
        !RegExp(r'[A-Z]').hasMatch(s) ||
        !RegExp(r'[a-z]').hasMatch(s) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(s)) {
      setState(() => _erro = 'A nova senha deve ter 6+ caracteres, maiúscula, minúscula e caractere especial.');
      return;
    }
    if (s == _atual.text) {
      setState(() => _erro = 'A nova senha não pode ser igual à senha atual.');
      return;
    }
    if (s != _conf.text) {
      setState(() => _erro = 'A confirmação da senha não coincide.');
      return;
    }
    state.senhaAtual = s;
    setState(() {
      _sucesso = 'Senha alterada com sucesso!';
      _atual.clear();
      _nova.clear();
      _conf.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/resetar-senha',
      titulo: 'Alterar Senha',
      subtitulo: 'Mantenha sua senha segura (${state.emailUsuario})',
      icone: Icons.key,
      onNavegar: widget.onNavegar,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CardPainel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_erro != null) BannerAlerta(texto: _erro!),
                if (_sucesso != null) BannerAlerta(texto: _sucesso!, sucesso: true),
                TextField(controller: _atual, obscureText: true, decoration: const InputDecoration(labelText: 'Senha Atual')),
                const SizedBox(height: 14),
                TextField(controller: _nova, obscureText: true, decoration: const InputDecoration(labelText: 'Nova Senha (6+ chars, A-Z, a-z, especial)')),
                const SizedBox(height: 14),
                TextField(controller: _conf, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar Nova Senha')),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _salvar,
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Alterar Senha'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => widget.onNavegar('/dashboard'),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}