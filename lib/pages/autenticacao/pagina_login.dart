
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/banner_alerta.dart';

class PaginaLogin extends StatefulWidget {
  final Function(String) onNavegar;

  const PaginaLogin({
    super.key,
    required this.onNavegar,
  });

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {

  // ==========================================================
  // CONTROLADORES E VARIÁVEIS
  // ==========================================================

  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _senhaFocus = FocusNode();

  String? _erro;

  bool _carregando = false;
  bool _mostrarSenha = false;

  // ==========================================================
  // VALIDAÇÃO DOS CAMPOS
  // ==========================================================

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    final regex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!regex.hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }

    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Informe sua senha.';
    }

    return null;
  }

  bool get _erroEmail =>
      _erro != null &&
      _erro!.toLowerCase().contains('mail');

  bool get _erroSenha =>
      _erro != null &&
      _erro!.toLowerCase().contains('senha');

  void _limparErro() {
    if (_erro != null) {
      setState(() {
        _erro = null;
      });
    }
  }

  // ==========================================================
  // AUTENTICAÇÃO
  // ==========================================================

  Future<void> _entrar() async {

    // Impede múltiplas solicitações simultâneas.
    if (_carregando) return;

    setState(() {
      _erro = null;
    });

    // Valida os campos antes da autenticação.
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Fecha o teclado.
    FocusScope.of(context).unfocus();

    // Captura os dados do formulário.
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;

    setState(() {
      _carregando = true;
    });

    try {

      // Realiza a autenticação pelo SistemaState.
      final resultado = await state.login(
        email,
        senha,
      );

      if (!mounted) return;

      // Verifica se ocorreu algum erro.
      if (resultado != null) {
        setState(() {
          _erro = resultado;
        });

        return;
      }

      // Remove a senha do controlador após o sucesso.
      _senhaCtrl.clear();

      // Redireciona para o painel principal.
      widget.onNavegar('/dashboard');

    } catch (_) {

      if (!mounted) return;

      setState(() {
        _erro =
            'Não foi possível realizar o login. '
            'Tente novamente.';
      });

    } finally {

      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // ==========================================================
  // DECORAÇÃO PADRÃO DOS CAMPOS
  // ==========================================================

  InputDecoration _decoracaoCampo({
    required String placeholder,
    required IconData icone,
    bool erro = false,
    Widget? sufixo,
  }) {

    const corErro = Color(0xFFE53935);

    return InputDecoration(

      hintText: placeholder,

      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),

      prefixIcon: Icon(
        icone,
        color: AppColors.primary,
        size: 20,
      ),

      suffixIcon: sufixo,

      filled: true,

      fillColor: erro
          ? const Color(0xFFFFF5F5)
          : AppColors.inputBg,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: BorderSide(
          color: erro ? corErro : AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: BorderSide(
          color: erro ? corErro : AppColors.primary,
          width: 2,
        ),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: corErro,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: corErro,
          width: 2,
        ),
      ),

      errorStyle: const TextStyle(
        color: corErro,
        fontSize: 12,
      ),

      errorMaxLines: 2,
    );
  }

  // ==========================================================
  // CABEÇALHO
  // ==========================================================

  Widget _buildCabecalho() {

    return const Column(
      children: [

        Icon(
          Icons.meeting_room_outlined,
          size: 52,
          color: AppColors.primary,
        ),

        SizedBox(height: 12),

        Text(
          'Gerenciador de Salas',
          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),

        SizedBox(height: 6),

        Text(
          'Gerenciamento de Ambientes',
          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // CAMPO DE E-MAIL
  // ==========================================================

  Widget _buildCampoEmail() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          'E-mail',

          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(

          controller: _emailCtrl,

          enabled: !_carregando,

          keyboardType: TextInputType.emailAddress,

          textInputAction: TextInputAction.next,

          textCapitalization: TextCapitalization.none,

          autocorrect: false,

          enableSuggestions: false,

          autofillHints: const [
            AutofillHints.email,
          ],

          autovalidateMode:
              AutovalidateMode.onUserInteraction,

          validator: _validarEmail,

          onFieldSubmitted: (_) {
            _senhaFocus.requestFocus();
          },

          onChanged: (_) => _limparErro(),

          decoration: _decoracaoCampo(
            placeholder: 'seu.email@usuario.br',
            icone: Icons.email_outlined,
            erro: _erroEmail,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // CAMPO DE SENHA
  // ==========================================================

  Widget _buildCampoSenha() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          'Senha',

          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(

          controller: _senhaCtrl,

          focusNode: _senhaFocus,

          enabled: !_carregando,

          obscureText: !_mostrarSenha,

          keyboardType: TextInputType.visiblePassword,

          textInputAction: TextInputAction.done,

          autocorrect: false,

          enableSuggestions: false,

          autofillHints: const [
            AutofillHints.password,
          ],

          autovalidateMode:
              AutovalidateMode.onUserInteraction,

          validator: _validarSenha,

          onFieldSubmitted: (_) => _entrar(),

          onChanged: (_) => _limparErro(),

          decoration: _decoracaoCampo(

            placeholder: 'Digite sua senha',

            icone: Icons.lock_outline,

            erro: _erroSenha,

            sufixo: IconButton(

              tooltip: _mostrarSenha
                  ? 'Ocultar senha'
                  : 'Mostrar senha',

              icon: Icon(

                _mostrarSenha
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,

                color: AppColors.textMuted,

                size: 20,
              ),

              onPressed: _carregando
                  ? null
                  : () {
                      setState(() {
                        _mostrarSenha = !_mostrarSenha;
                      });
                    },
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BOTÃO ENTRAR — SEM ÍCONE
  // ==========================================================

  Widget _buildBotaoEntrar() {

    return SizedBox(

      width: double.infinity,

      height: 50,

      child: ElevatedButton(

        onPressed: _carregando
            ? null
            : _entrar,

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          disabledBackgroundColor:
              AppColors.primary.withOpacity(0.65),

          disabledForegroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),

          elevation: 4,

          shadowColor:
              AppColors.primary.withOpacity(0.35),
        ),

        child: _carregando

            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  SizedBox(
                    width: 18,
                    height: 18,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(width: 10),

                  Text(
                    'Entrando...',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )

            : const Text(
                'Entrar',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ==========================================================
  // LINK DE CADASTRO
  // ==========================================================

  Widget _buildCadastro() {

    return Wrap(

      alignment: WrapAlignment.center,

      crossAxisAlignment: WrapCrossAlignment.center,

      spacing: 4,

      children: [

        const Text(
          'Não tem uma conta?',

          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),

        TextButton(

          onPressed: _carregando
              ? null
              : () => widget.onNavegar('/cadastro'),

          style: TextButton.styleFrom(

            foregroundColor: AppColors.primary,

            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
          ),

          child: const Text(
            'Cadastre-se gratuitamente',

            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // RODAPÉ DE SEGURANÇA
  // ==========================================================

  Widget _buildRodape() {

    return const Column(

      children: [

        Divider(
          color: AppColors.border,
          thickness: 1,
        ),

        SizedBox(height: 12),

        Row(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.shield_outlined,
              size: 16,
              color: Color(0xFF8A9BB5),
            ),

            SizedBox(width: 6),

            Flexible(
              child: Text(
                'Sistema protegido. Apenas usuários autorizados.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A9BB5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // LIBERAÇÃO DOS RECURSOS
  // ==========================================================

  @override
  void dispose() {

    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _senhaFocus.dispose();

    super.dispose();
  }

  // ==========================================================
  // CONSTRUÇÃO DA PÁGINA
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    final larguraTela = MediaQuery.of(context).size.width;

    final telaPequena = larguraTela < 400;

    return Scaffold(

      backgroundColor: AppColors.bgMain,

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Container(

              width: double.infinity,

              constraints: const BoxConstraints(
                maxWidth: 420,
              ),

              padding: EdgeInsets.symmetric(
                horizontal: telaPequena ? 22 : 36,
                vertical: telaPequena ? 30 : 40,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(24),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: AutofillGroup(

                child: Form(

                  key: _formKey,

                  child: Column(

                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                    children: [

                      // Cabeçalho.
                      _buildCabecalho(),

                      const SizedBox(height: 28),

                      // Mensagens de erro.
                      if (_erro != null) ...[

                        BannerAlerta(
                          texto: _erro!,
                        ),

                        const SizedBox(height: 16),
                      ],

                      // Mensagens do sistema.
                      if (state.flashMsg != null) ...[

                        BannerAlerta(
                          texto: state.flashMsg!,
                          sucesso: state.flashOk,
                        ),

                        const SizedBox(height: 16),
                      ],

                      // Campo de e-mail.
                      _buildCampoEmail(),

                      const SizedBox(height: 18),

                      // Campo de senha.
                      _buildCampoSenha(),

                      const SizedBox(height: 24),

                      // Botão de autenticação.
                      _buildBotaoEntrar(),

                      const SizedBox(height: 14),

                      // Link para cadastro.
                      _buildCadastro(),

                      const SizedBox(height: 14),

                      // Rodapé de segurança.
                      _buildRodape(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
