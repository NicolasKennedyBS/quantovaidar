import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum ReceiptStyle {
  simple, modern, tech, premium, minimal,
  construction, creative, health, retro, corporate
}

class PdfUtil {

  static Future<void> generateAndShowReceipt({
    required String issuerName,
    required String clientName,
    required String serviceDescription,
    required String value,
    required String date,
    required ReceiptStyle style,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          switch (style) {
            case ReceiptStyle.modern: return _buildModernLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.tech: return _buildTechLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.premium: return _buildPremiumLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.minimal: return _buildMinimalLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.construction: return _buildConstructionLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.creative: return _buildCreativeLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.health: return _buildHealthLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.retro: return _buildRetroLayout(issuerName, clientName, serviceDescription, value, date);
            case ReceiptStyle.corporate: return _buildCorporateLayout(issuerName, clientName, serviceDescription, value, date);
            default: return _buildSimpleLayout(issuerName, clientName, serviceDescription, value, date);
          }
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Recibo_$clientName.pdf',
    );
  }

  //SIMPLES
  static pw.Widget _buildSimpleLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Header(level: 0, child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("RECIBO", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text("Por: $issuer", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ])
      ])),
      pw.SizedBox(height: 30),
      pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold))),
      pw.Divider(),
      pw.SizedBox(height: 20),
      pw.Text("Recebemos de: $client", style: const pw.TextStyle(fontSize: 18)),
      pw.SizedBox(height: 10),
      pw.Text("Referente a: $service", style: const pw.TextStyle(fontSize: 18)),
      pw.Spacer(),
      pw.Text("Data: $date"),
      pw.SizedBox(height: 10),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      pw.Center(child: pw.Text("Assinatura: $issuer")),
    ]);
  }

  // MODERNO
  static pw.Widget _buildModernLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Container(
        color: PdfColors.blue900,
        padding: const pw.EdgeInsets.all(20),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text("RECIBO", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text("Emitido por: $issuer", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
        ]),
      ),
      pw.SizedBox(height: 40),
      pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 2), borderRadius: pw.BorderRadius.circular(10)),
        padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: pw.Column(children: [
          pw.Text("VALOR TOTAL", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        ]),
      ),
      pw.SizedBox(height: 30),
      _buildRowLabelValue("Cliente", client),
      pw.SizedBox(height: 10),
      _buildRowLabelValue("Serviço", service),
      pw.Spacer(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(date),
        pw.Column(children: [
          pw.Container(width: 150, height: 1, color: PdfColors.blue900),
          pw.Text(issuer),
        ])
      ])
    ]);
  }

  // TECH
  static pw.Widget _buildTechLayout(String issuer, String client, String service, String value, String date) {
    const green = PdfColors.greenAccent;
    const bg = PdfColors.black;
    return pw.Container(
      color: bg,
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text("> SYSTEM.NEW_RECEIPT", style: pw.TextStyle(color: green, font: pw.Font.courier())),
        pw.Text("> ISSUER: $issuer", style: pw.TextStyle(color: green, font: pw.Font.courier(), fontWeight: pw.FontWeight.bold)),
        pw.Divider(color: green),
        pw.SizedBox(height: 20),
        pw.Text("TO: $client", style: pw.TextStyle(color: green, fontSize: 18, font: pw.Font.courier())),
        pw.Text("FOR: $service", style: pw.TextStyle(color: green, fontSize: 18, font: pw.Font.courier())),
        pw.SizedBox(height: 40),
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: green)),
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text("R\$ $value", style: pw.TextStyle(color: green, fontSize: 30, fontWeight: pw.FontWeight.bold, font: pw.Font.courier())),
        ),
        pw.Spacer(),
        pw.Text("> DATE: $date", style: pw.TextStyle(color: green, font: pw.Font.courier())),
        pw.Text("> SIGNED_BY: $issuer", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      ]),
    );
  }

  // PREMIUM
  static pw.Widget _buildPremiumLayout(String issuer, String client, String service, String value, String date) {
    final gold = PdfColors.amber700;
    return pw.Column(children: [
      pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(vertical: 20),
        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: gold, width: 3))),
        child: pw.Text("RECIBO - $issuer".toUpperCase(), style: pw.TextStyle(fontSize: 20, color: PdfColors.black, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 50),
      pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 50, color: gold, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 50),
      _buildGoldRow("CLIENTE", client, gold),
      pw.SizedBox(height: 20),
      _buildGoldRow("SERVIÇO", service, gold),
      pw.Spacer(),
      pw.Center(child: pw.Text("$date  |  $issuer", style: pw.TextStyle(color: gold, fontWeight: pw.FontWeight.bold))),
    ]);
  }

  // MINIMAL
  static pw.Widget _buildMinimalLayout(String issuer, String client, String service, String value, String date) {
    return pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
      pw.Text("Por: $issuer", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
      pw.SizedBox(height: 20),
      pw.Text("Recibo.", style: pw.TextStyle(fontSize: 50, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 50),
      pw.Text(client, style: const pw.TextStyle(fontSize: 20)),
      pw.Text(service, style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
      pw.SizedBox(height: 40),
      pw.Divider(indent: 100, endIndent: 100),
      pw.SizedBox(height: 40),
      pw.Text("R\$ $value", style: const pw.TextStyle(fontSize: 24)),
      pw.SizedBox(height: 100),
      pw.Text(date, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
    ]));
  }

  // CONSTRUCTION
  static pw.Widget _buildConstructionLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Container(height: 20, width: double.infinity, color: PdfColors.orange),
      pw.SizedBox(height: 30),
      pw.Text("ORDEM DE SERVIÇO", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
      pw.Text("Responsável: $issuer", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 40),
      pw.Table(border: pw.TableBorder.all(width: 2), children: [
        pw.TableRow(children: [
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("CLIENTE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(client)),
        ]),
        pw.TableRow(children: [
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("SERVIÇO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(service)),
        ]),
        pw.TableRow(children: [
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("VALOR", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange800))),
          pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("R\$ $value", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
        ]),
      ]),
      pw.Spacer(),
      pw.Container(height: 2, width: 200, color: PdfColors.black),
      pw.Text("ASSINATURA: $issuer"),
      pw.SizedBox(height: 20),
      pw.Container(height: 20, width: double.infinity, color: PdfColors.orange),
    ]);
  }

  // CREATIVE
  static pw.Widget _buildCreativeLayout(String issuer, String client, String service, String value, String date) {
    const purple = PdfColors.purple600;
    return pw.Stack(children: [
      pw.Container(decoration: pw.BoxDecoration(color: purple, borderRadius: pw.BorderRadius.circular(20)), height: 200, width: double.infinity),
      pw.Padding(padding: const pw.EdgeInsets.all(20), child: pw.Column(children: [
        pw.Text("Pagamento Confirmado", style: pw.TextStyle(color: PdfColors.white, fontSize: 18)),
        pw.Text(issuer, style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 40),
        pw.Container(
          decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10), boxShadow: const [pw.BoxShadow(blurRadius: 10, color: PdfColors.grey300)]),
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(children: [
            pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 40, color: purple, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            _buildRowLabelValue("Quem pagou", client),
            pw.SizedBox(height: 15),
            _buildRowLabelValue("Pelo que", service),
            pw.SizedBox(height: 15),
            _buildRowLabelValue("Quando", date),
          ]),
        ),
      ]))
    ]);
  }

  // HEALTH
  static pw.Widget _buildHealthLayout(String issuer, String client, String service, String value, String date) {
    const teal = PdfColors.teal;
    return pw.Column(children: [
      pw.Row(children: [
        pw.Container(width: 10, height: 10, color: teal),
        pw.SizedBox(width: 5),
        pw.Text(issuer, style: pw.TextStyle(color: teal, fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ]),
      pw.SizedBox(height: 40),
      pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(20), color: PdfColors.teal50, child: pw.Text("R\$ $value", style: pw.TextStyle(color: teal, fontSize: 35, fontWeight: pw.FontWeight.bold))),
      pw.SizedBox(height: 40),
      pw.Text(client, style: pw.TextStyle(fontSize: 22)),
      pw.Text(service, style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
      pw.Spacer(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Container(width: 2, height: 40, color: teal),
        pw.SizedBox(width: 10),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(date),
          pw.Text("Profissional: $issuer"),
        ])
      ])
    ]);
  }

  // RETRO
  static pw.Widget _buildRetroLayout(String issuer, String client, String service, String value, String date) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.brown, style: pw.BorderStyle.dashed)),
      padding: const pw.EdgeInsets.all(30),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Center(child: pw.Text("NOTA DE SERVICO", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 24, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 10),
        pw.Divider(borderStyle: pw.BorderStyle.dotted),
        pw.SizedBox(height: 20),
        pw.Text("EMITENTE......: $issuer", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 16)),
        pw.Text("CLIENTE.......: $client", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 16)),
        pw.Text("ITEM..........: $service", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 16)),
        pw.Text("DATA..........: $date", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 16)),
        pw.SizedBox(height: 40),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text("TOTAL LIQUIDO:", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 16)),
          pw.Text("R\$ $value", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 24, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 40),
        pw.Divider(borderStyle: pw.BorderStyle.dotted),
      ]),
    );
  }

  // CORPORATE
  static pw.Widget _buildCorporateLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("RECIBO", style: pw.TextStyle(fontSize: 30, color: PdfColors.red900, fontWeight: pw.FontWeight.bold)),
        pw.Text(issuer, style: const pw.TextStyle(color: PdfColors.grey)),
      ]),
      pw.Divider(color: PdfColors.red900, thickness: 2),
      pw.SizedBox(height: 20),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("PARA:", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.Text(client, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ])),
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("DATA:", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.Text(date, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ])),
      ]),
      pw.SizedBox(height: 30),
      pw.Table.fromTextArray(
        headers: ['Descrição', 'Preço'],
        data: [[service, 'R\$ $value']],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
      ),
      pw.Spacer(),
      pw.Text("Emitido por $issuer", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
    ]);
  }

  // HELPERS
  static pw.Widget _buildRowLabelValue(String label, String value) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey600)),
      pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    ]);
  }

  static pw.Widget _buildGoldRow(String label, String value, PdfColor color) {
    return pw.Row(children: [
      pw.Container(width: 5, height: 50, color: color),
      pw.SizedBox(width: 10),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: color)),
        pw.Text(value, style: pw.TextStyle(fontSize: 18)),
      ])
    ]);
  }
}