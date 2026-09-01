# Nx Naviux® - App Oficial

Solución móvil multiplataforma desarrollada en Flutter para **Naviux Eyewear**, diseñada para digitalizar la experiencia de compra de óptica y fortalecer el canal B2B con profesionales farmacéuticos.

## 🚀 Características Principales

### 🛒 eCommerce & Retail
*   **Catálogo Dinámico**: Sincronización en tiempo real con el inventario de WooCommerce.
*   **Gestión de Atributos**: Soporte completo para variaciones de producto (color, graduación, diámetro).
*   **Checkout Seguro**: Proceso de pago optimizado con integración de **Redsys** (Tarjeta de crédito y Bizum).
*   **Facturación Automática**: Generación y descarga de facturas en formato PDF tras cada pedido.

### 🕶️ Probador Virtual (Virtual Try-On)
*   Experiencia inmersiva que permite visualizar modelos de gafas sobre diferentes tipos de rostro.
*   **Procesamiento de Imagen**: Integración con APIs de IA para la eliminación de fondos en tiempo real, ofreciendo un ajuste preciso y realista.

### 🏥 Portal Farmacéutico (B2B)
*   **Acceso Profesional**: Sistema de verificación y login exclusivo para farmacias colaboradoras.
*   **Catálogo Interactivo**: Visualización y gestión de pedidos directamente a través de un catálogo PDF interactivo con envío automatizado por email.

### 🔔 Notificaciones & Soporte
*   **Push Notifications**: Canal de comunicación directo mediante Firebase Cloud Messaging.
*   **Multi-idioma**: Soporte nativo para Español e Inglés mediante Localizaciones de Flutter.

## 🛠️ Stack Tecnológico

*   **Framework**: Flutter (Dart)
*   **Gestión de Estado**: Flutter Riverpod con generadores de código.
*   **Navegación**: GoRouter con rutas protegidas y navegación persistente (ShellRoute).
*   **Persistencia Local**: Hive (NoSQL) para carrito, favoritos y preferencias.
*   **Networking**: Dio con interceptores para gestión de tokens JWT y autenticación Basic Auth.
*   **Backend**: WordPress + WooCommerce API REST.

## 📦 Estructura del Proyecto

La arquitectura sigue una organización por **características (features)** para facilitar la escalabilidad:

```text
lib/
├── core/           # Configuración global, temas, rutas y servicios compartidos.
├── data/           # Modelos de datos comunes y adaptadores.
├── features/       # Módulos independientes (auth, shop, pharmacy, try_on, etc.).
│   ├── application/   # Lógica de negocio (providers).
│   ├── data/          # Repositorios y fuentes de datos.
│   └── presentation/  # Interfaz de usuario (pantallas y widgets).
├── shared/         # Componentes UI reutilizables.
└── l10n/           # Archivos de traducción.
```

## ⚙️ Configuración y Seguridad

Para ejecutar el proyecto localmente, es imprescindible crear un archivo `.env` en la raíz con las siguientes claves:

```env
BASE_URL=tu_url_wordpress
WC_CONSUMER_KEY=tu_key_woocommerce
WC_CONSUMER_SECRET=tu_secret_woocommerce
FIREBASE_WEB_API_KEY=tu_api_key
FIREBASE_ANDROID_API_KEY=tu_api_key
FIREBASE_IOS_API_KEY=tu_api_key
REMOVE_BG_API_KEY=tu_key_remove_bg
```

> **Nota de Seguridad**: Los archivos sensibles como `.env`, `firebase_options.dart` y almacenes de claves están excluidos del repositorio para proteger la propiedad intelectual de la empresa.

## ⚖️ Licencia y Propiedad

© 2026 **Nx Naviux®**. Todos los derechos reservados. El código fuente y los activos visuales de este proyecto son propiedad privada de Naviux World S.L. y su uso no autorizado está estrictamente prohibido.
