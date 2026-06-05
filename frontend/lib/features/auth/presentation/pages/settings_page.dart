import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/presentation/notifiers/empresa_prestadora_notifier.dart';
import '../../../models/presentation/notifiers/auth_notifier.dart';
import '../../../../models/empresa_prestadora.dart';
import '../../../../models/enums.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ── Preferências (SharedPreferences) ────────────────────────────────────────
  bool _notificacoes = true;
  bool _emailMarketing = false;
  bool _notifNovasEmpresas = true;
  bool _notifAvaliacoes = true;
  bool _modoEscuro = false;

  // ── Estado de carregamento ───────────────────────────────────────────────────
  bool _carregandoPerfil = true;

  /// Empresa carregada do banco. Null quando o usuário logado é cliente
  /// ou ainda não concluiu o cadastro de empresa.
  EmpresaPrestadora? _empresa;

  @override
  void initState() {
    super.initState();
    _carregarPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarEmpresa());
  }

  // ── Carregamentos ────────────────────────────────────────────────────────────

  Future<void> _carregarPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificacoes = prefs.getBool('notificacoes') ?? true;
        _emailMarketing = prefs.getBool('emailMarketing') ?? false;
        _notifNovasEmpresas = prefs.getBool('notifNovasEmpresas') ?? true;
        _notifAvaliacoes = prefs.getBool('notifAvaliacoes') ?? true;
        _modoEscuro = prefs.getBool('modoEscuro') ?? false;
      });
    }
  }

  Future<void> _carregarEmpresa() async {
    if (!mounted) return;
    setState(() => _carregandoPerfil = true);

    try {
      // Busca todas as empresas e usa a primeira como perfil da sessão.
      // Numa integração real, filtra pelo ID do usuário logado.
      await context.read<EmpresaPrestadoraNotifier>().buscarTodas();
      final empresas = context.read<EmpresaPrestadoraNotifier>().empresas;

      if (mounted) {
        setState(() {
          _empresa = empresas.isNotEmpty ? empresas.first : null;
          _carregandoPerfil = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregandoPerfil = false);
    }
  }

  Future<void> _salvarPref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  // ── Modal de edição de perfil ────────────────────────────────────────────────

  void _editarPerfil() {
    // Campos pré-preenchidos com dados reais do banco
    final cnpjCtrl =
        TextEditingController(text: _empresa?.cnpj ?? '');
    final reputacaoCtrl =
        TextEditingController(text: _empresa?.reputacao ?? '');
    StatusCuradoria statusSelecionado =
        _empresa?.statusCuradoria ?? StatusCuradoria.emAnalise;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (ctx, setModalState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('Editar Empresa',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context)),
                    ]),
                    const SizedBox(height: 16),

                    // CNPJ
                    _campoFormulario(
                      'CNPJ',
                      cnpjCtrl,
                      'Ex: 00.000.000/0001-00',
                      tipo: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatório';
                        final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (clean.length != 14) return 'CNPJ deve ter 14 dígitos';
                        return null;
                      },
                    ),

                    // Reputação
                    _campoFormulario(
                      'Reputação',
                      reputacaoCtrl,
                      'Ex: Excelente',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),

                    // Status de curadoria
                    const Text('Status de Curadoria',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<StatusCuradoria>(
                      value: statusSelecionado,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0))),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: StatusCuradoria.values
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(_statusLabel(s)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => statusSelecionado = v);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final empresaAtualizada = EmpresaPrestadora(
                            idEmpresa: _empresa?.idEmpresa,
                            cnpj: cnpjCtrl.text.trim(),
                            statusCuradoria: statusSelecionado,
                            reputacao: reputacaoCtrl.text.trim(),
                          );

                          await context
                              .read<EmpresaPrestadoraNotifier>()
                              .salvar(empresaAtualizada);

                          if (mounted) {
                            setState(() => _empresa = empresaAtualizada);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('✅ Empresa atualizada com sucesso!'),
                                backgroundColor: Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Salvar Alterações',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers de label ─────────────────────────────────────────────────────────

  String _statusLabel(StatusCuradoria s) {
    switch (s) {
      case StatusCuradoria.aprovada:
        return 'Aprovada';
      case StatusCuradoria.emAnalise:
        return 'Em análise';
      case StatusCuradoria.reprovada:
        return 'Reprovada';
    }
  }

  Color _statusColor(StatusCuradoria s) {
    switch (s) {
      case StatusCuradoria.aprovada:
        return const Color(0xFF16A34A);
      case StatusCuradoria.emAnalise:
        return const Color(0xFFD97706);
      case StatusCuradoria.reprovada:
        return const Color(0xFFDC2626);
    }
  }

  // ── Sair ─────────────────────────────────────────────────────────────────────

  void _confirmarSair() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tem certeza que deseja sair da sua conta?',
            style: TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthNotifier>().logout();
              if (mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  // ── Limpar cache ─────────────────────────────────────────────────────────────

  void _limparCache() async {
    // Recarrega dados do banco para limpar qualquer estado em memória
    await context.read<EmpresaPrestadoraNotifier>().buscarTodas();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Cache limpo com sucesso!'),
          backgroundColor: Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('Configurações',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF0F172A))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card de perfil ───────────────────────────────────────────────
            _carregandoPerfil
                ? Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : GestureDetector(
                    onTap: _editarPerfil,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                                child: Text('🏢',
                                    style: TextStyle(fontSize: 28))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _empresa == null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nenhuma empresa cadastrada',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Toque para cadastrar',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CNPJ: ${_empresa!.cnpj}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                                    _empresa!.statusCuradoria)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _statusLabel(
                                                _empresa!.statusCuradoria),
                                            style: TextStyle(
                                                color: _statusColor(
                                                    _empresa!.statusCuradoria),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Reputação: ${_empresa!.reputacao}',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 18),
                          ),
                        ]),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),

            // ── Notificações ─────────────────────────────────────────────────
            _secaoTitulo('Notificações'),
            _cardConfig(children: [
              _switchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receber notificações no dispositivo',
                value: _notificacoes,
                onChanged: (v) {
                  setState(() => _notificacoes = v);
                  _salvarPref('notificacoes', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.mail_outline,
                title: 'E-mail Marketing',
                subtitle: 'Promoções e novidades por e-mail',
                value: _emailMarketing,
                onChanged: (v) {
                  setState(() => _emailMarketing = v);
                  _salvarPref('emailMarketing', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.business_outlined,
                title: 'Novas Empresas',
                subtitle: 'Alerta quando empresas do seu segmento entram',
                value: _notifNovasEmpresas,
                onChanged: (v) {
                  setState(() => _notifNovasEmpresas = v);
                  _salvarPref('notifNovasEmpresas', v);
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.star_outline,
                title: 'Avaliações',
                subtitle: 'Notificar quando receber avaliações',
                value: _notifAvaliacoes,
                onChanged: (v) {
                  setState(() => _notifAvaliacoes = v);
                  _salvarPref('notifAvaliacoes', v);
                },
              ),
            ]),
            const SizedBox(height: 16),

            // ── Aparência ────────────────────────────────────────────────────
            _secaoTitulo('Aparência'),
            _cardConfig(children: [
              _switchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Modo Escuro',
                subtitle: 'Alterar tema do aplicativo',
                value: _modoEscuro,
                onChanged: (v) {
                  setState(() => _modoEscuro = v);
                  _salvarPref('modoEscuro', v);
                },
              ),
            ]),
            const SizedBox(height: 16),

            // ── Dados e Privacidade ──────────────────────────────────────────
            _secaoTitulo('Dados e Privacidade'),
            _cardConfig(children: [
              _actionTile(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFF2563EB),
                title: 'Limpar Cache',
                subtitle: 'Remover dados temporários do app',
                onTap: _limparCache,
              ),
              _divider(),
              _actionTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF7C3AED),
                title: 'Política de Privacidade',
                subtitle: 'Leia nossos termos e condições',
                onTap: () {},
              ),
              _divider(),
              _actionTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF0891B2),
                title: 'Termos de Uso',
                subtitle: 'Contrato de uso da plataforma',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 16),

            // ── Suporte ──────────────────────────────────────────────────────
            _secaoTitulo('Suporte'),
            _cardConfig(children: [
              _actionTile(
                icon: Icons.help_outline,
                iconColor: const Color(0xFF16A34A),
                title: 'Central de Ajuda',
                subtitle: 'Dúvidas frequentes e tutoriais',
                onTap: () {},
              ),
              _divider(),
              _actionTile(
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFF2563EB),
                title: 'Falar com Suporte',
                subtitle: 'Chat ao vivo com nossa equipe',
                onTap: () {},
              ),
              _divider(),
              _actionTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF64748B),
                title: 'Versão do App',
                subtitle: 'ConectaServ v1.0.0',
                onTap: null,
                showArrow: false,
              ),
            ]),
            const SizedBox(height: 16),

            // ── Sair ────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmarSair,
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                label: const Text('Sair da Conta',
                    style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────────

  Widget _secaoTitulo(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF64748B),
                letterSpacing: 0.3)),
      );

  Widget _cardConfig({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );

  Widget _divider() =>
      Divider(height: 1, indent: 52, color: Colors.grey[100]);

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2563EB)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      dense: true,
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios,
              size: 13, color: Color(0xFF94A3B8))
          : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      dense: true,
    );
  }

  Widget _campoFormulario(
    String label,
    TextEditingController ctrl,
    String hint, {
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: tipo,
            validator: validator,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF2563EB), width: 2)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFEF4444))),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFEF4444), width: 2)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}