import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pdf_util.dart';

class CreateReceiptPage extends StatefulWidget {
  final Map? receiptToEdit;
  final int? hiveKey;

  const CreateReceiptPage({super.key, this.receiptToEdit, this.hiveKey});

  @override
  State<CreateReceiptPage> createState() => _CreateReceiptPageState();
}

class _CreateReceiptPageState extends State<CreateReceiptPage> {

  final _issuerController = TextEditingController();
  final _pixController = TextEditingController();
  final _clientController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();

  final _descriptionController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  final _codeController = TextEditingController();
  final _unitController = TextEditingController(text: 'UN');

  bool _isProduct = false;

  @override
  void initState() {
    super.initState();

    _qtyController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);

    if (widget.receiptToEdit != null) {

      final r = widget.receiptToEdit!;
      _issuerController.text = r['issuer'];
      _pixController.text = r['pix'] ?? '';
      _clientController.text = r['client'];
      _valueController.text = r['value'];
      _dateController.text = r['date'];

      _isProduct = r['isProduct'] ?? false;
      if (_isProduct) {
        _descriptionController.text = r['rawService'] ?? '';
        _qtyController.text = r['qty'] ?? '1';
        _unitPriceController.text = r['unitPrice'] ?? '';
        _codeController.text = r['code'] ?? '';
        _unitController.text = r['unit'] ?? 'UN';
      } else {
        _descriptionController.text = r['service'];
      }

    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      var settingsBox = Hive.box('settings');
      _issuerController.text = settingsBox.get('default_name', defaultValue: '');
      _pixController.text = settingsBox.get('default_pix', defaultValue: '');
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_isProduct) {
      double qty = double.tryParse(_qtyController.text) ?? 0;
      String cleanPrice = _unitPriceController.text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.');
      double price = double.tryParse(cleanPrice) ?? 0;

      double total = qty * price;

      if (total > 0) {
        final formatter = NumberFormat("#,##0.00", "pt_BR");
        _valueController.text = formatter.format(total);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.receiptToEdit != null ? "Editar Documento" : "Novo Documento", style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isProduct = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isProduct ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                        ),
                        child: Text(
                          "SERVIÇO",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: !_isProduct ? Colors.white : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isProduct = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isProduct ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                        ),
                        child: Text(
                          "PRODUTO / VENDA",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: _isProduct ? Colors.white : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _issuerController,
                    decoration: const InputDecoration(labelText: "Quem está emitindo?", border: InputBorder.none, icon: Icon(Icons.store, color: Colors.blue)),
                  ),
                  const Divider(),
                  TextField(
                    controller: _pixController,
                    decoration: const InputDecoration(labelText: "Chave Pix (Opcional)", border: InputBorder.none, icon: Icon(Icons.pix, color: Colors.green)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text("Detalhes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: "Nome do Cliente",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                filled: true, fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            if (_isProduct) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: "Cód.",
                        hintText: "001",
                        border: OutlineInputBorder(),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: "Un.",
                        hintText: "UN",
                        border: OutlineInputBorder(),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Qtd",
                        border: OutlineInputBorder(),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Nome do Produto",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _unitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Unit. (R\$)",
                        border: OutlineInputBorder(),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descrição do Serviço",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                  filled: true, fillColor: Colors.white,
                ),
              ),
            ],

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    readOnly: _isProduct,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                    decoration: InputDecoration(
                      labelText: "Valor Total (R\$)",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: _isProduct ? Colors.grey.shade200 : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: "Data",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      filled: true, fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_issuerController.text.isEmpty || _clientController.text.isEmpty || _valueController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha os campos obrigatórios."), backgroundColor: Colors.red));
                    return;
                  }
                  _showModelSelection(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(widget.receiptToEdit != null ? "ATUALIZAR E GERAR" : "GERAR DOCUMENTO", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, elevation: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text("Escolha o Layout", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildModelOption(context, "DANFE (Nota Fiscal)", "Estilo oficial com código de barras", Icons.receipt_long, Colors.blueGrey, ReceiptStyle.danfe),
                    _buildModelOption(context, "Executivo", "Azul Profissional", Icons.business, Colors.blue[800]!, ReceiptStyle.modern),
                    _buildModelOption(context, "Tech Dev", "Hacker", Icons.terminal, Colors.green, ReceiptStyle.tech),
                    _buildModelOption(context, "Premium Gold", "Sofisticado", Icons.workspace_premium, Colors.amber[800]!, ReceiptStyle.premium),
                    _buildModelOption(context, "Minimalista", "Design Clean", Icons.circle_outlined, Colors.black, ReceiptStyle.minimal),
                    _buildModelOption(context, "Obras & Construção", "Forte e Visível", Icons.construction, Colors.orange[800]!, ReceiptStyle.construction),
                    _buildModelOption(context, "Criativo", "Roxo Moderno", Icons.auto_awesome, Colors.purple, ReceiptStyle.creative),
                    _buildModelOption(context, "Saúde & Bem-estar", "Relaxante", Icons.spa, Colors.teal, ReceiptStyle.health),
                    _buildModelOption(context, "Retrô", "Nota Fiscal Antiga", Icons.receipt, Colors.brown, ReceiptStyle.retro),
                    _buildModelOption(context, "Corporativo", "Internacional", Icons.apartment, Colors.red[900]!, ReceiptStyle.corporate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModelOption(BuildContext context, String title, String subtitle, IconData icon, Color color, ReceiptStyle style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.pop(context);
          _saveAndGeneratePdf(style);
        },
      ),
    );
  }

  void _saveAndGeneratePdf(ReceiptStyle style) async {
    var box = Hive.box('receipts');

    String finalDescription = _descriptionController.text;
    if (_isProduct) {
      finalDescription = "${_qtyController.text}x $_finalDescription";
    }

    final receiptData = {
      'id': widget.receiptToEdit != null ? widget.receiptToEdit!['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
      'issuer': _issuerController.text,
      'pix': _pixController.text,
      'client': _clientController.text,
      'service': finalDescription,
      'rawService': _descriptionController.text,
      'value': _valueController.text,
      'date': _dateController.text,
      'style': style.index,
      'isProduct': _isProduct,
      'qty': _qtyController.text,
      'unitPrice': _unitPriceController.text,
      'code': _codeController.text,
      'unit': _unitController.text,

      'createdAt': DateTime.now().toString(),
    };

    if (widget.hiveKey != null) {
      await box.put(widget.hiveKey, receiptData);
    } else {
      await box.add(receiptData);
    }

    if (mounted && widget.hiveKey != null) Navigator.pop(context);

    await PdfUtil.generateAndShare(
      issuerName: _issuerController.text,
      pixKey: _pixController.text,
      clientName: _clientController.text,
      serviceDescription: _descriptionController.text,
      value: _valueController.text,
      date: _dateController.text,
      style: style,

      isProduct: _isProduct,
      qty: _qtyController.text,
      unitPrice: _unitPriceController.text,
    );
  }

  String get _finalDescription => _descriptionController.text;
}