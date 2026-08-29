import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/order_model.dart';

class PdfInvoiceService {
  // servicio para generar facturas en formato pdf
  Future<void> generateAndPrintInvoice(OrderModel order) async {
    // crea y muestra el documento pdf de la factura para impresión o descarga
    final doc = pw.Document();

    final orderId = order.id.toString();
    final date = DateTime.tryParse(order.dateCreated);
    final formattedDate = date != null ? DateFormat('dd/MM/yyyy').format(date) : 'N/A';
    
    final total = order.total;
    final billing = order.billing ?? {};
    final firstName = billing['first_name'] ?? '';
    final lastName = billing['last_name'] ?? '';
    final address = billing['address_1'] ?? '';
    final city = billing['city'] ?? '';
    
    final lineItems = order.lineItems;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('NAVIUX EYEWEAR', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('FACTURA', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Nº $orderId'),
                      pw.Text('Fecha: $formattedDate'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Facturar a:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('$firstName $lastName'),
                      pw.Text(address),
                      pw.Text(city),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Naviux Eyewear S.L.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Calle Falsa 123'),
                      pw.Text('Madrid, 28000'),
                      pw.Text('CIF: B12345678'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.TableHelper.fromTextArray(
                headers: ['Descripción', 'Cant.', 'Precio Unit.', 'Total'],
                data: lineItems.map((item) {
                  return [
                    item.name,
                    item.quantity.toString(),
                    '${item.price ?? (double.parse(item.total) / item.quantity).toStringAsFixed(2)} €',
                    '${item.total} €'
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {0: pw.Alignment.centerLeft},
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ${double.tryParse(total.toString()) != null ? (double.parse(total.toString()) / 1.21).toStringAsFixed(2) : "0.00"} €'),
                      pw.Text('IVA (21%): ${double.tryParse(total.toString()) != null ? (double.parse(total.toString()) - (double.parse(total.toString()) / 1.21)).toStringAsFixed(2) : "0.00"} €'),
                      pw.Divider(),
                      pw.Text('Total: $total €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(child: pw.Text('Gracias por su compra en Naviux', style: pw.TextStyle(color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Factura_Naviux_$orderId.pdf',
    );
  }
}
