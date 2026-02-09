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
    if (_prefs != null) {
      await _prefs!.setString('default_name', _nameController.text);
      await _prefs!.setString('default_pix', _pixController.text);
      
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados padrão salvos neste celular!"), backgroundColor: Colors.green),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair da Conta?"),
        content: const Text("Você voltará para a tela de login."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              await ApiService().logout();
              
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("SAIR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, Box box, _) {
          final isDark = box.get('isDarkMode', defaultValue: false);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text("Modo Escuro", style: TextStyle(fontWeight: FontWeight.bold)),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  value: isDark,
                  onChanged: (val) {
                    box.put('isDarkMode', val);
                  },
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "Meus Dados (Padrão)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4C86D9)),
              ),
              const SizedBox(height: 5),
              const Text(
                "Preenchemos automaticamente novos recibos com estes dados.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome da Empresa / Emissor", prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _pixController,
                decoration: const InputDecoration(labelText: "Chave Pix (Opcional)", prefixIcon: Icon(Icons.pix), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text("SALVAR NESTE CELULAR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C86D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Sair da Conta", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _logout,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.withOpacity(0.2))),
              ),

              const SizedBox(height: 20),
              Center(child: Text("Usuário: ${_prefs?.getString('userName') ?? '...'}", style: const TextStyle(color: Colors.grey, fontSize: 12))),
              const Center(child: Text("Versão Cloud v1.0", style: TextStyle(color: Colors.grey, fontSize: 10))),
            ],
          );
        }
    );
  }
}