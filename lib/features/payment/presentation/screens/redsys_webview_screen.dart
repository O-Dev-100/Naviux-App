import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RedsysWebViewScreen extends ConsumerStatefulWidget {
  final String merchantParameters;
  final String signature;
  final String signatureVersion;
  final String urlRedsys;

  const RedsysWebViewScreen({
    super.key,
    required this.merchantParameters,
    required this.signature,
    required this.signatureVersion,
    required this.urlRedsys,
  });

  @override
  ConsumerState<RedsysWebViewScreen> createState() => _RedsysWebViewScreenState();
}

class _RedsysWebViewScreenState extends ConsumerState<RedsysWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
          <title>Redirigiendo a Redsys...</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
              body { display: flex; justify-content: center; align-items: center; height: 100vh; font-family: sans-serif; background: #f8f9fa; }
              .loader { border: 4px solid #f3f3f3; border-radius: 50%; border-top: 4px solid #001B48; width: 40px; height: 40px; animation: spin 1s linear infinite; }
              @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
          </style>
      </head>
      <body>
          <div style="text-align:center;">
             <div class="loader" style="margin: 0 auto;"></div>
             <p style="margin-top:20px; font-weight: bold; color: #001B48;">Conectando con pasarela segura...</p>
          </div>
          <form name="frm" action="${widget.urlRedsys}" method="POST">
              <input type="hidden" name="Ds_SignatureVersion" value="${widget.signatureVersion}"/>
              <input type="hidden" name="Ds_MerchantParameters" value="${widget.merchantParameters}"/>
              <input type="hidden" name="Ds_Signature" value="${widget.signature}"/>
          </form>
          <script type="text/javascript">
            setTimeout(function() {
              document.frm.submit();
            }, 500);
          </script>
      </body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            
            // Detección mejorada basada en esquemas de la app o URLs de respuesta de WooCommerce
            if (url.contains('naviuxapp://payment/success') || 
                url.contains('order-received') || 
                url.contains('checkout/thank-you')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            
            if (url.contains('naviuxapp://payment/error') || 
                url.contains('pago-error') || 
                url.contains('cancel')) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }

            // SOPORTE PARA BIZUM Y APPS BANCARIAS:
            // Si la URL no es HTTP/S, es probablemente un esquema nativo (intent://, bizum://, etc.)
            if (!url.startsWith('http')) {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago Seguro - Redsys')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
