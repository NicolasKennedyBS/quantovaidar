import 'package:flutter/material.dart';
import 'api_service.dart';
import 'verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pixController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Preencha os campos obrigatórios."),
          backgroundColor: Colors.red));
      return;
    }
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("As senhas não coincidem."),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    final success = await ApiService().registerUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passController.text,
      pixKey: _pixController.text,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => VerificationPage(
                  email: _emailController.text, isRegistration: true)));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erro ao criar conta."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final primaryColor = const Color(0xFF4C86D9);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final formContent = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
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
                const SizedBox(height: 10),
              ],
              const Text("Criar Conta",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text("Comece a emitir recibos profissionais hoje",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 35),
              _buildInput(
                  controller: _nameController,
                  label: "Nome ou Empresa",
                  icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildInput(
                  controller: _emailController,
                  label: "E-mail",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildInput(
                  controller: _pixController,
                  label: "Chave Pix (Opcional)",
                  icon: Icons.pix_outlined),
              const SizedBox(height: 16),
              _buildInput(
                  controller: _passController,
                  label: "Senha",
                  icon: Icons.lock_outline,
                  obscure: true),
              const SizedBox(height: 16),
              _buildInput(
                  controller: _confirmPassController,
                  label: "Repita a Senha",
                  icon: Icons.lock_reset_outlined,
                  obscure: true),
              const SizedBox(height: 32),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                      : const Text("REGISTRAR",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Já tem uma conta?",
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Entrar agora",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
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
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, const Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add_rounded,
                            size: 100, color: Colors.white),
                        const SizedBox(height: 40),
                        const Text("Junte-se a nós",
                            style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.5)),
                        const SizedBox(height: 16),
                        Text(
                            "Cadastre-se para profissionalizar suas cobranças.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
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
      bool obscure = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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
