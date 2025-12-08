import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pdf_util.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('receipts').listenable(),
      builder: (context, Box box, widget) {

        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 10),
                const Text("Nenhum documento salvo.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final receipts = box.values.toList().reversed.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            final receipt = receipts[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.description, color: Colors.blue),
                ),
                title: Text(
                  receipt['client'] ?? 'Cliente Desconhecido',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${receipt['date']} • R\$ ${receipt['value']}"),
                trailing: const Icon(Icons.share, size: 20, color: Colors.grey),

                onTap: () {
                  PdfUtil.generateAndShare(
                    issuerName: receipt['issuer'],
                    clientName: receipt['client'],
                    serviceDescription: receipt['service'],
                    value: receipt['value'],
                    date: receipt['date'],
                    style: ReceiptStyle.values[receipt['style']],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}