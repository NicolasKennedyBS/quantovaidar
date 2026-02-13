import 'package:flutter/material.dart';
import 'api_service.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;

  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    if (_passController.text.isEmpty ||
        _passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("As senhas não coincidem ou estão vazias."),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    bool success =
        await ApiService().redefinirSenha(widget.email, _passController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Senha alterada com sucesso!"),
          backgroundColor: Colors.green));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erro ao redefinir senha."),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4C86D9);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;

    final formContent = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWide) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context)),
                ),
              ],
              const Icon(Icons.lock_open_rounded,
                  size: 60, color: Color(0xFF4C86D9)),
              const SizedBox(height: 24),
              const Text("Nova Senha",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text("Defina sua nova credencial de acesso abaixo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),

              _buildInput(
                controller: _passController,
                label: "Nova Senha",
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 16),

              _buildInput(
                controller: _confirmPassController,
                label: "Confirmar Nova Senha",
                icon: Icons.lock_reset_rounded,
                obscure: true,
              ),

              const SizedBox(height: 32),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("ALTERAR SENHA",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor:
          isWide ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
      body: isWide
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, const Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security_rounded,
                              size: 100, color: Colors.white),
                          const SizedBox(height: 24),
                          const Text("Redefinição Segura",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 12),
                          Text(
                              "Sua nova senha deve ser exclusiva\npara garantir sua proteção.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        child: formContent)),
              ],
            )
          : formContent,
    );
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}
