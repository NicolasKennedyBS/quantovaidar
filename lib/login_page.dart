import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final success =
        await ApiService().login(_emailController.text, _passController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Falha no login. Verifique seus dados."),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: isWide ? Colors.white : const Color(0xFFF5F7FA),
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C86D9), brightness: Brightness.light),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isWide ? const Color(0xFFF5F7FA) : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );

    final formContent = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWide) ...[
                Center(
                    child: Image.asset('assets/images/quantovaidartittle.png',
                        height: 50,
                        errorBuilder: (c, o, s) => const Icon(Icons.receipt,
                            size: 50, color: Color(0xFF4C86D9)))),
                const SizedBox(height: 30),
              ],
              const Text("Bem-vindo de volta",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              const Text("Faça login na sua conta para continuar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
              TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Senha",
                      prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 32),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C86D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("ENTRAR",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta?",
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text("Registre-se agora",
                        style: TextStyle(
                            color: Color(0xFF4C86D9),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Theme(
      data: lightTheme,
      child: Scaffold(
        body: isWide
            ? Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4C86D9), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.receipt_long_rounded,
                                size: 80, color: Colors.white),
                          ),
                          const SizedBox(height: 30),
                          const Text("QuantoVaiDar?",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1)),
                          const SizedBox(height: 16),
                          const Text(
                              "Profissionalize suas cobranças.\nEmita recibos em segundos.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 4, child: formContent),
                ],
              )
            : formContent,
      ),
    );
  }
}
