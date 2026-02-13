import 'package:flutter/material.dart';
import 'api_service.dart';
import 'new_password_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final bool isRegistration;

  const VerificationPage(
      {super.key, required this.email, this.isRegistration = true});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  void _verify() async {
  String cleanCode = _codeController.text.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleanCode.length < 8) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O código deve ter 8 dígitos."),
        backgroundColor: Colors.orange));
    return;
  }

  setState(() => _isLoading = true);
  bool success;

  if (widget.isRegistration) {
    success = await ApiService().confirmRegister(widget.email, cleanCode);
  } else {
    success = await ApiService().validarCodigoRecuperacao(widget.email, cleanCode);
  }

  setState(() => _isLoading = false);

  if (success && mounted) {
    if (widget.isRegistration) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Conta ativada com sucesso!"),
          backgroundColor: Colors.green));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => NewPasswordPage(email: widget.email)));
    }
  } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Código inválido ou expirado."),
        backgroundColor: Colors.red));
  }
}

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4C86D9);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;

    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isRegistration
                      ? Icons.mark_email_read_rounded
                      : Icons.lock_reset_rounded,
                  size: 60,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.isRegistration
                    ? "Verifique seu e-mail"
                    : "Recuperação de Senha",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                "Enviamos um código para ${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 10,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: "0000 0000",
                  counterText: "",
                  filled: true,
                  fillColor: isDark ? Colors.white10 : const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("VERIFICAR",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Voltar", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: isWide
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [primaryColor, const Color(0xFF1E3A8A)]),
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_user_rounded,
                          size: 100, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}
