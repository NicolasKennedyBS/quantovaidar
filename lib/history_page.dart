import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart'; 

import 'create_receipt_page.dart';
import 'pdf_util.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'settings_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _userName = '...';
  String _searchQuery = '';
  late Future<List<dynamic>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _invoicesFuture = ApiService().getInvoices();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('default_name') ??
        prefs.getString('userName') ??
        'Usuário';
    if (mounted) setState(() => _userName = name);
  }

  void _refreshInvoices() {
    final novoFuture = ApiService().getInvoices();
    setState(() {
      _invoicesFuture = novoFuture;
    });
  }

  void _logout() async {
    await ApiService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    }
  }

  void _openCustomDialog(Widget page) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (c, a1, a2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 6.0 * anim1.value, sigmaY: 6.0 * anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: Center(
              child: Material(
                elevation: 24,
                borderRadius: BorderRadius.circular(32),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 900,
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: page,
                ),
              ),
            ),
          ),
        );
      },
    );
    if (mounted) {
      _refreshInvoices();
    }
  }

  void _editDocument(BuildContext context, Map<String, dynamic> receipt) {

    final double valorNum = (receipt['totalValue'] as num).toDouble();
    final String valorFormatado =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valorNum);
    
    final Map<String, dynamic> adapted = {
      'id': receipt['id'],
      'client': receipt['clientName'],
      'issuer': receipt['issuerNameSnapshot'],
      'pix': receipt['pixKeySnapshot'],
      'value': valorFormatado,
      'date': receipt['issueDate'],
      'style': receipt['styleCode'] ?? 0,
      'isProduct': receipt['type'] == 1,
      'service': receipt['description'],
      
      'rawDescription': receipt['rawDescription'],
      'itemQty': receipt['itemQty'],
      'itemUnit': receipt['itemUnit'], 
      'itemPrice': receipt['itemPrice'],
      'itemCode': receipt['itemCode'],
      'unit': receipt['itemUnit'],
    };

    if (MediaQuery.of(context).size.width > 900) {
      _openCustomDialog(CreateReceiptPage(receiptToEdit: adapted));
    } else {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateReceiptPage(receiptToEdit: adapted)))
          .then((_) => _refreshInvoices());
    }
  }

  Widget _buildTopBar(Color primary, bool isDark) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/quantovaidartittle.png',
              height: 55, color: isDark ? Colors.white : null),
          PopupMenuButton<String>(
            offset: const Offset(0, 60),
            onSelected: (v) => v == 'sair'
                ? _logout()
                : _openCustomDialog(const SettingsPage()),
            child: CircleAvatar(
                radius: 22,
                backgroundColor: primary.withValues(alpha: 0.1),
                child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : "K",
                    style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18))),
            itemBuilder: (c) => [
              const PopupMenuItem(
                  value: 'aj',
                  child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text("Ajustes"),
                      contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(
                  value: 'sair',
                  child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text("Sair", style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;
    const primaryColor = Color(0xFF4C86D9);

    return Column(
      children: [
        if (isWide) _buildTopBar(primaryColor, isDark),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _invoicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final all = snapshot.data ?? [];

              double totalValue = 0;
              for (var r in all) {
                totalValue += (r['totalValue'] as num).toDouble();
              }
              final formattedTotal = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalValue);

              final filtered = all.where((r) {
                final client = (r['clientName'] ?? '').toString().toLowerCase();
                return client.contains(_searchQuery.toLowerCase());
              }).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Olá, $_userName!",
                                        style: TextStyle(
                                            fontSize: isWide ? 32 : 24,
                                            fontWeight: FontWeight.bold)),
                                    const Text("Resumo do seu faturamento",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                if (isWide)
                                  ElevatedButton.icon(
                                    onPressed: () => _openCustomDialog(const CreateReceiptPage()),
                                    icon: const Icon(Icons.add),
                                    label: const Text("Novo Recibo"),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                _buildCard("Emitidos", "${all.length}", Icons.description_outlined, primaryColor, isDark),
                                const SizedBox(width: 20),
                                _buildTotalCard(formattedTotal, primaryColor),
                              ],
                            ),
                            const SizedBox(height: 50),
                            Text("Documentos Recentes",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87)),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (v) => setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: "Buscar cliente...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: isDark ? Colors.white10 : Colors.grey[100],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            if (filtered.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    children: [
                                      Icon(Icons.description_outlined,
                                          size: 60, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Nenhum recibo encontrado.",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Crie um novo documento para começar!",
                                        style: TextStyle(color: Colors.grey[500]),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...filtered.map((r) => _buildInvoiceItem(r, primaryColor, isDark)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      String label, String val, IconData icon, Color primary, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 28),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text(val,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(String val, Color primary) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF4C86D9), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_graph, color: Colors.white70, size: 28),
            const SizedBox(height: 12),
            const Text("Faturamento Total",
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            FittedBox(
                child: Text(val,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(Map<String, dynamic> r, Color primary, bool isDark) {
    return Dismissible(
      key: Key(r['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteReceipt(r['id']),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(
              backgroundColor: primary.withValues(alpha: 0.1),
              child: Icon(
                  r['type'] == 1
                      ? Icons.shopping_bag_outlined
                      : Icons.work_outline,
                  color: primary)),
          title: Text(r['clientName'] ?? 'Sem Nome',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(
            "${DateFormat('dd/MM/yyyy').format(DateTime.parse(r['issueDate'].toString()))} • R\$ ${r['totalValue']}",
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () => _editDocument(context, r)),
              IconButton(
                  icon:
                      const Icon(Icons.share_rounded, color: Color(0xFF4C86D9)),
                  onPressed: () {
                    
                    if (kDebugMode) {
                      print("DEBUG UNIDADE: ${r['itemUnit']}");
                    }

                    PdfUtil.generateAndShare(
                        issuerName: r['issuerNameSnapshot'],
                        pixKey: r['pixKeySnapshot'] ?? '',
                        clientName: r['clientName'],
                        
                        serviceDescription: r['rawDescription'] ?? r['description'] ?? '',
                        
                        value: "R\$ ${r['totalValue']}",
                        date: r['issueDate'],
                        style: ReceiptStyle.values[r['styleCode'] ?? 0],
                        isProduct: r['type'] == 1,
                        qty: r['itemQty'] ?? '1',
                        unitPrice: r['itemPrice'] ?? '',
                        
                        unit: r['itemUnit'] ?? 'UN' 
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteReceipt(String id) async {
    final success = await ApiService().deleteInvoice(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Recibo removido."), backgroundColor: Colors.green));
      _refreshInvoices();
    }
  }
}