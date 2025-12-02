import 'package:flutter/material.dart';
import 'create_receipt_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Image.asset(
          'assets/images/faturaetransparentname.png',
          height: 100,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue[800]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.8,
              child: SizedBox(
                width: 250,
                child: Image.asset('assets/images/faturaelogotransp.png'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Nenhum recibo gerado ainda.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Botão Principal
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateReceiptPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(
                  "NOVO RECIBO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}