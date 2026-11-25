import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'supabase_config.dart';

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
      case 'admin_cliente': return 'Administrador';
      case 'gerente': return 'Coordenador';
      case 'usuario': return 'Usuário';
      default: return 'Visualizador';
    }
  }

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
        try {
          await supabase.from('usuarios_sistema').update({
            'tentativas_login': (resp['tentativas_login'] ?? 0) + 1,
          }).eq('id_usuario', resp['id_usuario']);
        } catch (_) {}
        return 'E-mail ou senha inválidos.';
      }

      tentativasLogin = 0;
      idUsuario = resp['id_usuario'] as int;
      idCliente = resp['id_cliente'] as int;
      nomeUsuario = resp['nome_usuario'] as String;
      emailUsuario = resp['email_usuario'] as String;
      tipoUsuario = resp['tipo_usuario'] as String;
      senhaHashAtual = hash;
      logado = true;

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

  Future<void> carregarDados() async {
    if (idCliente == null) return;
    carregando = true;
    notifyListeners();
    try {
      final cli = await supabase.from('clientes').select().eq('id_cliente', idCliente!).maybeSingle();
      nomeCliente = (cli?['nome_cliente'] ?? 'Organização').toString();

      unidades = List<Map<String, dynamic>>.from(await supabase.from('unidades').select().eq('id_cliente', idCliente!));
      salas = List<Map<String, dynamic>>.from(await supabase.from('salas').select().eq('id_cliente', idCliente!));
      cursos = List<Map<String, dynamic>>.from(await supabase.from('cursos').select().eq('id_cliente', idCliente!));
      aulas = List<Map<String, dynamic>>.from(await supabase.from('cronograma').select().eq('id_cliente', idCliente!));
      recessos = List<Map<String, dynamic>>.from(await supabase.from('recessos').select().eq('id_cliente', idCliente!));
      usuarios = List<Map<String, dynamic>>.from(await supabase.from('usuarios_sistema').select().eq('id_cliente', idCliente!));

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
    idUsuario = null; idCliente = null; idUnidadeAtiva = null;
    nomeUsuario = ''; emailUsuario = ''; tipoUsuario = ''; nomeCliente = ''; senhaHashAtual = '';
    unidades = []; salas = []; cursos = []; aulas = []; recessos = []; usuarios = [];
    setFlash('Você saiu do sistema com sucesso.', ok: true);
  }

  void setFlash(String msg, {bool ok = true}) {
    flashMsg = msg;
    flashOk = ok;
    notifyListeners();
  }

  Future<bool> criarUnidade({required String nome, required String cidade, required String estado, required String endereco}) async {
    try {
      await supabase.from('unidades').insert({
        'nome_unidade': nome, 'cidade_unidade': cidade, 'estado_unidade': estado,
        'endereco_unidade': endereco, 'status_unidade': 'ativo', 'id_cliente': idCliente!,
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
      await supabase.from('unidades').update({'status_unidade': novo}).eq('id_unidade', u['id_unidade']).eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  Future<bool> criarSala({required int numero, required String tipo, required int capacidade, required int andar}) async {
    if (idUnidadeAtiva == null) { setFlash('Selecione uma unidade ativa.', ok: false); return false; }
    try {
      await supabase.from('salas').insert({
        'id_unidade': idUnidadeAtiva, 'id_cliente': idCliente!, 'andar_sala': andar,
        'numero_sala': numero, 'tipo_sala': tipo, 'capacidade_sala': capacidade, 'status_sala': 'disponivel',
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
      await supabase.from('salas').delete().eq('id_sala', idSala).eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro ao excluir sala: $e', ok: false);
    }
  }

  Future<void> atualizarStatusSala(int idSala, String novoStatus) async {
    try {
      await supabase.from('salas').update({'status_sala': novoStatus}).eq('id_sala', idSala).eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  Future<void> toggleCurso(Map<String, dynamic> c) async {
    final novo = c['status_curso'] == 'ativo' ? 'inativo' : 'ativo';
    try {
      await supabase.from('cursos').update({'status_curso': novo}).eq('id_curso', c['id_curso']).eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  Future<void> marcarAulaRealizada(int idAula) async {
    try {
      await supabase.from('cronograma').update({'status_aula': 'realizada'}).eq('id_aula', idAula).eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  Future<void> alterarStatusUsuario(int idUsuario, String status) async {
    try {
      await supabase.from('usuarios_sistema').update({'status_usuario': status}).eq('id_usuario', idUsuario).eq('id_cliente', idCliente!);
      await carregarDados();
    } catch (e) {
      setFlash('Erro: $e', ok: false);
    }
  }

  Future<String?> alterarSenha(String atual, String nova) async {
    if (!BCrypt.checkpw(atual, senhaHashAtual)) return 'A senha atual está incorreta.';
    if (nova.length < 6 || !RegExp(r'[A-Z]').hasMatch(nova) || !RegExp(r'[a-z]').hasMatch(nova) || !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(nova)) {
      return 'A nova senha não atende aos requisitos.';
    }
    if (nova == atual) return 'A nova senha não pode ser igual à atual.';
    final novoHash = BCrypt.hashpw(nova, BCrypt.gensalt());
    try {
      await supabase.from('usuarios_sistema').update({'senha_usuario': novoHash}).eq('id_usuario', idUsuario!);
      senhaHashAtual = novoHash;
      return null;
    } catch (e) {
      return 'Erro ao salvar: $e';
    }
  }
}

final state = SistemaState();