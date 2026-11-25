import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/sistema_state.dart';
import '../../widgets/banner_alerta.dart';

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
    setState(() { _erro = null; _carregando = true; });
    final res = await state.login(_emailCtrl.text.trim(), _senhaCtrl.text);
    if (!mounted) return;
    setState(() => _carregando = false);
    if (res != null) { setState(() => _erro = res); } else { widget.onNavegar('/dashboard'); }
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))]),
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'E-mail', prefixIcon: const Icon(Icons.email, color: AppColors.primary), filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  onSubmitted: (_) => _entrar(),
                  decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock, color: AppColors.primary), filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _entrar,
                    icon: _carregando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.login, size: 18),
                    label: Text(_carregando ? 'Entrando...' : 'Entrar'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60))),
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