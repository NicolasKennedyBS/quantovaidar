import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

enum ReceiptStyle {
  simple, modern, tech, premium, minimal,
  construction, creative, health, retro, corporate, danfe
}

class PdfUtil {

  static Future<void> generateAndShare({
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
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          switch (style) {
            case ReceiptStyle.danfe: return _buildDanfeLayout(issuerName, clientName, serviceDescription, value, date);
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

    // LÓGICA DE COMPARTILHAMENTO
    final bytes = await doc.save();
    final fileName = 'Recibo_${clientName.replaceAll(" ", "_")}.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/$fileName");
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Olá $clientName, segue seu documento.');
    }
  }

  // --- LAYOUTS ---

  // 1. SIMPLES
  static pw.Widget _buildSimpleLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Header(level: 0, child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("RECIBO", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
        pw.Text("Por: $issuer"),
      ])),
      pw.SizedBox(height: 30),
      pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold))),
      pw.Divider(),
      pw.Text("Cliente: $client", style: const pw.TextStyle(fontSize: 18)),
      pw.SizedBox(height: 10),
      pw.Text("Referente a: $service", style: const pw.TextStyle(fontSize: 18)),
      pw.Spacer(),
      pw.Text("Data: $date"),
      pw.SizedBox(height: 20),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      pw.Center(child: pw.Text("Assinatura: $issuer")),
    ]);
  }

  // 2. DANFE
  static pw.Widget _buildDanfeLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()), height: 60, child: pw.Row(children: [
        pw.Expanded(flex: 4, child: _buildBox("RECEBEMOS DE $issuer OS PRODUTOS CONSTANTES DA NOTA INDICADA AO LADO", "", borderRight: true)),
        pw.Expanded(flex: 1, child: _buildBox("NF-e", "Nº 000.001\nSÉRIE 1", alignCenter: true)),
      ])),
      pw.SizedBox(height: 5),
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()), height: 100, child: pw.Row(children: [
        pw.Expanded(flex: 4, child: pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(issuer.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Text("Natureza da Operação: PRESTAÇÃO DE SERVIÇO", style: const pw.TextStyle(fontSize: 8)),
        ]))),
        pw.Expanded(flex: 2, child: _buildBox("DANFE", "Documento Auxiliar\nda Nota Fiscal\nEletrônica", alignCenter: true, borderRight: true, borderLeft: true)),
      ])),
      pw.SizedBox(height: 5),
      pw.Container(color: PdfColors.grey300, padding: const pw.EdgeInsets.all(2), child: pw.Text("DESTINATÁRIO / REMETENTE", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Row(children: [
        pw.Expanded(flex: 4, child: _buildBox("NOME / RAZÃO SOCIAL", client, borderRight: true)),
        pw.Expanded(flex: 1, child: _buildBox("DATA DA EMISSÃO", date)),
      ])),
      pw.SizedBox(height: 5),
      pw.Container(color: PdfColors.grey300, padding: const pw.EdgeInsets.all(2), child: pw.Text("DADOS DO PRODUTO / SERVIÇO", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
      pw.Table(border: pw.TableBorder.all(width: 0.5), children: [
        pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey200), children: [
          pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text("DESCRIÇÃO", style: const pw.TextStyle(fontSize: 6))),
          pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text("QTD", style: const pw.TextStyle(fontSize: 6))),
          pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text("VL. TOTAL", style: const pw.TextStyle(fontSize: 6))),
        ]),
        pw.TableRow(children: [
          pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(service, style: const pw.TextStyle(fontSize: 8))),
          pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text("1", style: const pw.TextStyle(fontSize: 8))),
          pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(value, style: const pw.TextStyle(fontSize: 8))),
        ]),
      ]),
      pw.Spacer(),
      pw.Center(child: pw.Text("SEM VALOR FISCAL", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.grey300))),
    ]);
  }

  // 3. MODERNO
  static pw.Widget _buildModernLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Container(color: PdfColors.blue900, padding: const pw.EdgeInsets.all(20), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("RECIBO", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text(issuer, style: pw.TextStyle(color: PdfColors.white)),
      ])),
      pw.SizedBox(height: 20),
      pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
      pw.Divider(),
      _buildRowLabelValue("Cliente", client),
      pw.SizedBox(height: 10),
      _buildRowLabelValue("Serviço", service),
      pw.Spacer(),
      pw.Text(date),
    ]);
  }

  // 4. TECH
  static pw.Widget _buildTechLayout(String issuer, String client, String service, String value, String date) {
    const green = PdfColors.greenAccent;
    return pw.Container(color: PdfColors.black, padding: const pw.EdgeInsets.all(20), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text("> SYSTEM.RECEIPT", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.Divider(color: green),
      pw.Text("FROM: $issuer", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.Text("TO: $client", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.Text("VALUE: $value", style: pw.TextStyle(color: green, fontSize: 20, font: pw.Font.courier())),
      pw.Spacer(),
      pw.Text(date, style: pw.TextStyle(color: green, font: pw.Font.courier())),
    ]));
  }

  // 5. PREMIUM
  static pw.Widget _buildPremiumLayout(String issuer, String client, String service, String value, String date) {
    final gold = PdfColors.amber700;
    return pw.Column(children: [
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: gold, width: 3))), child: pw.Text("RECIBO PREMIUM", style: pw.TextStyle(fontSize: 20, color: gold))),
      pw.SizedBox(height: 20),
      pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 40, color: gold)),
      pw.SizedBox(height: 20),
      _buildGoldRow("CLIENTE", client, gold),
      _buildGoldRow("EMISSOR", issuer, gold),
      pw.Spacer(),
      pw.Text(date, style: pw.TextStyle(color: gold)),
    ]);
  }

  // 6. MINIMAL
  static pw.Widget _buildMinimalLayout(String issuer, String client, String service, String value, String date) {
    return pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
      pw.Text(issuer, style: const pw.TextStyle(color: PdfColors.grey)),
      pw.SizedBox(height: 20),
      pw.Text("R\$ $value", style: const pw.TextStyle(fontSize: 30)),
      pw.SizedBox(height: 20),
      pw.Text(client),
      pw.Text(service),
      pw.SizedBox(height: 50),
      pw.Text(date, style: const pw.TextStyle(fontSize: 10)),
    ]));
  }

  // 7. CONSTRUCTION
  static pw.Widget _buildConstructionLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Container(height: 20, color: PdfColors.orange),
      pw.Text("OBRAS & SERVIÇOS", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.Divider(),
      _buildRowLabelValue("Cliente", client),
      _buildRowLabelValue("Valor", "R\$ $value"),
      pw.Spacer(),
      pw.Container(height: 20, color: PdfColors.black),
    ]);
  }

  // 8. CREATIVE
  static pw.Widget _buildCreativeLayout(String issuer, String client, String service, String value, String date) {
    return pw.Container(color: PdfColors.purple100, padding: const pw.EdgeInsets.all(20), child: pw.Column(children: [
      pw.Text("Uhull! Pagamento Recebido!", style: pw.TextStyle(color: PdfColors.purple, fontSize: 20)),
      pw.SizedBox(height: 20),
      pw.Container(color: PdfColors.white, padding: const pw.EdgeInsets.all(20), child: pw.Column(children: [
        pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 30, color: PdfColors.purple)),
        pw.Text(client),
      ])),
      pw.Spacer(),
      pw.Text(issuer),
    ]));
  }

  // 9. HEALTH
  static pw.Widget _buildHealthLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Text(issuer, style: pw.TextStyle(color: PdfColors.teal, fontSize: 20)),
      pw.Divider(color: PdfColors.teal),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("Paciente: $client"),
        pw.Text("R\$ $value", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ]),
      pw.Spacer(),
      pw.Text(date),
    ]);
  }

  // 10. RETRO
  static pw.Widget _buildRetroLayout(String issuer, String client, String service, String value, String date) {
    return pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all(style: pw.BorderStyle.dashed)), padding: const pw.EdgeInsets.all(20), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text("NOTA FISCAL", style: pw.TextStyle(font: pw.Font.courier())),
      pw.Divider(borderStyle: pw.BorderStyle.dotted),
      pw.Text("CLIENTE: $client", style: pw.TextStyle(font: pw.Font.courier())),
      pw.Text("TOTAL: R\$ $value", style: pw.TextStyle(font: pw.Font.courier())),
      pw.Spacer(),
      pw.Text(date, style: pw.TextStyle(font: pw.Font.courier())),
    ]));
  }

  // 11. CORPORATE
  static pw.Widget _buildCorporateLayout(String issuer, String client, String service, String value, String date) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("INVOICE", style: pw.TextStyle(color: PdfColors.red900, fontSize: 24)),
        pw.Text(issuer),
      ]),
      pw.Divider(color: PdfColors.red900),
      _buildRowLabelValue("Bill To", client),
      _buildRowLabelValue("Total", "R\$ $value"),
      pw.Spacer(),
      pw.Text(date),
    ]);
  }

  // Helpers
  static pw.Widget _buildBox(String label, String value, {bool borderRight = false, bool borderLeft = false, bool alignCenter = false}) {
    return pw.Container(padding: const pw.EdgeInsets.all(3), decoration: pw.BoxDecoration(border: pw.Border(right: borderRight ? const pw.BorderSide() : pw.BorderSide.none, left: borderLeft ? const pw.BorderSide() : pw.BorderSide.none)), child: pw.Column(crossAxisAlignment: alignCenter ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start, children: [pw.Text(label, style: const pw.TextStyle(fontSize: 5)), pw.Text(value, style: const pw.TextStyle(fontSize: 8))]));
  }
  static pw.Widget _buildRowLabelValue(String label, String value) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(label), pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]);
  }
  static pw.Widget _buildGoldRow(String label, String value, PdfColor color) {
    return pw.Row(children: [pw.Container(width: 5, height: 20, color: color), pw.SizedBox(width: 5), pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(label, style: pw.TextStyle(fontSize: 8, color: color)), pw.Text(value)])]);
  }
}