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
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Senha")),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Digite sua nova senha abaixo.",
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Nova Senha",
                  prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Confirmar Nova Senha",
                  prefixIcon: Icon(Icons.lock_reset)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C86D9),
                    foregroundColor: Colors.white),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("ALTERAR SENHA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
