# Guía de Configuración de Redsys - Naviux App

Este documento detalla los pasos necesarios para pasar la aplicación de entorno de PRUEBAS a PRODUCCIÓN una vez recibas las credenciales definitivas del banco.

## 1. Archivo `.env`

Debes actualizar las siguientes variables en el archivo `.env` en la raíz del proyecto:

```env
# Código de Comercio (FUC) proporcionado por el banco
REDSYS_FUC=tu_codigo_fuc

# Terminal (normalmente es 1)
REDSYS_TERMINAL=1

# Clave Secreta de Encriptación (Clave de Comercio)
# ¡IMPORTANTE! Debe ser la clave de PRODUCCIÓN
REDSYS_SECRET_KEY=tu_clave_secreta

# URL del entorno
# Pruebas: https://sis-t.redsys.es:25443/sis/realizarPago
# Producción: https://sis.redsys.es/sis/realizarPago
REDSYS_URL_ENTORNO=https://sis.redsys.es/sis/realizarPago
```

## 2. Configuración en el Backend (WordPress)

La aplicación solicita el "Payload" (los parámetros firmados) al servidor para no exponer la clave secreta en el código fuente de la app. Asegúrate de que en tu plugin de WordPress o en el archivo `functions.php`:

1. El endpoint `wp-json/naviux/v1/redsys-payload` esté configurado con las **mismas credenciales** que el archivo `.env`.
2. La URL de notificación (Notificación Online) esté correctamente configurada para que WooCommerce marque el pedido como "Pagado" automáticamente.

## 3. Verificación de Seguridad

La aplicación utiliza el modo `HMAC_SHA256_V1` por defecto, que es el estándar actual de Redsys.

## 4. Pruebas Finales

Una vez introducidas las credenciales:
1. Compila la app de nuevo: `flutter run`.
2. Realiza un pedido real (puedes usar un producto de 1€).
3. Verifica que tras el pago, la pantalla de "Pedido Completado" aparezca correctamente tras los segundos de espera (Short Polling).
