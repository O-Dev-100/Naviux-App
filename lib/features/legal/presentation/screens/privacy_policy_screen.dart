import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Política de Privacidad',
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
            _buildSectionTitle('1. Responsable del tratamiento'),
            _buildSectionText(
              'NAVIUX WORLD SL es el responsable del tratamiento de los datos personales de las personas usuarias de la aplicación móvil. Los datos se tratarán conforme al Reglamento (UE) 2016/679 (GDPR) y la Ley Orgánica 3/2018 (LOPDGDD).',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Finalidades del tratamiento'),
            _buildSectionText(
              'Tratamos tus datos personales para las siguientes finalidades relacionadas con la app móvil:',
            ),
            _buildBulletPoint('Gestión de la relación con el usuario y prestación de los servicios ofrecidos en la aplicación.'),
            _buildBulletPoint('Envío de comunicaciones comerciales y promociones por notificaciones push, correo electrónico, mensajes dentro de la app o por otros medios electrónicos que el usuario autorice.'),
            _buildBulletPoint('Realización de estudios de mercado y análisis estadísticos anónimos para mejorar la app y sus funcionalidades.'),
            _buildBulletPoint('Atención de solicitudes, incidencias y consultas recibidas a través de los formularios o canales de soporte integrados en la aplicación.'),
            _buildBulletPoint('Envío de boletines o novedades si el usuario se suscribe desde la app.'),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Legitimación del tratamiento'),
            _buildSectionText('El tratamiento se basa en:'),
            _buildBulletPoint('Consentimiento del usuario para el envío de comunicaciones comerciales y boletines.'),
            _buildBulletPoint('Interés legítimo del responsable para realizar análisis estadísticos, mejorar la experiencia de la app y gestionar solicitudes o encargos realizados por el usuario.'),
            const SizedBox(height: 24),
            _buildSectionTitle('4. Datos que recogemos y carácter obligatorio o facultativo'),
            _buildSectionText(
              'Los datos marcados como obligatorios en los formularios de la app son necesarios para atender tu petición o prestar el servicio; si no se facilitan, no podremos garantizar la correcta prestación del servicio.\n\n'
              'Los datos no obligatorios son voluntarios y su aportación facilita funcionalidades adicionales o una atención más personalizada.\n\n'
              'El usuario garantiza la veracidad de los datos facilitados y se compromete a mantenerlos actualizados.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('5. Conservación de los datos'),
            _buildSectionText(
              'Conservaremos tus datos el tiempo necesario para cumplir la finalidad para la que se recabaron o mientras exista una obligación legal que exija su conservación. Cuando ya no sean necesarios se procederá a su supresión o anonimización con medidas de seguridad adecuadas.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('6. Comunicaciones de datos a terceros'),
            _buildSectionText(
              'No se cederán datos a terceros salvo cuando sea necesario para la ejecución de las finalidades descritas (por ejemplo, proveedores de servicios técnicos o de comunicaciones). En esos casos, los proveedores actuarán como encargados del tratamiento y estarán sujetos a contratos que garanticen la confidencialidad y la seguridad exigida por la normativa.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('7. Medidas de seguridad'),
            _buildSectionText(
              'Hemos implementado medidas técnicas y organizativas apropiadas para proteger los datos personales frente a accesos no autorizados, pérdida, alteración o divulgación. Estas medidas se revisan periódicamente conforme a la normativa vigente.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('8. Derechos del usuario'),
            _buildSectionText('Puedes ejercer los siguientes derechos respecto a tus datos personales:'),
            _buildBulletPoint('Retirar el consentimiento en cualquier momento.'),
            _buildBulletPoint('Acceso, rectificación, supresión, portabilidad y limitación u oposición al tratamiento.'),
            _buildBulletPoint('Presentar una reclamación ante la autoridad de control si consideras que el tratamiento no se ajusta a la normativa.'),
            const SizedBox(height: 16),
            _buildSectionText(
              'Para ejercer tus derechos o solicitar información adicional, contacta en:\n'
              'NAVIUX WORLD SL\n'
              'Calle Felipe Moya, 48 Local 2. 03202 Elche (Alicante)\n'
              'Correo electrónico: naviux@naviux.com',
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
}
