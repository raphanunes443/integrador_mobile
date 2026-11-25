import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import 'core/app_colors.dart';
import 'core/sistema_state.dart';

// Pages
import 'pages/pagina_cadastro.dart';
import 'pages/pagina_coordenador.dart';
import 'pages/pagina_cronograma.dart';
import 'pages/pagina_cursos.dart';
import 'pages/pagina_dashboard.dart';
import 'pages/pagina_login.dart';
import 'pages/pagina_mapa_salas.dart';
import 'pages/pagina_recessos.dart';
import 'pages/pagina_resetar_senha.dart';
import 'pages/pagina_salas.dart';
import 'pages/pagina_unidades.dart';
import 'pages/pagina_usuarios_adm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://aiyahroofixqkdxwhtjh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpeWFocm9vZml4cWtkeHdodGpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTU0MjU1MjksImV4cCI6MjExMTAwMTUyOX0.TWasy1zqRi5a24-XHBOtZeJLfGiww9umLm3eSGPSoXk',
  );
  runApp(const GerenciadorAmbientesApp());
}

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
        case '/cadastro': pagina = PaginaCadastro(onNavegar: _irPara); break;
        case '/coordenador': pagina = PaginaCoordenador(onNavegar: _irPara); break;
        case '/unidades': pagina = PaginaUnidades(onNavegar: _irPara); break;
        case '/salas': pagina = PaginaSalas(onNavegar: _irPara); break;
        case '/cursos': pagina = PaginaCursos(onNavegar: _irPara); break;
        case '/cronograma': pagina = PaginaCronograma(onNavegar: _irPara); break;
        case '/mapa': pagina = PaginaMapaSalas(onNavegar: _irPara); break;
        case '/recessos': pagina = PaginaRecessos(onNavegar: _irPara); break;
        case '/usuarios': pagina = PaginaUsuariosAdm(onNavegar: _irPara); break;
        case '/resetar-senha': pagina = PaginaResetarSenha(onNavegar: _irPara); break;
        default: pagina = PaginaDashboard(onNavegar: _irPara);
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