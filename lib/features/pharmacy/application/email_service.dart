import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/models/catalog_item.dart';

class PharmacyEmailService {
  static Future<void> sendOrder({
    required String pharmacyName,
    required String cif,
    required String address,
    required String phone,
    required String email,
    required List<CatalogItem> items,
    String? attachmentPath,
  }) async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("DATOS DE LA FARMACIA");
    buffer.writeln("=========================");
    buffer.writeln("Nombre: $pharmacyName");
    if (cif != "Pendiente") buffer.writeln("CIF: $cif");
    buffer.writeln("Dirección: $address");
    buffer.writeln("Teléfono: $phone");
    buffer.writeln("Email: $email");
    
    if (items.isNotEmpty) {
      buffer.writeln("\nDETALLES DEL PEDIDO");
      buffer.writeln("=========================");
      // ... rest of logic for items
    } else if (attachmentPath != null) {
      buffer.writeln("\nDETALLES DEL PEDIDO");
      buffer.writeln("=========================");
      buffer.writeln("El pedido se adjunta en el archivo PDF rellenado por el cliente.");
    }

    buffer.writeln("\n=========================");
    buffer.writeln("Enviado desde la App Naviux");

    final String subject = "Pedido Farmacia App - $pharmacyName";
    
    // Si tenemos un adjunto, usamos share_plus para permitir al usuario
    // elegir su app de correo y que el archivo se adjunte automáticamente.
    if (attachmentPath != null) {
      await Share.shareXFiles(
        [XFile(attachmentPath)],
        subject: subject,
        text: buffer.toString(),
      );
      return;
    }

    // Fallback a mailto si no hay adjunto (aunque en este flujo siempre debería haberlo)
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'naviux@naviux.com',
      queryParameters: {
        'subject': subject,
        'body': buffer.toString(),
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'No se pudo abrir la aplicación de correo.';
    }
  }
}
