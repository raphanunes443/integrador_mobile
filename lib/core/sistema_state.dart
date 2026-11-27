
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'supabase_config.dart';

class SistemaState extends ChangeNotifier {
  bool logado = false;
  bool carregando = false;

  // ==========================================================
  // SESSÃO DO USUÁRIO
  // ==========================================================

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

  // ==========================================================
  // DADOS VINDOS DO BANCO
  // ==========================================================

  List<Map<String, dynamic>> unidades = [];
  List<Map<String, dynamic>> salas = [];
  List<Map<String, dynamic>> cursos = [];
  List<Map<String, dynamic>> aulas = [];
  List<Map<String, dynamic>> recessos = [];
  List<Map<String, dynamic>> usuarios = [];

  // ==========================================================
  // INFORMAÇÕES DA SESSÃO
  // ==========================================================

  String get nomeUnidadeAtiva {
    if (idUnidadeAtiva == null) return '—';

    final u = unidades.firstWhere(
      (e) => e['id_unidade'] == idUnidadeAtiva,
      orElse: () => <String, dynamic>{
        'nome_unidade': '—',
      },
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

  // Verifica se o usuário pode gerenciar unidades.
  bool get _podeGerenciarUnidades =>
      logado &&
      idCliente != null &&
      tipoUsuario == 'admin_cliente';

  // Retorna somente unidades ativas.
  List<Map<String, dynamic>> get unidadesAtivas =>
      unidades
          .where(
            (u) => u['status_unidade'] == 'ativo',
          )
          .toList();

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<String?> login(
    String email,
    String senha,
  ) async {
    if (email.isEmpty || senha.isEmpty) {
      return 'Preencha todos os campos.';
    }

    if (tentativasLogin >= 5) {
      return 'Muitas tentativas falhas. '
          'Entre em contato com o administrador.';
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
        return 'Usuário ${resp['status_usuario']}. '
            'Contate o administrador.';
      }

      final hash = resp['senha_usuario'] as String;

      if (!BCrypt.checkpw(senha, hash)) {
        tentativasLogin++;

        try {
          await supabase
              .from('usuarios_sistema')
              .update({
                'tentativas_login':
                    (resp['tentativas_login'] ?? 0) + 1,
              })
              .eq('id_usuario', resp['id_usuario']);
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
        await supabase
            .from('usuarios_sistema')
            .update({
              'data_ultimo_acesso':
                  DateTime.now().toIso8601String(),
              'tentativas_login': 0,
            })
            .eq('id_usuario', idUsuario!);
      } catch (_) {}

      await carregarDados();

      notifyListeners();

      return null;

    } catch (e) {
      return 'Erro ao conectar: $e';
    }
  }

  // ==========================================================
  // CARREGAMENTO DOS DADOS
  // ==========================================================

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

      nomeCliente =
          (cli?['nome_cliente'] ?? 'Organização')
              .toString();

      // Carrega unidades em ordem alfabética.
      unidades = List<Map<String, dynamic>>.from(
        await supabase
            .from('unidades')
            .select()
            .eq('id_cliente', idCliente!)
            .order('nome_unidade', ascending: true),
      );

      // Carrega salas.
      salas = List<Map<String, dynamic>>.from(
        await supabase
            .from('salas')
            .select()
            .eq('id_cliente', idCliente!),
      );

      // Carrega cursos.
      cursos = List<Map<String, dynamic>>.from(
        await supabase
            .from('cursos')
            .select()
            .eq('id_cliente', idCliente!),
      );

      // Carrega cronograma.
      aulas = List<Map<String, dynamic>>.from(
        await supabase
            .from('cronograma')
            .select()
            .eq('id_cliente', idCliente!),
      );

      // Carrega recessos.
      recessos = List<Map<String, dynamic>>.from(
        await supabase
            .from('recessos')
            .select()
            .eq('id_cliente', idCliente!),
      );

      // Carrega usuários.
      usuarios = List<Map<String, dynamic>>.from(
        await supabase
            .from('usuarios_sistema')
            .select()
            .eq('id_cliente', idCliente!),
      );

      // ======================================================
      // SELEÇÃO DA UNIDADE ATIVA
      // ======================================================

      final ativas = unidadesAtivas;

      final unidadeAtualValida = ativas.any(
        (u) => u['id_unidade'] == idUnidadeAtiva,
      );

      // Caso a unidade selecionada não exista ou esteja
      // inativa, seleciona a primeira unidade ativa.
      if (!unidadeAtualValida) {
        idUnidadeAtiva = ativas.isNotEmpty
            ? ativas.first['id_unidade'] as int
            : null;
      }

    } catch (e) {
      setFlash(
        'Erro ao carregar dados: $e',
        ok: false,
      );

    } finally {
      carregando = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // TROCAR UNIDADE ATIVA
  // ==========================================================

  void trocarUnidade(int novoId) {
    final unidadeValida = unidades.any(
      (u) =>
          u['id_unidade'] == novoId &&
          u['status_unidade'] == 'ativo',
    );

    if (!unidadeValida) {
      setFlash(
        'Selecione uma unidade ativa válida.',
        ok: false,
      );

      return;
    }

    idUnidadeAtiva = novoId;

    notifyListeners();
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

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

    setFlash(
      'Você saiu do sistema com sucesso.',
      ok: true,
    );
  }

  // ==========================================================
  // MENSAGENS DO SISTEMA
  // ==========================================================

  void setFlash(
    String msg, {
    bool ok = true,
  }) {
    flashMsg = msg;
    flashOk = ok;

    notifyListeners();
  }

  // ==========================================================
  // FUSOS HORÁRIOS PERMITIDOS
  // ==========================================================

  static const _fusosValidos = [
    'America/Noronha',
    'America/Belem',
    'America/Fortaleza',
    'America/Recife',
    'America/Araguaina',
    'America/Maceio',
    'America/Bahia',
    'America/Sao_Paulo',
    'America/Campo_Grande',
    'America/Cuiaba',
    'America/Santarem',
    'America/Porto_Velho',
    'America/Boa_Vista',
    'America/Manaus',
    'America/Eirunepe',
    'America/Rio_Branco',
  ];

  // ==========================================================
  // ESTADOS BRASILEIROS PERMITIDOS
  // ==========================================================

  static const _ufsValidas = [
    'AC', 'AL', 'AP', 'AM',
    'BA', 'CE', 'DF', 'ES',
    'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR',
    'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO',
  ];

  // ==========================================================
  // VERIFICAR VÍNCULOS DA UNIDADE
  // ==========================================================

  Future<String?> _verificarVinculosUnidade(
    int id,
    int cliente,
  ) async {
    final tabelas = {
      'salas': 'salas',
      'cursos': 'cursos',
      'funcionarios': 'funcionários',
    };

    for (final tabela in tabelas.entries) {
      final registros = await supabase
          .from(tabela.key)
          .select('id_unidade')
          .eq('id_unidade', id)
          .eq('id_cliente', cliente)
          .limit(1);

      if (registros.isNotEmpty) {
        return 'Não é possível inativar esta unidade. '
            'Existem ${tabela.value} vinculados a ela.';
      }
    }

    return null;
  }

  // ==========================================================
  // CRIAR UNIDADE
  // ==========================================================
  // Mantido para compatibilidade com outros arquivos.

  Future<bool> criarUnidade({
    required String nome,
    required String cidade,
    required String estado,
    required String endereco,
    String telefone = '',
    String email = '',
    String status = 'ativo',
    String fuso = 'America/Sao_Paulo',
  }) {
    return salvarUnidade(
      nome: nome,
      cidade: cidade,
      estado: estado,
      endereco: endereco,
      telefone: telefone,
      email: email,
      status: status,
      fuso: fuso,
    );
  }

  // ==========================================================
  // CADASTRAR OU EDITAR UNIDADE
  // ==========================================================

  Future<bool> salvarUnidade({
    int? id,
    required String nome,
    required String cidade,
    required String estado,
    required String endereco,
    String telefone = '',
    String email = '',
    String status = 'ativo',
    String fuso = 'America/Sao_Paulo',
  }) async {

    // Verifica a permissão administrativa.
    if (!_podeGerenciarUnidades) {
      setFlash(
        'Você não possui permissão para gerenciar unidades.',
        ok: false,
      );

      return false;
    }

    final cliente = idCliente!;

    // ======================================================
    // NORMALIZAÇÃO DOS DADOS
    // ======================================================

    nome = nome.trim();
    cidade = cidade.trim();
    estado = estado.trim().toUpperCase();
    endereco = endereco.trim();

    telefone = telefone.trim();
    email = email.trim();

    // ======================================================
    // VALIDAÇÃO DOS CAMPOS OBRIGATÓRIOS
    // ======================================================

    if (nome.isEmpty ||
        cidade.isEmpty ||
        estado.isEmpty ||
        endereco.isEmpty) {
      setFlash(
        'Preencha todos os campos obrigatórios.',
        ok: false,
      );

      return false;
    }

    // ======================================================
    // VALIDAÇÃO DOS LIMITES DO BANCO
    // ======================================================

    if (nome.length > 100) {
      setFlash(
        'O nome da unidade deve possuir até 100 caracteres.',
        ok: false,
      );

      return false;
    }

    if (cidade.length > 80) {
      setFlash(
        'A cidade deve possuir até 80 caracteres.',
        ok: false,
      );

      return false;
    }

    if (endereco.length > 200) {
      setFlash(
        'O endereço deve possuir até 200 caracteres.',
        ok: false,
      );

      return false;
    }

    if (telefone.length > 15) {
      setFlash(
        'O telefone deve possuir até 15 caracteres.',
        ok: false,
      );

      return false;
    }

    if (email.length > 100) {
      setFlash(
        'O e-mail deve possuir até 100 caracteres.',
        ok: false,
      );

      return false;
    }

    // ======================================================
    // VALIDAÇÃO DA UF
    // ======================================================

    if (!_ufsValidas.contains(estado)) {
      setFlash(
        'Informe uma UF brasileira válida.',
        ok: false,
      );

      return false;
    }

    // ======================================================
    // VALIDAÇÃO DO E-MAIL
    // ======================================================

    if (email.isNotEmpty &&
        !RegExp(
          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
        ).hasMatch(email)) {
      setFlash(
        'Informe um e-mail válido.',
        ok: false,
      );

      return false;
    }

    // ======================================================
    // VALIDAÇÃO DO STATUS
    // ======================================================

    if (!['ativo', 'inativo'].contains(status)) {
      setFlash(
        'Status da unidade inválido.',
        ok: false,
      );

      return false;
    }

    // ======================================================
    // VALIDAÇÃO DO FUSO HORÁRIO
    // ======================================================

    if (!_fusosValidos.contains(fuso)) {
      setFlash(
        'Selecione um fuso horário válido.',
        ok: false,
      );

      return false;
    }

    try {

      // ====================================================
      // VERIFICAÇÃO DE NOMES DUPLICADOS
      // ====================================================

      final duplicados = await supabase
          .from('unidades')
          .select('id_unidade')
          .eq('id_cliente', cliente)
          .eq('nome_unidade', nome);

      final nomeDuplicado = duplicados.any(
        (u) => u['id_unidade'] != id,
      );

      if (nomeDuplicado) {
        setFlash(
          'Já existe uma unidade com este nome '
          'nesta organização.',
          ok: false,
        );

        return false;
      }

      // ====================================================
      // VERIFICAÇÕES PARA EDIÇÃO
      // ====================================================

      if (id != null) {
        final unidadeAtual = await supabase
            .from('unidades')
            .select('id_unidade, status_unidade')
            .eq('id_cliente', cliente)
            .eq('id_unidade', id)
            .maybeSingle();

        if (unidadeAtual == null) {
          setFlash(
            'Unidade não encontrada.',
            ok: false,
          );

          return false;
        }

        // Impede a inativação pelo formulário de edição
        // caso existam registros vinculados.
        if (unidadeAtual['status_unidade'] == 'ativo' &&
            status == 'inativo') {

          final erroVinculo =
              await _verificarVinculosUnidade(
            id,
            cliente,
          );

          if (erroVinculo != null) {
            setFlash(
              erroVinculo,
              ok: false,
            );

            return false;
          }
        }
      }

      // ====================================================
      // DADOS QUE SERÃO ENVIADOS AO BANCO
      // ====================================================

      final dados = <String, dynamic>{
        'nome_unidade': nome,
        'cidade_unidade': cidade,
        'estado_unidade': estado,
        'endereco_unidade': endereco,

        'telefone_unidade':
            telefone.isEmpty ? null : telefone,

        'email_unidade':
            email.isEmpty ? null : email,

        'status_unidade': status,
        'fuso': fuso,

        'id_cliente': cliente,
      };

      // ====================================================
      // CADASTRO
      // ====================================================

      if (id == null) {
        await supabase
            .from('unidades')
            .insert(dados)
            .select('id_unidade')
            .single();

      // ====================================================
      // EDIÇÃO
      // ====================================================

      } else {
        await supabase
            .from('unidades')
            .update(dados)
            .eq('id_unidade', id)
            .eq('id_cliente', cliente)
            .select('id_unidade')
            .single();
      }

      setFlash(
        id == null
            ? 'Unidade cadastrada com sucesso.'
            : 'Unidade atualizada com sucesso.',
      );

      // Atualiza os dados exibidos no sistema.
      await carregarDados();

      return true;

    } catch (_) {
      setFlash(
        'Não foi possível salvar a unidade. '
        'Verifique os dados, a conexão e as permissões.',
        ok: false,
      );

      return false;
    }
  }

  // ==========================================================
  // ATIVAR OU INATIVAR UNIDADE
  // ==========================================================

  Future<void> toggleUnidade(
    Map<String, dynamic> u,
  ) async {

    if (!_podeGerenciarUnidades) {
      setFlash(
        'Você não possui permissão para alterar unidades.',
        ok: false,
      );

      return;
    }

    final cliente = idCliente!;

    try {
      final id = u['id_unidade'] as int;

      // Consulta o status atual diretamente no banco.
      final unidadeAtual = await supabase
          .from('unidades')
          .select('id_unidade, status_unidade')
          .eq('id_unidade', id)
          .eq('id_cliente', cliente)
          .maybeSingle();

      if (unidadeAtual == null) {
        setFlash(
          'Unidade não encontrada.',
          ok: false,
        );

        return;
      }

      final novoStatus =
          unidadeAtual['status_unidade'] == 'ativo'
              ? 'inativo'
              : 'ativo';

      // Verifica vínculos antes de inativar.
      if (novoStatus == 'inativo') {
        final erroVinculo =
            await _verificarVinculosUnidade(
          id,
          cliente,
        );

        if (erroVinculo != null) {
          setFlash(
            erroVinculo,
            ok: false,
          );

          return;
        }
      }

      // Atualiza o status no banco.
      await supabase
          .from('unidades')
          .update({
            'status_unidade': novoStatus,
          })
          .eq('id_unidade', id)
          .eq('id_cliente', cliente)
          .select('id_unidade')
          .single();

      setFlash(
        novoStatus == 'ativo'
            ? 'Unidade ativada com sucesso.'
            : 'Unidade inativada com sucesso.',
      );

      await carregarDados();

    } catch (_) {
      setFlash(
        'Não foi possível alterar o status da unidade.',
        ok: false,
      );
    }
  }

  // ==========================================================
  // CADASTRAR SALA
  // ==========================================================

  Future<bool> criarSala({
    required int numero,
    required String tipo,
    required int capacidade,
    required int andar,
  }) async {

    if (idUnidadeAtiva == null) {
      setFlash(
        'Selecione uma unidade ativa.',
        ok: false,
      );

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
      setFlash(
        'Erro ao criar sala: $e',
        ok: false,
      );

      return false;
    }
  }

  // ==========================================================
  // EXCLUIR SALA
  // ==========================================================

  Future<void> deletarSala(int idSala) async {
    try {
      await supabase
          .from('salas')
          .delete()
          .eq('id_sala', idSala)
          .eq('id_cliente', idCliente!);

      await carregarDados();

    } catch (e) {
      setFlash(
        'Erro ao excluir sala: $e',
        ok: false,
      );
    }
  }

  // ==========================================================
  // ATUALIZAR STATUS DA SALA
  // ==========================================================

  Future<void> atualizarStatusSala(
    int idSala,
    String novoStatus,
  ) async {
    try {
      await supabase
          .from('salas')
          .update({
            'status_sala': novoStatus,
          })
          .eq('id_sala', idSala)
          .eq('id_cliente', idCliente!);

      await carregarDados();

    } catch (e) {
      setFlash(
        'Erro: $e',
        ok: false,
      );
    }
  }

  // ==========================================================
  // ATIVAR OU INATIVAR CURSO
  // ==========================================================

  Future<void> toggleCurso(
    Map<String, dynamic> c,
  ) async {
    final novo =
        c['status_curso'] == 'ativo'
            ? 'inativo'
            : 'ativo';

    try {
      await supabase
          .from('cursos')
          .update({
            'status_curso': novo,
          })
          .eq('id_curso', c['id_curso'])
          .eq('id_cliente', idCliente!);

      await carregarDados();

    } catch (e) {
      setFlash(
        'Erro: $e',
        ok: false,
      );
    }
  }

  // ==========================================================
  // MARCAR AULA COMO REALIZADA
  // ==========================================================

  Future<void> marcarAulaRealizada(
    int idAula,
  ) async {
    try {
      await supabase
          .from('cronograma')
          .update({
            'status_aula': 'realizada',
          })
          .eq('id_aula', idAula)
          .eq('id_cliente', idCliente!);

      await carregarDados();

    } catch (e) {
      setFlash(
        'Erro: $e',
        ok: false,
      );
    }
  }

  // ==========================================================
  // ALTERAR STATUS DO USUÁRIO
  // ==========================================================

  Future<void> alterarStatusUsuario(
    int idUsuario,
    String status,
  ) async {
    try {
      await supabase
          .from('usuarios_sistema')
          .update({
            'status_usuario': status,
          })
          .eq('id_usuario', idUsuario)
          .eq('id_cliente', idCliente!);

      await carregarDados();

    } catch (e) {
      setFlash(
        'Erro: $e',
        ok: false,
      );
    }
  }

  // ==========================================================
  // ALTERAR SENHA
  // ==========================================================

  Future<String?> alterarSenha(
    String atual,
    String nova,
  ) async {

    if (!BCrypt.checkpw(atual, senhaHashAtual)) {
      return 'A senha atual está incorreta.';
    }

    if (nova.length < 6 ||
        !RegExp(r'[A-Z]').hasMatch(nova) ||
        !RegExp(r'[a-z]').hasMatch(nova) ||
        !RegExp(
          r'[!@#$%^&*(),.?":{}|<>]',
        ).hasMatch(nova)) {
      return 'A nova senha não atende aos requisitos.';
    }

    if (nova == atual) {
      return 'A nova senha não pode ser igual à atual.';
    }

    final novoHash = BCrypt.hashpw(
      nova,
      BCrypt.gensalt(),
    );

    try {
      await supabase
          .from('usuarios_sistema')
          .update({
            'senha_usuario': novoHash,
          })
          .eq('id_usuario', idUsuario!);

      senhaHashAtual = novoHash;

      return null;

    } catch (e) {
      return 'Erro ao salvar: $e';
    }
  }
}

// ============================================================
// INSTÂNCIA GLOBAL DO SISTEMA
// ============================================================

final state = SistemaState();
