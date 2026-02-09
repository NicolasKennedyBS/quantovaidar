import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_receipt_page.dart';
import 'pdf_util.dart';
import 'dart:ui';
import 'api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  
  void _editDocument(BuildContext context, Map<String, dynamic> receipt) {
    
    final double valorNum = (receipt['totalValue'] as num).toDouble();
    final String valorFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valorNum);

    final Map<String, dynamic> adaptedReceipt = {
        'id': receipt['id'],
        'client': receipt['clientName'],
        'issuer': receipt['issuerNameSnapshot'],
        'pix': receipt['pixKeySnapshot'],
        'value': valorFormatado,
        'date': receipt['issueDate'],
        'style': receipt['styleCode'] ?? 0,
        'isProduct': receipt['type'] == 1,
        'service': receipt['description'],
        'rawService': receipt['description'],
        'qty': '1', 
        'unitPrice': '',
        'code': '',
        'unit': 'UN'
    };

    final isWebLayout = MediaQuery.of(context).size.width > 900;

    if (isWebLayout) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.2),
        builder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 900,
                    height: MediaQuery.of(context).size.height * 0.95,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CreateReceiptPage(receiptToEdit: adaptedReceipt),
                  ),
                ),
              ),
            ],
          );
        },
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateReceiptPage(receiptToEdit: adaptedReceipt),
        ),
      ).then((_) => setState(() {}));
    }
  }

  Future<void> _deleteReceipt(String id) async {
      final success = await ApiService().deleteInvoice(id);
      
      if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Recibo apagado da nuvem."))
          );
          setState(() {});
      } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Erro ao apagar. Verifique a internet."), backgroundColor: Colors.red)
          );
      }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF4C86D9);
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isWide = MediaQuery.of(context).size.width > 800;

    return FutureBuilder<List<dynamic>>(
      future: ApiService().getInvoices(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
            return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("Erro ao carregar recibos."),
                    TextButton(onPressed: () => setState((){}), child: const Text("Tentar Novamente"))
                ],
            ));
        }

        final receipts = snapshot.data ?? [];
        final int totalCount = receipts.length;
        
        double totalValue = 0;
        for (var r in receipts) {
            totalValue += (r['totalValue'] as num).toDouble();
        }

        final formattedTotal = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalValue);

        return Column(
          children: [
            if (!isWide)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 15),
                child: Text(
                  "Faturaê: Profissionalize sua cobrança.",
                  style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12, letterSpacing: 1.0, fontWeight: FontWeight.w500
                  ),
                ),
              ),

            if (isWide) const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description_outlined, color: primaryColor, size: 24),
                          const SizedBox(height: 10),
                          Text("Emitidos", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Text("$totalCount", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.attach_money, color: Colors.white, size: 24),
                          const SizedBox(height: 10),
                          const Text("Faturamento", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(formattedTotal, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [Text("Documentos Recentes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor))]),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: receipts.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Nenhum recibo na nuvem", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> r = receipts[receipts.length - 1 - index];
                        
                        final String id = r['id'];
                        final double val = (r['totalValue'] as num).toDouble();
                        final String valFormatted = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(val);
                        final bool isProduct = r['type'] == 1;

                        return Dismissible(
                          key: Key(id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                              return true;
                          },
                          onDismissed: (direction) {
                             _deleteReceipt(id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: isDark ? Colors.grey[800] : Colors.blue[50],
                                child: Icon(
                                    isProduct ? Icons.shopping_bag_outlined : Icons.work_outline,
                                    color: primaryColor, size: 20
                                ),
                              ),
                              title: Text(r['clientName'] ?? 'Sem Nome', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              subtitle: Text("${r['issueDate']} • $valFormatted", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                    onPressed: () {
                                      _editDocument(context, r);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share_rounded, size: 20, color: primaryColor),
                                    onPressed: () {
                                      // Gera o PDF na hora
                                      PdfUtil.generateAndShare(
                                        issuerName: r['issuerNameSnapshot'],
                                        pixKey: r['pixKeySnapshot'] ?? '',
                                        clientName: r['clientName'],
                                        serviceDescription: r['description'] ?? '',
                                        value: valFormatted,
                                        date: r['issueDate'],
                                        style: ReceiptStyle.values[r['styleCode'] ?? 0],
                                        isProduct: isProduct,
                                        qty: '1', 
                                        unitPrice: '',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}