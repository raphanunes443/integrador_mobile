import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/sistema_state.dart';
import '../widgets/banner_alerta.dart';
import '../widgets/card_painel.dart';
import '../widgets/shell_layout.dart';

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
    setState(() { _erro = null; _sucesso = null; });
    if (_atual.text.isEmpty || _nova.text.isEmpty || _conf.text.isEmpty) { setState(() => _erro = 'Preencha todos os campos.'); return; }
    if (_nova.text != _conf.text) { setState(() => _erro = 'A confirmação da senha não coincide.'); return; }
    setState(() => _salvando = true);
    final res = await state.alterarSenha(_atual.text, _nova.text);
    if (!mounted) return;
    setState(() {
      _salvando = false;
      if (res != null) { _erro = res; } else { _sucesso = 'Senha alterada com sucesso!'; _atual.clear(); _nova.clear(); _conf.clear(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShellLayout(
      rotaAtiva: '/resetar-senha', titulo: 'Alterar Senha',
      subtitulo: 'Mantenha sua senha segura (${state.emailUsuario})',
      icone: Icons.key, onNavegar: widget.onNavegar,
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
                    Expanded(child: ElevatedButton.icon(
                      onPressed: _salvando ? null : _salvar,
                      icon: _salvando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save, size: 16),
                      label: Text(_salvando ? 'Salvando...' : 'Alterar Senha'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton(onPressed: () => widget.onNavegar('/dashboard'), child: const Text('Cancelar'))),
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