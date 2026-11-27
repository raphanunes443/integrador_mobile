
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import 'core/app_colors.dart';
import 'core/sistema_state.dart';

// Pages
import 'pages/autenticacao/pagina_cadastro.dart';
import 'pages/dashboard/pagina_coordenador.dart';
import 'pages/cronograma/pagina_cronograma.dart';
import 'pages/cursos/pagina_cursos.dart';
import 'pages/dashboard/pagina_dashboard.dart';
import 'pages/autenticacao/pagina_login.dart';
import 'pages/mapas/pagina_mapa_salas.dart';
import 'pages/recessos/pagina_recessos.dart';
import 'pages/usuarios/pagina_resetar_senha.dart';
import 'pages/salas/pagina_salas.dart';
import 'pages/unidades/pagina_unidades.dart';
import 'pages/usuarios/pagina_usuarios_adm.dart';

// ============================================================
// CONFIGURAÇÕES DO SUPABASE
// ============================================================

const String supabaseUrl =
    'https://zjcgawddxfxbbhtqjkof.supabase.co';

const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqY2dhd2RkeGZ4YmJodHFqa29mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTU3NzA4NjksImV4cCI6MjExMTM0Njg2OX0.FMeMFm6r8yPgpGc15TMQNRdWybH_Q4WHb6Lruoh9xd0';

// ============================================================
// TESTE DE CONEXÃO COM O BANCO DE DADOS
// ============================================================

Future<void> testarConexao() async {
  debugPrint('========================================');
  debugPrint('[SUPABASE] Iniciando teste de conexão...');
  debugPrint('[SUPABASE] URL: $supabaseUrl');
  debugPrint('========================================');

  try {
    final supabase = Supabase.instance.client;

    // Consulta somente o ID, sem buscar dados sensíveis.
    final resposta = await supabase
        .from('usuarios_sistema')
        .select('id_usuario')
        .limit(1)
        .timeout(const Duration(seconds: 15));

    debugPrint(
      '[SUPABASE] Consulta executada com sucesso.',
    );

    if (resposta.isEmpty) {
      debugPrint(
        '[SUPABASE] Nenhum registro retornado.',
      );

      debugPrint(
        '[SUPABASE] Possíveis causas:',
      );

      debugPrint(
        '[SUPABASE] - Tabela sem usuários cadastrados.',
      );

      debugPrint(
        '[SUPABASE] - Políticas RLS restringindo o acesso.',
      );

      debugPrint(
        '[SUPABASE] - Projeto diferente do esperado.',
      );

    } else {
      debugPrint(
        '[SUPABASE] Registro encontrado no banco.',
      );

      debugPrint(
        '[SUPABASE] Teste de leitura realizado com sucesso.',
      );
    }

  } on PostgrestException catch (e) {
    debugPrint(
      '[SUPABASE] Erro ao consultar o banco.',
    );

    debugPrint(
      '[SUPABASE] Código: ${e.code}',
    );

    debugPrint(
      '[SUPABASE] Mensagem: ${e.message}',
    );

    debugPrint(
      '[SUPABASE] Detalhes: ${e.details}',
    );

    debugPrint(
      '[SUPABASE] Sugestão: ${e.hint}',
    );

  } catch (e) {
    debugPrint(
      '[SUPABASE] Falha durante o teste de conexão.',
    );

    debugPrint(
      '[SUPABASE] Erro: $e',
    );
  }

  debugPrint('========================================');
  debugPrint('[SUPABASE] Teste finalizado.');
  debugPrint('========================================');
}

// ============================================================
// INICIALIZAÇÃO DO APLICATIVO
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
    '[SISTEMA] Inicializando o SIGA Mobile...',
  );

  // Inicializa o cliente Supabase.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  debugPrint(
    '[SUPABASE] Cliente inicializado.',
  );

  // Teste temporário de comunicação com o banco.
  await testarConexao();

  // Inicializa a interface do sistema.
  runApp(const GerenciadorAmbientesApp());
}

// ============================================================
// APLICATIVO PRINCIPAL
// ============================================================

class GerenciadorAmbientesApp extends StatefulWidget {
  const GerenciadorAmbientesApp({
    super.key,
  });

  @override
  State<GerenciadorAmbientesApp> createState() =>
      _GerenciadorAmbientesAppState();
}

class _GerenciadorAmbientesAppState
    extends State<GerenciadorAmbientesApp> {

  // Rota inicial do sistema.
  String _rota = '/login';

  // ==========================================================
  // INICIALIZAÇÃO DO ESTADO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    state.addListener(_onStateChange);
  }

  // ==========================================================
  // LIBERAÇÃO DOS RECURSOS
  // ==========================================================

  @override
  void dispose() {
    state.removeListener(_onStateChange);

    super.dispose();
  }

  // ==========================================================
  // ATUALIZAÇÃO DO ESTADO
  // ==========================================================

  void _onStateChange() {
    if (!mounted) return;

    setState(() {});
  }

  // ==========================================================
  // NAVEGAÇÃO ENTRE PÁGINAS
  // ==========================================================

  void _irPara(String rota) {
    if (!mounted) return;

    setState(() {
      _rota = rota;
    });
  }

  // ==========================================================
  // CONSTRUÇÃO DO APLICATIVO
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    Widget pagina;

    // Usuários não autenticados são encaminhados ao login,
    // exceto quando acessam a página de cadastro.
    if (!state.logado && _rota != '/cadastro') {

      pagina = PaginaLogin(
        onNavegar: _irPara,
      );

    } else {

      switch (_rota) {

        // ====================================================
        // CADASTRO
        // ====================================================

        case '/cadastro':
          pagina = PaginaCadastro(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // COORDENADOR
        // ====================================================

        case '/coordenador':
          pagina = PaginaCoordenador(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // UNIDADES
        // ====================================================

        case '/unidades':
          pagina = PaginaUnidades(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // SALAS
        // ====================================================

        case '/salas':
          pagina = PaginaSalas(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // CURSOS
        // ====================================================

        case '/cursos':
          pagina = PaginaCursos(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // CRONOGRAMA
        // ====================================================

        case '/cronograma':
          pagina = PaginaCronograma(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // MAPA DE SALAS
        // ====================================================

        case '/mapa':
          pagina = PaginaMapaSalas(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // RECESSOS
        // ====================================================

        case '/recessos':
          pagina = PaginaRecessos(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // ADMINISTRAÇÃO DE USUÁRIOS
        // ====================================================

        case '/usuarios':
          pagina = PaginaUsuariosAdm(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // ALTERAÇÃO DE SENHA
        // ====================================================

        case '/resetar-senha':
          pagina = PaginaResetarSenha(
            onNavegar: _irPara,
          );
          break;

        // ====================================================
        // DASHBOARD
        // ====================================================

        default:
          pagina = PaginaDashboard(
            onNavegar: _irPara,
          );
          break;
      }
    }

    // ========================================================
    // CONFIGURAÇÃO VISUAL DO APLICATIVO
    // ========================================================

    return MaterialApp(
      title: 'Siga',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgMain,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),

        useMaterial3: true,
      ),

      home: pagina,
    );
  }
}
