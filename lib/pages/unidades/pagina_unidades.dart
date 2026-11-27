
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/card_painel.dart';
import '../../widgets/shell_layout.dart';

class PaginaUnidades extends StatefulWidget {
  final Function(String) onNavegar;

  const PaginaUnidades({
    super.key,
    required this.onNavegar,
  });

  @override
  State<PaginaUnidades> createState() => _PaginaUnidadesState();
}

class _PaginaUnidadesState extends State<PaginaUnidades> {
  // ==========================================================
  // CONTROLADORES E VARIÁVEIS
  // ==========================================================

  final _busca = TextEditingController();

  String _filtro = '';
  int _pagina = 0;
  bool _ocupado = false;

  static const int _registrosPorPagina = 8;

  bool get _admin =>
      state.logado &&
      state.tipoUsuario == 'admin_cliente';

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUSCAR UNIDADES
  // ==========================================================

  void _buscar() {
    setState(() {
      _filtro = _busca.text.trim().toLowerCase();
      _pagina = 0;
    });
  }

  void _limparBusca() {
    _busca.clear();

    setState(() {
      _filtro = '';
      _pagina = 0;
    });
  }

  // ==========================================================
  // CADASTRAR OU EDITAR UNIDADE
  // ==========================================================

  Future<void> _editar([
    Map<String, dynamic>? unidade,
  ]) async {
    if (!_admin || _ocupado) return;

    setState(() => _ocupado = true);

    try {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _FormularioUnidade(
          unidade: unidade,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _ocupado = false);
      }
    }
  }

  // ==========================================================
  // ATIVAR OU INATIVAR UNIDADE
  // ==========================================================

  Future<void> _alternar(
    Map<String, dynamic> unidade,
  ) async {
    if (!_admin || _ocupado) return;

    final ativo =
        unidade['status_unidade'] == 'ativo';

    setState(() => _ocupado = true);

    try {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: Text(
            ativo
                ? 'Inativar Unidade'
                : 'Ativar Unidade',
          ),

          content: Text(
            'Tem certeza que deseja '
            '${ativo ? 'inativar' : 'ativar'} '
            'a unidade "${unidade['nome_unidade']}"?',
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, false),

              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(ctx, true),

              style: ElevatedButton.styleFrom(
                backgroundColor: ativo
                    ? AppColors.danger
                    : AppColors.success,

                foregroundColor: Colors.white,
              ),

              child: Text(
                ativo ? 'Inativar' : 'Ativar',
              ),
            ),
          ],
        ),
      );

      if (confirmar == true && mounted) {
        await state.toggleUnidade(unidade);
      }

    } catch (_) {
      if (mounted) {
        state.setFlash(
          'Não foi possível alterar a unidade.',
          ok: false,
        );
      }

    } finally {
      if (mounted) {
        setState(() => _ocupado = false);
      }
    }
  }

  // ==========================================================
  // INDICADOR DE STATUS
  // ==========================================================

  Widget _status(bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: ativo
            ? AppColors.successBg
            : AppColors.dangerBg,

        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            Icons.circle,
            size: 8,

            color: ativo
                ? AppColors.success
                : AppColors.danger,
          ),

          const SizedBox(width: 6),

          Text(
            ativo ? 'Ativo' : 'Inativo',

            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,

              color: ativo
                  ? AppColors.successText
                  : AppColors.dangerText,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTÕES DE AÇÃO
  // ==========================================================

  Widget _acao({
    required String texto,
    required IconData icone,
    required Color fundo,
    required Color cor,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: _ocupado ? null : onPressed,

      icon: Icon(
        icone,
        size: 15,
      ),

      label: Text(
        texto,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      style: TextButton.styleFrom(
        backgroundColor: fundo,
        foregroundColor: cor,

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ==========================================================
  // BOTÃO NOVA UNIDADE
  // ==========================================================

  Widget _buildNovaUnidade() {
    return Align(
      alignment: Alignment.centerRight,

      child: ElevatedButton.icon(
        onPressed: _ocupado
            ? null
            : () => _editar(),

        icon: const Icon(
          Icons.add_circle_outline,
          size: 19,
        ),

        label: const Text(
          'Nova Unidade',

          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          elevation: 2,
        ),
      ),
    );
  }

  // ==========================================================
  // MENSAGENS DO SISTEMA
  // ==========================================================

  Widget _buildMensagem() {
    final sucesso = state.flashOk;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: sucesso
            ? AppColors.successBg
            : AppColors.dangerBg,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: sucesso
              ? AppColors.success.withOpacity(0.3)
              : AppColors.danger.withOpacity(0.3),
        ),
      ),

      child: Row(
        children: [
          Icon(
            sucesso
                ? Icons.check_circle_outline
                : Icons.error_outline,

            color: sucesso
                ? AppColors.successText
                : AppColors.dangerText,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              state.flashMsg ?? '',

              style: TextStyle(
                color: sucesso
                    ? AppColors.successText
                    : AppColors.dangerText,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Fechar mensagem',

            onPressed: () {
              setState(() {
                state.flashMsg = null;
              });
            },

            icon: const Icon(
              Icons.close,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CAMPO DE BUSCA
  // ==========================================================

  Widget _buildBusca(int total) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,

      crossAxisAlignment:
          WrapCrossAlignment.center,

      children: [
        SizedBox(
          width: 250,

          child: TextField(
            controller: _busca,

            textInputAction: TextInputAction.search,

            onSubmitted: (_) => _buscar(),

            decoration: InputDecoration(
              hintText: 'Buscar unidade...',

              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textMuted,
                size: 20,
              ),

              filled: true,
              fillColor: AppColors.inputBg,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),

                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),

                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        ElevatedButton.icon(
          onPressed: _buscar,

          icon: const Icon(
            Icons.search,
            size: 18,
          ),

          label: const Text('Buscar'),

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,

            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
        ),

        if (_filtro.isNotEmpty)
          TextButton(
            onPressed: _limparBusca,

            child: const Text('Limpar'),
          ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color: AppColors.bgMain,
            borderRadius: BorderRadius.circular(8),
          ),

          child: Text(
            'Total: $total',

            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TABELA DE UNIDADES
  // ==========================================================

  Widget _buildTabela(
    List<Map<String, dynamic>> registros,
  ) {
    if (state.carregando) {
      return const Padding(
        padding: EdgeInsets.all(32),

        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (registros.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),

        child: Column(
          children: [
            Icon(
              Icons.business_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),

            SizedBox(height: 12),

            Text(
              'Nenhuma unidade encontrada.',

              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),

            child: DataTable(
              headingRowHeight: 48,

              headingRowColor:
                  MaterialStateProperty.all(
                AppColors.bgMain,
              ),

              headingTextStyle: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),

              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textBody,
              ),

              dataRowMinHeight: 56,
              dataRowMaxHeight: 76,

              horizontalMargin: 16,
              columnSpacing: 24,

              dividerThickness: 0.8,

              columns: [
                const DataColumn(
                  label: Text('Nome'),
                ),

                const DataColumn(
                  label: Text('Cidade'),
                ),

                const DataColumn(
                  label: Text('UF'),
                ),

                const DataColumn(
                  label: Text('Telefone'),
                ),

                const DataColumn(
                  label: Text('Status'),
                ),

                if (_admin)
                  const DataColumn(
                    label: Text('Ações'),
                  ),
              ],

              rows: registros.map((unidade) {
                final ativo =
                    unidade['status_unidade'] ==
                        'ativo';

                final telefone =
                    (unidade['telefone_unidade'] ?? '')
                        .toString();

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '${unidade['nome_unidade'] ?? ''}',

                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    DataCell(
                      Text(
                        '${unidade['cidade_unidade'] ?? ''}',
                      ),
                    ),

                    DataCell(
                      Text(
                        '${unidade['estado_unidade'] ?? ''}',
                      ),
                    ),

                    DataCell(
                      Text(
                        telefone.isEmpty ? '—' : telefone,
                      ),
                    ),

                    DataCell(
                      _status(ativo),
                    ),

                    if (_admin)
                      DataCell(
                        Row(
                          children: [
                            _acao(
                              texto: 'Editar',
                              icone: Icons.edit_outlined,

                              fundo: const Color(
                                0xFFE8F0FE,
                              ),

                              cor: AppColors.primary,

                              onPressed: () =>
                                  _editar(unidade),
                            ),

                            const SizedBox(width: 6),

                            _acao(
                              texto: ativo
                                  ? 'Inativar'
                                  : 'Ativar',

                              icone: ativo
                                  ? Icons.block
                                  : Icons.check_circle_outline,

                              fundo: ativo
                                  ? const Color(0xFFFFF3CD)
                                  : AppColors.successBg,

                              cor: ativo
                                  ? const Color(0xFF856404)
                                  : AppColors.successText,

                              onPressed: () =>
                                  _alternar(unidade),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // PAGINAÇÃO
  // ==========================================================

  Widget _buildPaginacao(
    int paginaAtual,
    int totalPaginas,
  ) {
    if (totalPaginas <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),

      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment:
            WrapCrossAlignment.center,

        spacing: 6,
        runSpacing: 6,

        children: [
          IconButton(
            tooltip: 'Página anterior',

            onPressed: paginaAtual > 0
                ? () {
                    setState(() {
                      _pagina = paginaAtual - 1;
                    });
                  }
                : null,

            icon: const Icon(Icons.chevron_left),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              color: AppColors.primary,

              borderRadius:
                  BorderRadius.circular(8),
            ),

            child: Text(
              '${paginaAtual + 1} de $totalPaginas',

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Próxima página',

            onPressed:
                paginaAtual + 1 < totalPaginas
                    ? () {
                        setState(() {
                          _pagina = paginaAtual + 1;
                        });
                      }
                    : null,

            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CONSTRUÇÃO DA PÁGINA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // Filtra os registros.
    final unidades = state.unidades.where((unidade) {
      return [
        'nome_unidade',
        'cidade_unidade',
        'estado_unidade',
      ].any(
        (campo) => (unidade[campo] ?? '')
            .toString()
            .toLowerCase()
            .contains(_filtro),
      );
    }).toList();

    // Ordenação alfabética.
    unidades.sort(
      (a, b) => (a['nome_unidade'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo(
            (b['nome_unidade'] ?? '')
                .toString()
                .toLowerCase(),
          ),
    );

    // Calcula a quantidade de páginas.
    final totalPaginas =
        (unidades.length / _registrosPorPagina)
            .ceil();

    final paginaAtual = totalPaginas == 0
        ? 0
        : _pagina
            .clamp(0, totalPaginas - 1)
            .toInt();

    // Seleciona os registros da página atual.
    final registros = unidades
        .skip(paginaAtual * _registrosPorPagina)
        .take(_registrosPorPagina)
        .toList();

    return ShellLayout(
      rotaAtiva: '/unidades',

      titulo: 'Unidades',

      subtitulo:
          'Gerencie as unidades cadastradas no sistema',

      icone: Icons.business,

      onNavegar: widget.onNavegar,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          if (_admin) ...[
            _buildNovaUnidade(),

            const SizedBox(height: 20),
          ],

          if (state.flashMsg != null)
            _buildMensagem(),

          CardPainel(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: AppColors.primary,
                      size: 22,
                    ),

                    SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Lista de Unidades',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Divider(
                  color: AppColors.border,
                ),

                const SizedBox(height: 12),

                _buildBusca(unidades.length),

                const SizedBox(height: 20),

                _buildTabela(registros),

                _buildPaginacao(
                  paginaAtual,
                  totalPaginas,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FORMULÁRIO DE CADASTRO E EDIÇÃO DE UNIDADES
// ============================================================

class _FormularioUnidade extends StatefulWidget {
  final Map<String, dynamic>? unidade;

  const _FormularioUnidade({
    this.unidade,
  });

  @override
  State<_FormularioUnidade> createState() =>
      _FormularioUnidadeState();
}

class _FormularioUnidadeState
    extends State<_FormularioUnidade> {

  final _form = GlobalKey<FormState>();

  late final Map<String, TextEditingController> _ctrl;

  late String _status;
  late String _fuso;
  late String? _uf;

  bool _salvando = false;

  String? _erro;

  // ==========================================================
  // ESTADOS BRASILEIROS
  // ==========================================================

  static const _ufs = [
    'AC', 'AL', 'AP', 'AM',
    'BA', 'CE', 'DF', 'ES',
    'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR',
    'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO',
  ];

  // ==========================================================
  // FUSOS HORÁRIOS
  // ==========================================================

  static const _fusos = {
    'America/Noronha':
        'Fernando de Noronha (UTC-2)',

    'America/Belem':
        'Belém (UTC-3)',

    'America/Fortaleza':
        'Fortaleza (UTC-3)',

    'America/Recife':
        'Recife (UTC-3)',

    'America/Araguaina':
        'Araguaína (UTC-3)',

    'America/Maceio':
        'Maceió (UTC-3)',

    'America/Bahia':
        'Salvador (UTC-3)',

    'America/Sao_Paulo':
        'São Paulo (UTC-3)',

    'America/Campo_Grande':
        'Campo Grande (UTC-4)',

    'America/Cuiaba':
        'Cuiabá (UTC-4)',

    'America/Santarem':
        'Santarém (UTC-3)',

    'America/Porto_Velho':
        'Porto Velho (UTC-4)',

    'America/Boa_Vista':
        'Boa Vista (UTC-4)',

    'America/Manaus':
        'Manaus (UTC-4)',

    'America/Eirunepe':
        'Eirunepé (UTC-5)',

    'America/Rio_Branco':
        'Rio Branco (UTC-5)',
  };

  bool get _editando => widget.unidade != null;

  // ==========================================================
  // INICIALIZAÇÃO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _ctrl = {
      for (final campo in [
        'nome',
        'cidade',
        'endereco',
        'telefone',
        'email',
      ])

        campo: TextEditingController(
          text: (
            widget.unidade?['${campo}_unidade'] ??
                ''
          ).toString(),
        ),
    };

    final estado =
        (widget.unidade?['estado_unidade'] ?? '')
            .toString()
            .trim()
            .toUpperCase();

    _uf = _ufs.contains(estado) ? estado : null;

    _status =
        widget.unidade?['status_unidade'] ==
                'inativo'
            ? 'inativo'
            : 'ativo';

    final fuso = widget.unidade?['fuso'];

    _fuso = _fusos.containsKey(fuso)
        ? fuso as String
        : 'America/Sao_Paulo';
  }

  @override
  void dispose() {
    for (final controlador in _ctrl.values) {
      controlador.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // DECORAÇÃO DOS CAMPOS
  // ==========================================================

  InputDecoration _decoracao({
    required String dica,
    IconData? icone,
  }) {
    return InputDecoration(
      hintText: dica,

      hintStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textMuted,
      ),

      prefixIcon: icone == null
          ? null
          : Icon(
              icone,
              size: 19,
              color: AppColors.primary,
            ),

      filled: true,
      fillColor: AppColors.inputBg,

      counterText: '',

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 2,
        ),
      ),
    );
  }

  // ==========================================================
  // RÓTULO DOS CAMPOS
  // ==========================================================

  Widget _rotulo(
    String texto, {
    bool obrigatorio = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Text(
        '$texto${obrigatorio ? ' *' : ''}',

        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // ==========================================================
  // CAMPO DE TEXTO
  // ==========================================================

  Widget _campo({
    required String chave,
    required String rotulo,
    required String dica,
    required IconData icone,
    bool obrigatorio = true,
    TextInputType? teclado,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _rotulo(
            rotulo,
            obrigatorio: obrigatorio,
          ),

          TextFormField(
            controller: _ctrl[chave],

            enabled: !_salvando,

            keyboardType: teclado,

            maxLength: const {
              'nome': 100,
              'cidade': 80,
              'endereco': 200,
              'telefone': 15,
              'email': 100,
            }[chave],

            decoration: _decoracao(
              dica: dica,
              icone: icone,
            ),

            validator: (valor) {
              final texto = valor?.trim() ?? '';

              if (obrigatorio && texto.isEmpty) {
                return 'Campo obrigatório.';
              }

              if (chave == 'email' &&
                  texto.isNotEmpty &&
                  !RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(texto)) {
                return 'Informe um e-mail válido.';
              }

              if (chave == 'telefone' &&
                  texto.isNotEmpty) {

                final numeros = texto.replaceAll(
                  RegExp(r'\D'),
                  '',
                );

                if (!RegExp(
                  r'^[0-9()+\s-]+$',
                ).hasMatch(texto) ||
                    ![10, 11].contains(numeros.length)) {
                  return 'Informe um telefone válido com DDD.';
                }
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SELEÇÃO DA UF
  // ==========================================================

  Widget _campoUf() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _rotulo(
            'UF',
            obrigatorio: true,
          ),

          DropdownButtonFormField<String>(
            value: _uf,
            isExpanded: true,

            decoration: _decoracao(
              dica: 'Selecione o estado',
              icone: Icons.map_outlined,
            ),

            items: _ufs.map((uf) {
              return DropdownMenuItem(
                value: uf,
                child: Text(uf),
              );
            }).toList(),

            validator: (valor) =>
                valor == null
                    ? 'Selecione uma UF.'
                    : null,

            onChanged: _salvando
                ? null
                : (valor) {
                    setState(() {
                      _uf = valor;
                    });
                  },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SELEÇÃO DE STATUS
  // ==========================================================

  Widget _campoStatus() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _rotulo(
            'Status',
            obrigatorio: true,
          ),

          DropdownButtonFormField<String>(
            value: _status,

            decoration: _decoracao(
              dica: 'Selecione o status',
              icone: Icons.check_circle_outline,
            ),

            items: const [
              DropdownMenuItem(
                value: 'ativo',
                child: Text('Ativo'),
              ),

              DropdownMenuItem(
                value: 'inativo',
                child: Text('Inativo'),
              ),
            ],

            onChanged: _salvando
                ? null
                : (valor) {
                    if (valor == null) return;

                    setState(() {
                      _status = valor;
                    });
                  },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SELEÇÃO DO FUSO HORÁRIO
  // ==========================================================

  Widget _campoFuso() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        _rotulo(
          'Fuso horário',
          obrigatorio: true,
        ),

        DropdownButtonFormField<String>(
          value: _fuso,

          isExpanded: true,

          decoration: _decoracao(
            dica: 'Selecione o fuso horário',
            icone: Icons.access_time,
          ),

          items: _fusos.entries.map((fuso) {
            return DropdownMenuItem(
              value: fuso.key,
              child: Text(
                fuso.value,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),

          onChanged: _salvando
              ? null
              : (valor) {
                  if (valor == null) return;

                  setState(() {
                    _fuso = valor;
                  });
                },
        ),

        const SizedBox(height: 8),

        const Text(
          'Selecione o fuso horário correspondente '
          'à localização da unidade.',

          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SALVAR UNIDADE
  // ==========================================================

  Future<void> _salvar() async {
    if (_salvando) return;

    if (_form.currentState?.validate() != true) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _salvando = true;
      _erro = null;
    });

    String valor(String campo) {
      return _ctrl[campo]!.text.trim();
    }

    try {
      final sucesso = await state.salvarUnidade(
        id: widget.unidade?['id_unidade'] as int?,

        nome: valor('nome'),
        cidade: valor('cidade'),
        estado: _uf!,
        endereco: valor('endereco'),
        telefone: valor('telefone'),
        email: valor('email'),
        status: _status,
        fuso: _fuso,
      );

      if (!mounted) return;

      if (sucesso) {
        setState(() => _salvando = false);

        Navigator.pop(context, true);

        return;
      }

      setState(() {
        _erro = state.flashMsg ??
            'Não foi possível salvar a unidade.';
      });

    } catch (_) {
      if (mounted) {
        setState(() {
          _erro =
              'Ocorreu um erro ao salvar a unidade.';
        });
      }

    } finally {
      if (mounted && _salvando) {
        setState(() => _salvando = false);
      }
    }
  }

  // ==========================================================
  // CONSTRUÇÃO DO FORMULÁRIO
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_salvando,

      child: AlertDialog(
        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        insetPadding: const EdgeInsets.all(16),

        title: Row(
          children: [
            Icon(
              _editando
                  ? Icons.edit_outlined
                  : Icons.add_circle_outline,

              color: AppColors.primary,
              size: 25,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _editando
                    ? 'Editar Unidade'
                    : 'Cadastrar Unidade',

                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),

        content: SizedBox(
          width: 580,

          child: SingleChildScrollView(
            child: Form(
              key: _form,

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [
                  const Text(
                    'Preencha os dados da unidade.',

                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Divider(
                    color: AppColors.border,
                  ),

                  const SizedBox(height: 12),

                  if (_erro != null)
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,

                        borderRadius:
                            BorderRadius.circular(8),
                      ),

                      child: Text(
                        _erro!,

                        style: const TextStyle(
                          color: AppColors.dangerText,
                        ),
                      ),
                    ),

                  _campo(
                    chave: 'nome',
                    rotulo: 'Nome da unidade',
                    dica: 'Ex: Unidade Centro',
                    icone: Icons.business_outlined,
                  ),

                  // UF e cidade lado a lado em telas maiores.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cidade = _campo(
                        chave: 'cidade',
                        rotulo: 'Cidade',
                        dica: 'Ex: Belo Horizonte',
                        icone: Icons.location_city,
                      );

                      if (constraints.maxWidth < 420) {
                        return Column(
                          children: [
                            _campoUf(),
                            cidade,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          SizedBox(
                            width: 150,
                            child: _campoUf(),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: cidade,
                          ),
                        ],
                      );
                    },
                  ),

                  _campo(
                    chave: 'endereco',
                    rotulo: 'Endereço',
                    dica: 'Ex: Rua Augusta, 1000',
                    icone: Icons.location_on_outlined,
                  ),

                  _campo(
                    chave: 'telefone',
                    rotulo: 'Telefone',
                    dica: '(31) 33333-3333',
                    icone: Icons.phone_outlined,
                    obrigatorio: false,
                    teclado: TextInputType.phone,
                  ),

                  _campo(
                    chave: 'email',
                    rotulo: 'E-mail',
                    dica: 'unidade@exemplo.com',
                    icone: Icons.email_outlined,
                    obrigatorio: false,
                    teclado:
                        TextInputType.emailAddress,
                  ),

                  _campoStatus(),

                  _campoFuso(),

                  const SizedBox(height: 16),

                  const Text(
                    '* Campos obrigatórios',

                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        actions: [
          OutlinedButton(
            onPressed: _salvando
                ? null
                : () => Navigator.pop(context),

            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textBody,

              side: const BorderSide(
                color: AppColors.border,
              ),
            ),

            child: const Text('Cancelar'),
          ),

          ElevatedButton(
            onPressed: _salvando
                ? null
                : _salvar,

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,

              disabledBackgroundColor:
                  AppColors.primary.withOpacity(0.65),

              disabledForegroundColor: Colors.white,

              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30),
              ),
            ),

            child: _salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _editando
                        ? 'Salvar Alterações'
                        : 'Cadastrar Unidade',
                  ),
          ),
        ],
      ),
    );
  }
}
