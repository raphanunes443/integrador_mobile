import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/sistema_state.dart';
import '../core/supabase_config.dart';
import '../widgets/banner_alerta.dart';
import '../widgets/formatters.dart';

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
    if (_nomeOrg.text.isEmpty || _emailOrg.text.isEmpty || _nomeAdm.text.isEmpty || _emailAdm.text.isEmpty) { setState(() => _erro = 'Preencha todos os campos obrigatórios (*).'); return; }
    if (!(_tamOk && _maiOk && _minOk && _espOk && _confOk)) { setState(() => _erro = 'A senha não atende aos requisitos mínimos.'); return; }
    setState(() => _salvando = true);
    try {
      final existe = await supabase.from('usuarios_sistema').select('id_usuario').eq('email_usuario', _emailAdm.text.trim()).maybeSingle();
      if (existe != null) { setState(() { _salvando = false; _erro = 'Já existe uma conta com esse e-mail.'; }); return; }
      
      final cliente = await supabase.from('clientes').insert({
        'nome_cliente': _nomeOrg.text.trim(), 'tipo_cliente': _tipo,
        'cnpj_cliente': _cnpj.text.trim().isEmpty ? null : _cnpj.text.trim(),
        'email_cliente': _emailOrg.text.trim(),
        'telefone_cliente': _tel.text.trim().isEmpty ? null : _tel.text.trim(),
        'status_cliente': 'ativo', 'plano_cliente': 'gratuito',
      }).select().single();
      
      final idCliente = cliente['id_cliente'] as int;
      final hash = BCrypt.hashpw(_senha.text, BCrypt.gensalt());
      await supabase.from('usuarios_sistema').insert({
        'id_cliente': idCliente, 'nome_usuario': _nomeAdm.text.trim(),
        'email_usuario': _emailAdm.text.trim(), 'senha_usuario': hash,
        'tipo_usuario': 'admin_cliente', 'status_usuario': 'ativo',
        'telefone_usuario': _tel.text.trim().isEmpty ? null : _tel.text.trim(),
      });
      
      if (!mounted) return;
      state.setFlash('Cadastro realizado com sucesso! Agora faça login.', ok: true);
      widget.onNavegar('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() { _salvando = false; _erro = 'Erro ao cadastrar: $e'; });
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))]),
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
                        value: _tipo, decoration: _dec('Tipo'),
                        items: const [DropdownMenuItem(value: 'escola', child: Text('Escola')), DropdownMenuItem(value: 'salão', child: Text('Salão')), DropdownMenuItem(value: 'empresa', child: Text('Empresa')), DropdownMenuItem(value: 'outro', child: Text('Outro'))],
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
                  controller: _senha, obscureText: !_verSenha, onChanged: (_) => setState(() {}),
                  decoration: _dec('Senha *').copyWith(suffixIcon: IconButton(icon: Icon(_verSenha ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _verSenha = !_verSenha))),
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 14, runSpacing: 4, children: [_req('6+ caracteres', _tamOk), _req('Letra maiúscula', _maiOk), _req('Letra minúscula', _minOk), _req('Caractere especial', _espOk)]),
                const SizedBox(height: 12),
                TextField(controller: _confirma, obscureText: !_verSenha, onChanged: (_) => setState(() {}), decoration: _dec('Confirmar Senha *')),
                const SizedBox(height: 6),
                _req('As senhas devem coincidir', _confOk),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _salvando ? null : _cadastrar,
                  icon: _salvando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.person_add, size: 18),
                  label: Text(_salvando ? 'Cadastrando...' : 'Cadastrar Organização'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60))),
                ),
                TextButton(onPressed: () => widget.onNavegar('/login'), child: const Text('Já tem uma conta? Faça login')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController c, String hint, {List<TextInputFormatter>? fmt}) => TextField(controller: c, inputFormatters: fmt, decoration: _dec(label).copyWith(hintText: hint));
  InputDecoration _dec(String label) => InputDecoration(labelText: label, filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));
  Widget _req(String t, bool ok) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(ok ? Icons.check_circle : Icons.circle, size: 12, color: ok ? AppColors.successText : AppColors.dangerText), const SizedBox(width: 4), Text(t, style: TextStyle(fontSize: 12, color: ok ? AppColors.successText : AppColors.dangerText))]);
}