import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _pixController = TextEditingController();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = _prefs?.getString('default_name') ?? '';
      _pixController.text = _prefs?.getString('default_pix') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    final success = await ApiService()
        .updateProfile(_nameController.text, _pixController.text);

    if (success) {
      await _prefs?.setString('default_name', _nameController.text);
      await _prefs?.setString('default_pix', _pixController.text);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Dados salvos na nuvem!" : "Erro ao salvar"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _logout() async {
    await ApiService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, Box box, _) {
          final isDarkMode = box.get('isDarkMode', defaultValue: false);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  const Text(
                    "Configurações",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: SwitchListTile(
                      title: const Text("Modo Escuro",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      secondary:
                          Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                      value: isDarkMode,
                      onChanged: (val) => box.put('isDarkMode', val),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Meus Dados Padrão",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C86D9)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome da Empresa",
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pixController,
                    decoration: const InputDecoration(
                      labelText: "Chave Pix",
                      prefixIcon: Icon(Icons.pix),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveSettings,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload),
                      label:
                          Text(_isLoading ? "SALVANDO..." : "SALVAR NA NUVEM"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C86D9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Divider(),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Sair da Conta",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Usuário: ${_userName()}\nQuantoVaiDar? v1.0",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _userName() => _prefs?.getString('userName') ?? '...';
}
