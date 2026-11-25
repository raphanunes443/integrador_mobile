import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://aiyahroofixqkdxwhtjh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpeWFocm9vZml4cWtkeHdodGpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTU0MjU1MjksImV4cCI6MjExMTAwMTUyOX0.TWasy1zqRi5a24-XHBOtZeJLfGiww9umLm3eSGPSoXk',
  );
  runApp(const GerenciadorAmbientesApp());
}

final supabase = Supabase.instance.client;

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

class SistemaState extends ChangeNotifier {
  bool logado = false;
  bool carregando = false;

  // Sessão
  int? idUsuario;
  int? idCliente;
  String nomeUsuario = '';
  String emailUsuario = '';
  String tipoUsuario = '';
  String nomeCliente = '';
  String senhaHashAtual = '';
  int tentativasLogin = 0;

  int? idUnidadeAtiva;
  String? flashMsg;
  bool flashOk = true;

  // Dados vindos do banco
  List<Map<String, dynamic>> unidades = [];
  List<Map<String, dynamic>> salas = [];
  List<Map<String, dynamic>> cursos = [];
  List<Map<String, dynamic>> aulas = [];
  List<Map<String, dynamic>> recessos = [];
  List<Map<String, dynamic>> usuarios = [];

  String get nomeUnidadeAtiva {
    if (idUnidadeAtiva == null) return '—';
    final u = unidades.firstWhere(
      (e) => e['id_unidade'] == idUnidadeAtiva,
      orElse: () => <String, dynamic>{'nome_unidade': '—'},
    );
    return (u['nome_unidade'] ?? '—').toString();
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

  // ---------- LOGIN ----------
  Future<String?> login(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) return 'Preencha todos os campos.';
    if (tentativasLogin >= 5) {
      return 'Muitas tentativas falhas. Entre em contato com o administrador.';
    }

    try {
      final resp = await supabase
          .from('usuarios_sistema')
          .select()
          .eq('email_usuario', email.trim())
          .maybeSingle();

      if (resp == null) {
        tentativasLogin++;
        return 'E-mail ou senha inválidos.';
      }

      if (resp['status_usuario'] != 'ativo') {
        return 'Usuário ${resp['status_usuario']}. Contate o administrador.';
      }

      final hash = resp['senha_usuario'] as String;
      if (!BCrypt.checkpw(senha, hash)) {
        tentativasLogin++;
        // Grava tentativa no banco (não bloqueia o site, só incrementa)
        try {
          await supabase.from('usuarios_sistema').update({
            'tentativas_login': (resp['tentativas_login'] ?? 0) + 1,
          }).eq('id_usuario', resp['id_usuario']);
        } catch (_) {}
        return 'E-mail ou senha inválidos.';
      }

      // Sucesso
      tentativasLogin = 0;
      idUsuario = resp['id_usuario'] as int;
      idCliente = resp['id_cliente'] as int;
      nomeUsuario = resp['nome_usuario'] as String;
      emailUsuario = resp['email_usuario'] as String;
      tipoUsuario = resp['tipo_usuario'] as String;
      senhaHashAtual = hash;
      logado = true;

      // Registra último acesso e zera tentativas
      try {
        await supabase.from('usuarios_sistema').update({
          'data_ultimo_acesso': DateTime.now().toIso8601String(),
          'tentativas_login': 0,
        }).eq('id_usuario', idUsuario!);
      } catch (_) {}

      await carregarDados();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao conectar: $e';
    }
  }

