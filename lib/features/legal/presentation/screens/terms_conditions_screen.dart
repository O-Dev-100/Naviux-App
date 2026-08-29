import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Términos y Condiciones',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Introducción'),
            _buildSectionText(
              'Estas Condiciones Generales regulan la contratación de productos y/o servicios a través de la aplicación móvil de NAVIUX WORLD SL (marca comercial naviux). La aceptación de estas condiciones por parte del usuario implica que ha leído y acepta las obligaciones aquí dispuestas.\n\n'
              '“Este documento contractual regirá las Condiciones Generales de contratación de productos y/o servicios (en adelante, «Condiciones») a través del sitio web www.naviux.com, titular Naviux World S.L.a bajo la marca comercial nx naviux, en adelante, naviux.”.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Identidad de las partes'),
            _buildSectionText(
              'Proveedor / Responsable: NAVIUX WORLD SL — Calle Felipe Moya, 48 Local 2, 03202 Elche (Alicante), CIF B23869639 — correo: info@naviux.com.\n\n'
              'Usuario / Cliente: persona que utiliza la app, ya sea con cuenta registrada (usuario y contraseña) o en modo invitado; es responsable de la veracidad y custodia de sus credenciales.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Ámbito y objeto'),
            _buildSectionText(
              'Estas condiciones regulan la compra y contratación de productos y servicios ofrecidos desde la app. Cuando la app actúe como canal de venta, la aceptación del pedido por parte del usuario formaliza el contrato de compraventa.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('4. Requisitos de acceso y cuenta de usuario'),
            _buildBulletPoint('El usuario debe ser mayor de edad.'),
            _buildBulletPoint('Al registrarse, el usuario crea un nombre de usuario y contraseña y se compromete a custodiar dichos datos y a notificar su pérdida o acceso no autorizado desde la propia app o por correo a info@naviux.com.'),
            _buildBulletPoint('La app podrá ofrecer modo invitado para compras puntuales; el usuario invitado es igualmente responsable de la veracidad de los datos facilitados.'),
            const SizedBox(height: 24),
            _buildSectionTitle('5. Proceso de contratación y confirmación del pedido'),
            _buildBulletPoint('Selección de producto en la app.'),
            _buildBulletPoint('Revisión de datos de facturación y envío.'),
            _buildBulletPoint('Selección de método de pago.'),
            _buildBulletPoint('Confirmación del pedido.'),
            _buildSectionText(
              '\nTras procesar el pedido, la app enviará una confirmación al correo del cliente y registrará el pedido en los sistemas de naviux.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('6. Precios y formas de pago'),
            _buildBulletPoint('Los precios se expresan en euros e incluyen IVA cuando proceda; los gastos de envío se mostrarán antes de finalizar la compra.'),
            _buildBulletPoint('Métodos de pago disponibles en la app: tarjeta (crédito/débito), Bizum, Google Pay, Apple Pay, PayPal.'),
            _buildBulletPoint('La emisión de factura se realizará según los datos facilitados por el cliente; la factura podrá remitirse en formato papel junto con el envío o, cuando proceda, en formato electrónico.'),
            const SizedBox(height: 24),
            _buildSectionTitle('7. Envíos y entrega (productos físicos)'),
            _buildBulletPoint('Los envíos se gestionan con los transportistas indicados por naviux; la app mostrará plazos y condiciones aplicables según destino.'),
            _buildBulletPoint('naviux no será responsable de retrasos una vez el pedido haya sido entregado al transportista.'),
            _buildBulletPoint('El cliente debe verificar el estado del pedido a la recepción y anotar cualquier incidencia en el albarán del transportista.'),
            const SizedBox(height: 24),
            _buildSectionTitle('8. Derecho de desistimiento y devoluciones'),
            _buildSectionText(
              'El cliente dispone del plazo indicado en la app (el documento original establece 30 días naturales) para ejercer el derecho de desistimiento desde la recepción del producto.\n\n'
              'Para tramitar devoluciones, la app ofrecerá un formulario o indicará el correo de contacto (por ejemplo, pedidosweb@naviux.com) y las instrucciones de envío. Los gastos de envío de la devolución serán los que se indiquen en la política de devoluciones de la app.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('9. Garantías y responsabilidad'),
            _buildSectionText(
              'Las garantías se ajustan a la normativa vigente en materia de consumidores y usuarios. naviux responderá por defectos de conformidad salvo que el daño derive de un uso indebido.\n\n'
              'La responsabilidad de naviux se limitará a lo establecido por la ley aplicable y por estas condiciones.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('10. Suspensión y resolución'),
            _buildSectionText(
              'naviux podrá suspender o cancelar el acceso del usuario a la app o a servicios concretos si detecta incumplimientos de estas condiciones, fraude o uso indebido.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('11. Protección de datos y política de privacidad'),
            _buildSectionText(
              'El tratamiento de datos personales se regirá por la Política de Privacidad de naviux adaptada a la app (notificaciones push, identificadores de dispositivo, almacenamiento local). En la app habrá enlaces claros para consultar la política y ejercer derechos (acceso, rectificación, supresión, portabilidad, limitación u oposición).',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('12. Comunicaciones y notificaciones'),
            _buildSectionText(
              'Las comunicaciones contractuales se podrán realizar por correo electrónico, notificaciones dentro de la app o por otros medios electrónicos que el usuario haya autorizado.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('13. Legislación aplicable y jurisdicción'),
            _buildSectionText(
              'Estas condiciones se regirán por la legislación española. Para cualquier controversia, las partes se someten a los juzgados y tribunales de Elche (Alicante), salvo que la ley aplicable disponga otra cosa.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: Colors.black87,
        height: 1.6,
      ),
      textAlign: TextAlign.left,
    );
  }
}
