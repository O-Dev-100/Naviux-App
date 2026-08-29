import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromoCarousel extends StatelessWidget {
  const PromoCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, String>> slides = [
      {
        'title': 'Bienvenido a NAVIUX®',
        'subtitle': 'cuidamos de lo que más nos importa, tu salud visual.',
        'image': 'assets/images/inicio/bienvenido_naviux.webp',
        'buttonText': 'SABER MÁS',
        'route': '/about',
      },
      {
        'title': 'Gafas de Lectura',
        'subtitle': 'La mejor calidad para tu lectura',
        'image': 'assets/images/inicio/gafas_lectura.webp',
        'buttonText': 'VER MODELOS',
        'route': '/shop',
        'category': 'Lectura',
      },
      {
        'title': 'Gafas de Lectura Blue Light',
        'subtitle': 'Protección frente a pantallas',
        'image': 'assets/images/inicio/gafas_bluelight.webp',
        'buttonText': 'VER MODELOS',
        'route': '/shop',
        'category': 'Blue Light',
      },
      {
        'title': 'Gafas de Sol Polarizadas',
        'subtitle': 'Protección total con estilo',
        'image': 'assets/images/inicio/gafas_pol.webp',
        'buttonText': 'VER MODELOS',
        'route': '/shop',
        'category': 'Sol Polarizadas',
      },
      {
        'title': 'Edición Limitada',
        'subtitle': 'Diseños exclusivos Naviux',
        'image': 'assets/images/inicio/ed_limitada.webp',
        'buttonText': 'DESCUBRIR',
        'route': '/shop',
        'category': 'Edición Limitada',
      },
      {
        'title': 'Nuestra Tienda',
        'subtitle': 'Explora toda nuestra colección',
        'image': 'assets/images/inicio/visitar_tienda.webp',
        'buttonText': 'VISITAR TIENDA',
        'route': '/shop',
      },
    ];

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: slides.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final slide = slides[index];
          final isFirst = index == 0;
          final hasButton = slide['buttonText']!.isNotEmpty && !isFirst;

          return Container(
            width: isFirst || hasButton ? 300 : 250,
            margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    slide['image']!,
                    fit: BoxFit.cover,
                    cacheWidth: index == 0 ? 800 : 600, // Optimización de memoria
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.primary.withAlpha(20),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (slide['subtitle']!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            slide['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (hasButton) ...[
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (slide['category'] != null) {
                                context.push('/shop', extra: {'category': slide['category']});
                              } else {
                                context.go(slide['route']!);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              slide['buttonText']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