  // ---------- CARREGAR DADOS ----------
  Future<void> carregarDados() async {
    if (idCliente == null) return;
    carregando = true;
    notifyListeners();
    try {
      final cli = await supabase
          .from('clientes')
          .select()
          .eq('id_cliente', idCliente!)
          .maybeSingle();
      nomeCliente = (cli?['nome_cliente'] ?? 'Organização').toString();

      unidades = List<Map<String, dynamic>>.from(
          await supabase.from('unidades').select().eq('id_cliente', idCliente!));

      salas = List<Map<String, dynamic>>.from(
          await supabase.from('salas').select().eq('id_cliente', idCliente!));

      cursos = List<Map<String, dynamic>>.from(
          await supabase.from('cursos').select().eq('id_cliente', idCliente!));

      aulas = List<Map<String, dynamic>>.from(
          await supabase.from('cronograma').select().eq('id_cliente', idCliente!));

      recessos = List<Map<String, dynamic>>.from(
          await supabase.from('recessos').select().eq('id_cliente', idCliente!));

      usuarios = List<Map<String, dynamic>>.from(
          await supabase.from('usuarios_sistema').select().eq('id_cliente', idCliente!));

      // Define unidade ativa
      final ativas = unidades.where((u) => u['status_unidade'] == 'ativo').toList();
      if (idUnidadeAtiva == null || !unidades.any((u) => u['id_unidade'] == idUnidadeAtiva)) {
        idUnidadeAtiva = ativas.isNotEmpty
            ? ativas.first['id_unidade'] as int
            : (unidades.isNotEmpty ? unidades.first['id_unidade'] as int : null);
      }
    } catch (e) {
      setFlash('Erro ao carregar dados: $e', ok: false);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void trocarUnidade(int novoId) {
    idUnidadeAtiva = novoId;
    notifyListeners();
  }

  void logout() {
    logado = false;
    idUsuario = null;
    idCliente = null;
    idUnidadeAtiva = null;
    nomeUsuario = '';
    emailUsuario = '';
    tipoUsuario = '';
    nomeCliente = '';
    senhaHashAtual = '';
    unidades = [];
    salas = [];
    cursos = [];
    aulas = [];
    recessos = [];
    usuarios = [];
    setFlash('Você saiu do sistema com sucesso.', ok: true);
  }

  void setFlash(String msg, {bool ok = true}) {
    flashMsg = msg;
    flashOk = ok;
    notifyListeners();
  }

  // ---------- HELPERS ----------
  static String fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String timeOfDayToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  // ---------- CRUD UNIDADES ----------
  Future<bool> criarUnidade({
    required String nome,
    required String cidade,
    required String estado,
    required String endereco,
  }) async {
    try {
      await supabase.from('unidades').insert({
        'nome_unidade': nome,
        'cidade_unidade': cidade,
        'estado_unidade': estado,
        'endereco_unidade': endereco,
        'status_unidade': 'ativo',
        'id_cliente': idCliente!,
      });
      await carregarDados();
      return true;
    } catch (e) {
      setFlash('Erro ao criar unidade: $e', ok: false);
      return false;
    }
  }

  Future<void> toggleUnidade(Map<String, dynamic> u) async {
    final novo = u['status_unidade'] == 'ativo' ? 'inativo' : 'ativo';
    try {
      await supabase.from('unidades')
          .update({'status_unidade': novo})
          .eq('id_unidade', u['id_unidade'])
          .eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  // ---------- CRUD SALAS ----------
  Future<bool> criarSala({
    required int numero,
    required String tipo,
    required int capacidade,
    required int andar,
  }) async {
    if (idUnidadeAtiva == null) {
      setFlash('Selecione uma unidade ativa.', ok: false);
      return false;
    }
    try {
      await supabase.from('salas').insert({
        'id_unidade': idUnidadeAtiva,
        'id_cliente': idCliente!,
        'andar_sala': andar,
        'numero_sala': numero,
        'tipo_sala': tipo,
        'capacidade_sala': capacidade,
        'status_sala': 'disponivel',
      });
      await carregarDados();
      return true;
    } catch (e) {
      setFlash('Erro ao criar sala: $e', ok: false);
      return false;
    }
  }

  Future<void> deletarSala(int idSala) async {
    try {
      await supabase.from('salas')
          .delete()
          .eq('id_sala', idSala)
          .eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro ao excluir sala: $e', ok: false);
    }
  }

  Future<void> atualizarStatusSala(int idSala, String novoStatus) async {
    try {
      await supabase.from('salas')
          .update({'status_sala': novoStatus})
          .eq('id_sala', idSala)
          .eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  // ---------- CRUD CURSOS ----------
  Future<void> toggleCurso(Map<String, dynamic> c) async {
    final novo = c['status_curso'] == 'ativo' ? 'inativo' : 'ativo';
    try {
      await supabase.from('cursos')
          .update({'status_curso': novo})
          .eq('id_curso', c['id_curso'])
          .eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  // ---------- CRUD CRONOGRAMA ----------
  Future<void> marcarAulaRealizada(int idAula) async {
    try {
      await supabase.from('cronograma')
          .update({'status_aula': 'realizada'})
          .eq('id_aula', idAula)
          .eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  // ---------- CRUD USUÁRIOS ----------
  Future<void> alterarStatusUsuario(int idUsuario, String status) async {
    try {
      await supabase.from('usuarios_sistema')
          .update({'status_usuario': status})
          .eq('id_usuario', idUsuario)
          .eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  // ---------- ALTERAR SENHA ----------
  Future<String?> alterarSenha(String atual, String nova) async {
    if (!BCrypt.checkpw(atual, senhaHashAtual)) {
      return 'A senha atual está incorreta.';
    }
    if (nova.length < 6 ||
        !RegExp(r'[A-Z]').hasMatch(nova) ||
        !RegExp(r'[a-z]').hasMatch(nova) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(nova)) {
      return 'A nova senha não atende aos requisitos.';
    }
    if (nova == atual) return 'A nova senha não pode ser igual à atual.';
    final novoHash = BCrypt.hashpw(nova, BCrypt.gensalt());
    try {
      await supabase.from('usuarios_sistema')
          .update({'senha_usuario': novoHash})
          .eq('id_usuario', idUsuario!);
      senhaHashAtual = novoHash;
      return null;
    } catch (e) {
      return 'Erro ao salvar: $e';
    }
  }
}

final state = SistemaState();

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
  void _irPara(String r) => setState(() => _rota = r);

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

class CnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var d = n.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 14) d = d.substring(0, 14);
    var r = '';
    for (int i = 0; i < d.length; i++) {
      if (i == 2 || i == 5) r += '.';
      if (i == 8) r += '/';
      if (i == 12) r += '-';
      r += d[i];
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var d = n.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 11) d = d.substring(0, 11);
    var r = '';
    if (d.isNotEmpty) {
      r += '(';
      for (int i = 0; i < d.length; i++) {
        if (i == 2) r += ') ';
        if (d.length <= 10 && i == 6) r += '-';
        if (d.length == 11 && i == 7) r += '-';
        r += d[i];
      }
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class ShellLayout extends StatelessWidget {
  final String rotaAtiva, titulo, subtitulo;
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
    final unidadesAtivas =
        state.unidades.where((u) => u['status_unidade'] == 'ativo').toList();
    final idsAtivos = unidadesAtivas.map((u) => u['id_unidade']).toList();
    final valorSel = idsAtivos.contains(state.idUnidadeAtiva)
        ? state.idUnidadeAtiva
        : (idsAtivos.isNotEmpty ? idsAtivos.first as int : null);

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: AppColors.primary),
              title: Text(titulo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
      drawer: isDesktop
          ? null
          : Drawer(child: _Sidebar(rotaAtiva: rotaAtiva, onNavegar: onNavegar)),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFFE8EDF5)))),
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
                              Text(titulo,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(subtitulo,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.textMuted)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (valorSel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: valorSel,
                                  icon: const Icon(Icons.swap_horiz,
                                      size: 18, color: AppColors.primary),
                                  items: unidadesAtivas
                                      .map((u) => DropdownMenuItem<int>(
                                            value: u['id_unidade'] as int,
                                            child: Text(u['nome_unidade'].toString(),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600)),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) state.trocarUnidade(v);
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
    final atrasadas = state.aulas
        .where((a) =>
            a['status_aula'] == 'agendada' &&
            DateTime.parse(a['data_aula'].toString()).isBefore(DateTime.now()))
        .length;

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
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.meeting_room, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Siga',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Sistema Multi-Tenant',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
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
                _nav(context, Icons.admin_panel_settings, 'Painel Coordenador',
                    '/coordenador',
                    badge: atrasadas > 0 ? '$atrasadas' : null),
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: Text('CADASTROS & AMBIENTES',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9AABBF))),
                ),
                _nav(context, Icons.business, 'Unidades', '/unidades'),
                _nav(context, Icons.door_front_door, 'Salas', '/salas'),
                _nav(context, Icons.book, 'Cursos', '/cursos'),
                _nav(context, Icons.calendar_month, 'Cronograma Aulas',
                    '/cronograma'),
                _nav(context, Icons.map, 'Mapa de Salas', '/mapa'),
                _nav(context, Icons.event_busy, 'Recessos', '/recessos'),
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: Text('ADMINISTRAÇÃO',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9AABBF))),
                ),
                _nav(context, Icons.people, 'Usuários (ADM)', '/usuarios'),
                _nav(context, Icons.key, 'Alterar Senha', '/resetar-senha'),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEEF2F9),
              child: Text(state.nomeUsuario.isNotEmpty
                  ? state.nomeUsuario[0].toUpperCase()
                  : '?'),
            ),
            title: Text(state.nomeUsuario,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(state.nomeCliente,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.primary)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(BuildContext context, IconData icon, String label, String rota,
      {String? badge}) {
    final ativo = rotaAtiva == rota;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: () {
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          }
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
              Icon(icon,
                  size: 18,
                  color: ativo ? Colors.white : const Color(0xFF8A9BB5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ativo
                            ? Colors.white
                            : const Color(0xFF5A6A7E))),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(60)),
                  child: Text(badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(sucesso ? Icons.check_circle : Icons.error, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    color: fg, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class CardPainel extends StatelessWidget {
  final Widget child;
  final Color? borda, fundo;
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

class PaginaLogin extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaLogin({super.key, required this.onNavegar});
  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String? _erro;
  bool _carregando = false;

  Future<void> _entrar() async {
    setState(() {
      _erro = null;
      _carregando = true;
    });
    final res = await state.login(_emailCtrl.text.trim(), _senhaCtrl.text);
    if (!mounted) return;
    setState(() => _carregando = false);
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.door_front_door,
                    size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text('Siga',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const Text('Gerenciamento de Ambientes',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 24),
                if (_erro != null) BannerAlerta(texto: _erro!),
                if (state.flashMsg != null)
                  BannerAlerta(
                      texto: state.flashMsg!, sucesso: state.flashOk),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon:
                        const Icon(Icons.email, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  onSubmitted: (_) => _entrar(),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon:
                        const Icon(Icons.lock, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _entrar,
                    icon: _carregando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.login, size: 18),
                    label: Text(_carregando ? 'Entrando...' : 'Entrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta? ',
                        style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => widget.onNavegar('/cadastro'),
                      child: const Text('Cadastre-se gratuitamente',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
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

class PaginaDashboard extends StatelessWidget {
  final Function(String) onNavegar;
  const PaginaDashboard({super.key, required this.onNavegar});

  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/dashboard',
      titulo: 'Dashboard',
      subtitulo:
          'Bem-vindo(a), ${state.nomeUsuario}! (${state.tipoUsuarioFormatado})',
      icone: Icons.pie_chart,
      onNavegar: onNavegar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _stat('${state.unidades.length}', 'Unidades',
                      Icons.business)),
              const SizedBox(width: 8),
              Expanded(
                  child: _stat('${state.cursos.length}', 'Cursos', Icons.book)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _stat('${state.usuarios.length}', 'Usuários', Icons.people)),
              const SizedBox(width: 8),
              Expanded(
                  child: _stat('${state.salas.length}', 'Salas',
                      Icons.door_front_door)),
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
                    Text('Navegação Rápida',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    _atalho('Unidades', Icons.business,
                        () => onNavegar('/unidades')),
                    _atalho('Cursos', Icons.book, () => onNavegar('/cursos')),
                    _atalho('Salas', Icons.door_front_door,
                        () => onNavegar('/salas')),
                    _atalho('Cronograma', Icons.calendar_month,
                        () => onNavegar('/cronograma')),
                    _atalho('Mapa de Salas', Icons.map,
                        () => onNavegar('/mapa')),
                    _atalho('Usuários', Icons.people,
                        () => onNavegar('/usuarios')),
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
                Text(num,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.25)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      );

  Widget _atalho(String nome, IconData icon, VoidCallback tap,
          {bool perigo = false}) =>
      InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 145,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: perigo ? AppColors.danger : const Color(0xFFEEF3FA)),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: perigo ? AppColors.danger : AppColors.primary,
                  size: 28),
              const SizedBox(height: 8),
              Text(nome,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: perigo ? AppColors.danger : AppColors.textBody)),
            ],
          ),
        ),
      );
}

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
              TextField(
                  controller: nomeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nome da Unidade')),
              TextField(
                  controller: cidadeCtrl,
                  decoration: const InputDecoration(labelText: 'Cidade')),
              TextField(
                  controller: estadoCtrl,
                  maxLength: 2,
                  decoration:
                      const InputDecoration(labelText: 'UF (ex: MG)')),
              TextField(
                  controller: endCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Endereço')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nomeCtrl.text.isEmpty ||
                  cidadeCtrl.text.isEmpty ||
                  estadoCtrl.text.isEmpty ||
                  endCtrl.text.isEmpty) {
                return;
              }
              final ok = await state.criarUnidade(
                nome: nomeCtrl.text.trim(),
                cidade: cidadeCtrl.text.trim(),
                estado: estadoCtrl.text.trim().toUpperCase(),
                endereco: endCtrl.text.trim(),
              );
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
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ],
      child: CardPainel(
        child: state.carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('UNIDADE')),
                    DataColumn(label: Text('CIDADE / UF')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('AÇÕES')),
                  ],
                  rows: state.unidades.map((u) {
                    final ativo = u['status_unidade'] == 'ativo';
                    return DataRow(cells: [
                      DataCell(Text((u['nome_unidade'] ?? '').toString(),
                          style:
                              const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(
                          '${u['cidade_unidade'] ?? ''} - ${u['estado_unidade'] ?? ''}')),
                      DataCell(Text(ativo ? 'Ativa' : 'Inativa',
                          style: TextStyle(
                              color: ativo
                                  ? AppColors.success
                                  : AppColors.danger,
                              fontWeight: FontWeight.w600))),
                      DataCell(TextButton(
                        onPressed: () async {
                          await state.toggleUnidade(u);
                          if (mounted) setState(() {});
                        },
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
              TextField(
                  controller: numCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Número da Sala')),
              TextField(
                  controller: tipoCtrl,
                  decoration: const InputDecoration(labelText: 'Tipo')),
              TextField(
                  controller: capCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Capacidade')),
              TextField(
                  controller: andarCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Andar')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final num = int.tryParse(numCtrl.text);
              final cap = int.tryParse(capCtrl.text);
              final andar = int.tryParse(andarCtrl.text) ?? 1;
              if (num == null || cap == null) return;
              final ok = await state.criarSala(
                numero: num,
                tipo: tipoCtrl.text.trim().isEmpty
                    ? 'Sala Aula'
                    : tipoCtrl.text.trim(),
                capacidade: cap,
                andar: andar,
              );
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
    final salasUnidade = state.idUnidadeAtiva == null
        ? state.salas
        : state.salas
            .where((s) => s['id_unidade'] == state.idUnidadeAtiva)
            .toList();

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
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ],
      child: CardPainel(
        child: salasUnidade.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhuma sala cadastrada nesta unidade.'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('SALA')),
                    DataColumn(label: Text('TIPO')),
                    DataColumn(label: Text('CAPACIDADE')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('EXCLUIR')),
                  ],
                  rows: salasUnidade.map((s) {
                    return DataRow(cells: [
                      DataCell(Text(
                          'Sala ${s['numero_sala']} (Andar ${s['andar_sala']})',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700))),
                      DataCell(Text((s['tipo_sala'] ?? '').toString())),
                      DataCell(Text('${s['capacidade_sala']} lugares')),
                      DataCell(Text(
                          (s['status_sala'] ?? '').toString().toUpperCase())),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete,
                            color: AppColors.danger, size: 18),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir sala?'),
                              content: Text(
                                  'Deseja excluir a sala ${s['numero_sala']}?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar')),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await state.deletarSala(s['id_sala'] as int);
                            if (mounted) setState(() {});
                          }
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
        child: state.cursos.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhum curso cadastrado.'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('CÓDIGO')),
                    DataColumn(label: Text('CURSO')),
                    DataColumn(label: Text('CARGA')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: state.cursos.map((c) {
                    final ativo = c['status_curso'] == 'ativo';
                    return DataRow(cells: [
                      DataCell(Text((c['numero_curso'] ?? '').toString())),
                      DataCell(Text((c['nome_curso'] ?? '').toString(),
                          style:
                              const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(
                          Text('${c['carga_horaria_curso']}h')),
                      DataCell(TextButton(
                        onPressed: () async {
                          await state.toggleCurso(c);
                          if (mounted) setState(() {});
                        },
                        child: Text(ativo
                            ? 'Ativo (Inativar)'
                            : 'Inativo (Ativar)'),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

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
      rotaAtiva: '/cronograma',
      titulo: 'Cronograma de Aulas',
      subtitulo: 'Programação completa de horários e ensalamento',
      icone: Icons.calendar_month,
      onNavegar: widget.onNavegar,
      child: CardPainel(
        child: state.aulas.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhuma aula agendada.'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('DATA')),
                    DataColumn(label: Text('INÍCIO')),
                    DataColumn(label: Text('FIM')),
                    DataColumn(label: Text('TURNO')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('AÇÃO')),
                  ],
                  rows: state.aulas.map((a) {
                    final status = (a['status_aula'] ?? '').toString();
                    return DataRow(cells: [
                      DataCell(Text((a['data_aula'] ?? '').toString())),
                      DataCell(Text((a['horario_inicio'] ?? '').toString())),
                      DataCell(Text((a['horario_fim'] ?? '').toString())),
                      DataCell(Text((a['turno'] ?? '').toString())),
                      DataCell(Text(status.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(
                        status == 'agendada'
                            ? TextButton(
                                onPressed: () async {
                                  await state.marcarAulaRealizada(
                                      a['id_aula'] as int);
                                  if (mounted) setState(() {});
                                },
                                child: const Text('Marcar realizada',
                                    style: TextStyle(color: AppColors.success)),
                              )
                            : const Text('—'),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

class PaginaMapaSalas extends StatefulWidget {
  final Function(String) onNavegar;
  const PaginaMapaSalas({super.key, required this.onNavegar});
  @override
  State<PaginaMapaSalas> createState() => _PaginaMapaSalasState();
}

class _PaginaMapaSalasState extends State<PaginaMapaSalas> {
  @override
  Widget build(BuildContext context) {
    final salasUnidade = state.idUnidadeAtiva == null
        ? state.salas
        : state.salas
            .where((s) => s['id_unidade'] == state.idUnidadeAtiva)
            .toList();

    return ShellLayout(
      rotaAtiva: '/mapa',
      titulo: 'Mapa de Salas (Dia)',
      subtitulo: 'Ocupação em tempo real e registro de manutenção',
      icone: Icons.map,
      onNavegar: widget.onNavegar,
      child: salasUnidade.isEmpty
          ? const CardPainel(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhuma sala cadastrada nesta unidade.'),
              ),
            )
          : Wrap(
              spacing: 20,
              runSpacing: 20,
              children: salasUnidade.map((s) {
                final status = (s['status_sala'] ?? '').toString();
                Color cor = status == 'disponivel'
                    ? AppColors.success
                    : (status == 'ocupada'
                        ? AppColors.primary
                        : (status == 'manutencao'
                            ? AppColors.warning
                            : AppColors.danger));
                String label = status == 'disponivel'
                    ? 'DISPONÍVEL'
                    : (status == 'ocupada'
                        ? 'EM AULA'
                        : (status == 'manutencao'
                            ? 'MANUTENÇÃO'
                            : 'INATIVA'));

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
                          Text('Sala ${s['numero_sala']}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                color: cor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(60)),
                            child: Text(label,
                                style: TextStyle(
                                    color: cor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text((s['tipo_sala'] ?? '').toString(),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                      Text('Capacidade: ${s['capacidade_sala']} alunos',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final novo = status == 'manutencao'
                                ? 'disponivel'
                                : 'manutencao';
                            await state.atualizarStatusSala(
                                s['id_sala'] as int, novo);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.build, size: 15),
                          label: Text(status == 'manutencao'
                              ? 'Liberar Sala'
                              : 'Registrar Manutenção'),
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
        child: state.recessos.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhum recesso cadastrado.'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('NOME')),
                    DataColumn(label: Text('INÍCIO')),
                    DataColumn(label: Text('FIM')),
                    DataColumn(label: Text('TIPO')),
                  ],
                  rows: state.recessos
                      .map((r) => DataRow(cells: [
                            DataCell(Text((r['nome_recesso'] ?? '').toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700))),
                            DataCell(
                                Text((r['data_inicio'] ?? '').toString())),
                            DataCell(Text((r['data_fim'] ?? '').toString())),
                            DataCell(Text((r['tipo'] ?? '').toString())),
                          ]))
                      .toList(),
                ),
              ),
      ),
    );
  }
}

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
        child: state.usuarios.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhum usuário cadastrado.'),
              )
            : SingleChildScrollView(
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
                    final st = (u['status_usuario'] ?? '').toString();
                    final ehEu = u['id_usuario'] == state.idUsuario;
                    return DataRow(cells: [
                      DataCell(Text((u['nome_usuario'] ?? '').toString(),
                          style:
                              const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text((u['email_usuario'] ?? '').toString())),
                      DataCell(Text((u['tipo_usuario'] ?? '').toString())),
                      DataCell(Text(st.toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: st == 'ativo'
                                  ? AppColors.success
                                  : (st == 'pendente' || st == 'inativo'
                                      ? AppColors.warning
                                      : AppColors.danger)))),
                      DataCell(ehEu
                          ? const Text('—')
                          : Row(
                              children: [
                                if (st == 'pendente' || st == 'inativo')
                                  TextButton(
                                    onPressed: () async {
                                      await state.alterarStatusUsuario(
                                          u['id_usuario'] as int, 'ativo');
                                      if (mounted) setState(() {});
                                    },
                                    child: const Text('Aprovar',
                                        style: TextStyle(
                                            color: AppColors.success)),
                                  ),
                                if (st == 'ativo')
                                  TextButton(
                                    onPressed: () async {
                                      await state.alterarStatusUsuario(
                                          u['id_usuario'] as int, 'bloqueado');
                                      if (mounted) setState(() {});
                                    },
                                    child: const Text('Bloquear',
                                        style: TextStyle(
                                            color: AppColors.danger)),
                                  ),
                                if (st == 'bloqueado')
                                  TextButton(
                                    onPressed: () async {
                                      await state.alterarStatusUsuario(
                                          u['id_usuario'] as int, 'ativo');
                                      if (mounted) setState(() {});
                                    },
                                    child: const Text('Desbloquear',
                                        style: TextStyle(
                                            color: AppColors.primary)),
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
  bool _salvando = false;

  Future<void> _salvar() async {
    setState(() {
      _erro = null;
      _sucesso = null;
    });
    if (_atual.text.isEmpty || _nova.text.isEmpty || _conf.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    if (_nova.text != _conf.text) {
      setState(() => _erro = 'A confirmação da senha não coincide.');
      return;
    }
    setState(() => _salvando = true);
    final res = await state.alterarSenha(_atual.text, _nova.text);
    if (!mounted) return;
    setState(() {
      _salvando = false;
      if (res != null) {
        _erro = res;
      } else {
        _sucesso = 'Senha alterada com sucesso!';
        _atual.clear();
        _nova.clear();
        _conf.clear();
      }
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
                if (_sucesso != null)
                  BannerAlerta(texto: _sucesso!, sucesso: true),
                TextField(
                    controller: _atual,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Senha Atual')),
                const SizedBox(height: 14),
                TextField(
                    controller: _nova,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText:
                            'Nova Senha (6+ chars, A-Z, a-z, especial)')),
                const SizedBox(height: 14),
                TextField(
                    controller: _conf,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmar Nova Senha')),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _salvando ? null : _salvar,
                        icon: _salvando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save, size: 16),
                        label: Text(_salvando ? 'Salvando...' : 'Alterar Senha'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14)),
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
  bool _salvando = false;
  String? _erro;

  bool get _tamOk => _senha.text.length >= 6;
  bool get _maiOk => RegExp(r'[A-Z]').hasMatch(_senha.text);
  bool get _minOk => RegExp(r'[a-z]').hasMatch(_senha.text);
  bool get _espOk => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_senha.text);
  bool get _confOk => _confirma.text.isNotEmpty && _senha.text == _confirma.text;

  Future<void> _cadastrar() async {
    setState(() => _erro = null);

    if (_nomeOrg.text.isEmpty ||
        _emailOrg.text.isEmpty ||
        _nomeAdm.text.isEmpty ||
        _emailAdm.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios (*).');
      return;
    }
    if (!(_tamOk && _maiOk && _minOk && _espOk && _confOk)) {
      setState(() => _erro = 'A senha não atende aos requisitos mínimos.');
      return;
    }

    setState(() => _salvando = true);
    try {
      // 1) Verifica e-mail duplicado
      final existe = await supabase
          .from('usuarios_sistema')
          .select('id_usuario')
          .eq('email_usuario', _emailAdm.text.trim())
          .maybeSingle();
      if (existe != null) {
        setState(() {
          _salvando = false;
          _erro = 'Já existe uma conta com esse e-mail.';
        });
        return;
      }

      // 2) Insere cliente
      final cliente = await supabase
          .from('clientes')
          .insert({
            'nome_cliente': _nomeOrg.text.trim(),
            'tipo_cliente': _tipo,
            'cnpj_cliente': _cnpj.text.trim().isEmpty ? null : _cnpj.text.trim(),
            'email_cliente': _emailOrg.text.trim(),
            'telefone_cliente': _tel.text.trim().isEmpty ? null : _tel.text.trim(),
            'status_cliente': 'ativo',
            'plano_cliente': 'gratuito',
          })
          .select()
          .single();

      final idCliente = cliente['id_cliente'] as int;

      // 3) Insere usuário admin com senha hasheada em bcrypt
      final hash = BCrypt.hashpw(_senha.text, BCrypt.gensalt());
      await supabase.from('usuarios_sistema').insert({
        'id_cliente': idCliente,
        'nome_usuario': _nomeAdm.text.trim(),
        'email_usuario': _emailAdm.text.trim(),
        'senha_usuario': hash,
        'tipo_usuario': 'admin_cliente',
        'status_usuario': 'ativo',
        'telefone_usuario': _tel.text.trim().isEmpty ? null : _tel.text.trim(),
      });

      if (!mounted) return;
      state.setFlash(
          'Cadastro realizado com sucesso! Agora faça login.', ok: true);
      widget.onNavegar('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Erro ao cadastrar: $e';
      });
    }
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add, size: 42, color: AppColors.primary),
                const SizedBox(height: 6),
                const Text('Criar Conta',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const Text('Siga - Cadastro de Organização',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted)),
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
                    Expanded(
                        child: _campo('CNPJ', _cnpj, '00.000.000/0000-00',
                            fmt: [CnpjFormatter()])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _campo('E-mail Organização *', _emailOrg,
                            'contato@org.com')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _campo('Telefone', _tel, '(00) 00000-0000',
                            fmt: [TelefoneFormatter()])),
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
                      icon: Icon(_verSenha
                          ? Icons.visibility_off
                          : Icons.visibility),
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
                  onPressed: _salvando ? null : _cadastrar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.person_add, size: 18),
                  label: Text(_salvando
                      ? 'Cadastrando...'
                      : 'Cadastrar Organização'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60)),
                  ),
                ),
                TextButton(
                    onPressed: () => widget.onNavegar('/login'),
                    child: const Text('Já tem uma conta? Faça login')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController c, String hint,
          {List<TextInputFormatter>? fmt}) =>
      TextField(
          controller: c,
          inputFormatters: fmt,
          decoration: _dec(label).copyWith(hintText: hint));

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _req(String t, bool ok) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check_circle : Icons.circle,
              size: 12,
              color: ok ? AppColors.successText : AppColors.dangerText),
          const SizedBox(width: 4),
          Text(t,
              style: TextStyle(
                  fontSize: 12,
                  color: ok ? AppColors.successText : AppColors.dangerText)),
        ],
      );
}

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
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime(2000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final hojeStr = hoje.toIso8601String().substring(0, 10);

    final aulasUnidade = state.idUnidadeAtiva == null
        ? state.aulas
        : state.aulas
            .where((a) => a['id_unidade'] == state.idUnidadeAtiva)
            .toList();

    final aulasHoje = aulasUnidade
        .where((a) => a['data_aula'].toString().startsWith(hojeStr))
        .toList();
    final concluidasHoje =
        aulasHoje.where((a) => a['status_aula'] == 'realizada').length;

    final atrasadas = aulasUnidade.where((a) {
      if (a['status_aula'] != 'agendada') return false;
      return _parseDate(a['data_aula']).isBefore(
          DateTime(hoje.year, hoje.month, hoje.day));
    }).toList();

    final aguardando = aulasUnidade
        .where((a) => a['status_aula'] == 'aguardando_remarcacao')
        .toList();

    return ShellLayout(
      rotaAtiva: '/coordenador',
      titulo: 'Painel do Coordenador',
      subtitulo:
          'Gestão de Aulas e Progresso dos Cursos - ${state.nomeUnidadeAtiva}',
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
              _resumo('${aulasHoje.length}', 'Total Aulas Hoje', Icons.book,
                  AppColors.primary),
              _resumo('$concluidasHoje', 'Concluídas Hoje',
                  Icons.check_circle, AppColors.success),
              _resumo('${aulasHoje.length - concluidasHoje}', 'Pendentes Hoje',
                  Icons.access_time, AppColors.warning),
              _resumo('${aguardando.length}', 'Aguardando Remarcação',
                  Icons.hourglass_bottom, Colors.orange),
              _resumo('${atrasadas.length}', 'Aulas Atrasadas', Icons.warning,
                  AppColors.danger),
            ],
          ),
          const SizedBox(height: 24),
          CardPainel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aulas de Hoje - $hojeStr',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (aulasHoje.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Nenhuma aula agendada para hoje.'),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('CURSO')),
                        DataColumn(label: Text('TURNO')),
                        DataColumn(label: Text('INÍCIO')),
                        DataColumn(label: Text('FIM')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('AÇÃO')),
                      ],
                      rows: aulasHoje.map((a) {
                        final ok = a['status_aula'] == 'realizada';
                        return DataRow(cells: [
                          DataCell(Text('Curso #${a['id_curso']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700))),
                          DataCell(Text((a['turno'] ?? '').toString())),
                          DataCell(
                              Text((a['horario_inicio'] ?? '').toString())),
                          DataCell(Text((a['horario_fim'] ?? '').toString())),
                          DataCell(_badge(
                              ok ? 'Concluída' : 'Pendente',
                              ok ? AppColors.success : AppColors.warning)),
                          DataCell(ok
                              ? const Text('—')
                              : TextButton(
                                  onPressed: () async {
                                    await state.marcarAulaRealizada(
                                        a['id_aula'] as int);
                                    if (mounted) setState(() {});
                                  },
                                  child: const Text('Concluir',
                                      style: TextStyle(
                                          color: AppColors.success)),
                                )),
                        ]);
                      }).toList(),
                    ),
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
                  const Text('Aulas Anteriores Não Concluídas',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger)),
                  const SizedBox(height: 8),
                  ...atrasadas.map((a) {
                    final idAula = a['id_aula'] as int;
                    return CheckboxListTile(
                      value: _selAtrasadas.contains(idAula),
                      onChanged: (v) => setState(() => v!
                          ? _selAtrasadas.add(idAula)
                          : _selAtrasadas.remove(idAula)),
                      title: Text('Curso #${a['id_curso']}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          'Data: ${a['data_aula']} | Turno: ${a['turno']}'),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _selAtrasadas.isEmpty
                        ? null
                        : () async {
                            for (final id in _selAtrasadas) {
                              await state.marcarAulaRealizada(id);
                            }
                            if (!mounted) return;
                            setState(() {
                              _msg =
                                  '${_selAtrasadas.length} aula(s) concluída(s)!';
                              _selAtrasadas.clear();
                            });
                          },
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Concluir Selecionadas'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          CardPainel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progresso dos Cursos',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                          Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((c['nome_curso'] ?? '').toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  Text('Carga: ${total}h',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                ]),
                          ),
                          Expanded(
                            flex: 2,
                            child: LinearProgressIndicator(
                              value: (perc / 100).clamp(0.0, 1.0),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              color: perc >= 80
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${perc.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
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
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBF0F8))),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: c.withOpacity(0.15),
                child: Icon(i, color: c)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text(l,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ]),
            ),
          ],
        ),
      );

  Widget _badge(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: c.withOpacity(0.15),
            borderRadius: BorderRadius.circular(60)),
        child: Text(t,
            style: TextStyle(
                color: c, fontWeight: FontWeight.w600, fontSize: 12)),
      );
}