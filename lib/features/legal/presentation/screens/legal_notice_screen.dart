import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';

class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aviso Legal',
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
            _buildSectionTitle('LEY DE LOS SERVICIOS DE LA SOCIEDAD DE LA INFORMACIÓN (LSSI) Identificación del responsable'),
            _buildSectionText(
              'NAVIUX WORLD SL (marca comercial Naviux) es la empresa responsable de la aplicación móvil. Datos de contacto: Calle Felipe Moya, 48 Local 2, 03202 Elche (Alicante), CIF B23869639, teléfono 658 60 71 69, correo naviux@naviux.com.\n\n'
              '“n·x naviux, responsable del sitio web, en adelante RESPONSABLE, pone a disposición de los usuarios el presente documento, con el que pretende dar cumplimiento a las obligaciones dispuestas en la Ley 34/2002, de 11 de julio, de Servicios de la Sociedad de la Información y de Comercio Electrónico (LSSICE).”',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Ámbito y aceptación de las condiciones'),
            _buildSectionText(
              'El presente Aviso Legal regula el uso de la aplicación móvil y los servicios ofrecidos a través de la misma. El acceso o uso de la app implica la aceptación de estas condiciones y de la normativa aplicable.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Propiedad intelectual e industrial'),
            _buildSectionText(
              'Los contenidos, diseños, logotipos, textos, imágenes y demás elementos de la app son propiedad de NAVIUX WORLD SL o cuentan con licencia. Queda prohibida su reproducción, distribución o explotación sin autorización previa y por escrito del responsable.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Condiciones de uso y responsabilidad'),
            _buildBulletPoint('El usuario se compromete a utilizar la app conforme a la ley y a no emplearla para fines ilícitos.'),
            _buildBulletPoint('NAVIUX WORLD SL no garantiza la disponibilidad ininterrumpida de la app; podrá suspender temporalmente el servicio por mantenimiento, actualizaciones o causas de fuerza mayor.'),
            _buildBulletPoint('NAVIUX WORLD SL no será responsable de los daños derivados de un uso indebido de la app o de la información facilitada por terceros.'),
            const SizedBox(height: 24),
            _buildSectionTitle('Tecnologías en la app (equivalente a cookies)'),
            _buildSectionText(
              'La app puede utilizar identificadores de dispositivo, almacenamiento local y SDKs para funciones técnicas, analíticas y de personalización. Estas tecnologías se emplean únicamente para las finalidades descritas en la Política de Privacidad de la app y, cuando proceda, se solicitará el consentimiento del usuario desde la propia aplicación.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Enlaces a terceros'),
            _buildSectionText(
              'La app puede contener enlaces a servicios o contenidos de terceros. NAVIUX WORLD SL no controla dichos contenidos y no asume responsabilidad por ellos; procederá a retirar enlaces que vulneren la ley o derechos de terceros cuando tenga conocimiento efectivo.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Exclusión de tratamiento de direcciones IP y registro de servidores'),
            _buildSectionText(
              'Se suprime la descripción detallada sobre la detección y registro de direcciones IP propia de la versión web. En la app, cualquier registro técnico de eventos o diagnósticos se realizará con fines operativos y de seguridad, y se tratará conforme a la Política de Privacidad.\n\n'
              '“Nombre de dominio: www.naviux.com”',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Legislación aplicable y jurisdicción'),
            _buildSectionText(
              'Estas condiciones se regirán por la legislación española. Para la resolución de controversias, las partes se someten a los juzgados y tribunales de Elche (Alicante), salvo disposición legal en contrario.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Contacto para incidencias y reclamaciones'),
            _buildSectionText(
              'Para consultas, avisos de vulneración de derechos o reclamaciones: naviux@naviux.com o pedidosweb@naviux.com según proceda. También podrá consultarse la sección legal dentro de la app para formular reclamaciones o solicitar información.',
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
