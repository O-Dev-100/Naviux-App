import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/providers/products_provider.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../widgets/product_card.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:naviux_app/l10n/app_localizations.dart';
import '../../../../data/models/product_model.dart';

import 'package:naviux_app/features/auth/application/auth_provider.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _searchQuery = '';
  Timer? _debounce;
  String? _selectedCollection = 'Todos';
  String? _selectedGender;
  String? _sortByPrice = 'asc'; 
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    // inicialización del scroll y parámetros de navegación
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GoRouterState.of(context).extra is Map<String, dynamic>) {
        final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
        if (extra.containsKey('category')) {
          setState(() {
            _selectedCollection = extra['category'];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // gestiona la búsqueda con un pequeño retardo
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = query);
    });
  }

  void _onScroll() {
    // controla la carga infinita de productos al hacer scroll
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final slug = _getCategorySlug(_selectedCollection);
    final notifier = ref.read(productsProvider(slug).notifier);

    if (position.pixels >= position.maxScrollExtent - 300 &&
        !ref.read(productsProvider(slug)).isLoading &&
        !notifier.hasReachedEnd) {
      _currentPage++;
      notifier.loadMore(_currentPage);
    }
  }

  String? _getCategorySlug(String? collection) {
    // mapea nombres de colecciones a sus identificadores de api
    if (collection == null || collection == 'Todos') return null;
    switch (collection) {
      case 'Lectura': return 'lectura';
      case 'Sol Polarizadas': 
      case 'Sol': return 'sol';
      case 'Blue Light': return 'blue-light';
      case 'Edición Limitada': 
      case 'Ed. Limitada': return 'edicion-limitada';
      default: return collection.toLowerCase().replaceAll(' ', '-');
    }
  }

  void _showFilterSheet() {
    // muestra el menú inferior de filtros avanzados
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros Avanzados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Género', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ['Todos', 'Hombre', 'Mujer', 'Unisex'].map((g) {
                  final bool isSel = (_selectedGender ?? 'Todos') == g;
                  return ChoiceChip(
                    label: Text(g),
                    selected: isSel,
                    onSelected: (_) {
                      setSheetState(() => _selectedGender = g == 'Todos' ? null : g);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Ordenar por Precio', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  {'label': 'Menor a Mayor', 'value': 'asc'},
                  {'label': 'Mayor a Menor', 'value': 'desc'},
                ].map((s) {
                  final bool isSel = _sortByPrice == s['value'];
                  return ChoiceChip(
                    label: Text(s['label']!),
                    selected: isSel,
                    onSelected: (_) {
                      setSheetState(() => _sortByPrice = s['value']);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Aplicar Filtros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // construye la interfaz principal de la tienda con filtros y catálogo
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra.containsKey('category')) {
      final categoryExtra = extra['category'] as String;
      if (categoryExtra != _selectedCollection) {
        Future.microtask(() {
          if (mounted) setState(() => _selectedCollection = categoryExtra);
        });
      }
    }

    final String? currentCategorySlug = _getCategorySlug(_selectedCollection);
    final productsAsync = ref.watch(productsProvider(currentCategorySlug));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: CustomAppBar(title: l10n.shopTitle, showBackButton: false),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          _buildCategoryTabs(),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = _applyLocalFilters(products);
                return filtered.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No hay productos con estos filtros', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedGender = null;
                              });
                              ref.read(productsProvider(currentCategorySlug).notifier).refresh();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Limpiar Filtros y Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(),
                    )
                  : RefreshIndicator(
                      onRefresh: () async { _currentPage = 1; await ref.read(productsProvider(currentCategorySlug).notifier).refresh(); },
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 16, mainAxisSpacing: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => ProductCard(product: filtered[index]),
                      ),
                    );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 24),
                      const Text(
                        'Lo sentimos mucho, ha ocurrido un problema al conectar con nuestra tienda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Estamos trabajando para solucionarlo. Por favor, intenta refrescar la lista.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(productsProvider(currentCategorySlug).notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('REFRESCAR PRODUCTOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ProductModel> _applyLocalFilters(List<ProductModel> products) {
    // filtra y ordena localmente la lista de productos
    var filtered = List<ProductModel>.from(products);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedGender != null) {
      final genderSearch = _selectedGender!.toLowerCase();
      filtered = filtered.where((p) {
        final hasGenderAttr = p.attributes.any((attr) {
          final aName = attr.name.toLowerCase();
          if (aName.contains('gén') || aName.contains('gender') || aName.contains('sexo')) {
            return attr.options.any((o) {
              final opt = o.toLowerCase();
              return opt == genderSearch || opt == 'unisex';
            });
          }
          return false;
        });
        if (hasGenderAttr) return true;

        final hasGenderCat = p.categories.any((c) {
          final cName = c.name.toLowerCase();
          return cName.contains(genderSearch) || cName == 'unisex';
        });
        if (hasGenderCat) return true;

        return p.name.toLowerCase().contains(genderSearch);
      }).toList();
    }

    filtered.sort((a, b) {
      final double priceA = double.tryParse(a.price) ?? 0.0;
      final double priceB = double.tryParse(b.price) ?? 0.0;
      if (_sortByPrice == 'desc') {
        return priceB.compareTo(priceA);
      }
      return priceA.compareTo(priceB);
    });

    return filtered;
  }

  Widget _buildSearchAndFilterBar() {
    // barra superior de búsqueda y botón de filtros
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar gafas...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true, fillColor: Colors.grey.shade100,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune_rounded),
            style: IconButton.styleFrom(
              backgroundColor: _selectedGender != null ? AppColors.secondary : Colors.grey.shade200,
              foregroundColor: _selectedGender != null ? Colors.white : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    // selector horizontal de categorías de productos
    final List<String> categories = ['Todos', 'Lectura', 'Sol Polarizadas', 'Blue Light', 'Edición Limitada'];
    final int currentIndex = categories.indexOf(_selectedCollection ?? 'Todos');

    return DefaultTabController(
      length: categories.length,
      initialIndex: currentIndex != -1 ? currentIndex : 0,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          if (controller.index != currentIndex && currentIndex != -1) {
            controller.index = currentIndex;
          }
          
          return TabBar(
            onTap: (index) => setState(() {
              _currentPage = 1;
              _selectedCollection = categories[index];
            }),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.secondary,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [Tab(text: 'Todos'), Tab(text: 'Lectura'), Tab(text: 'Sol Polarizadas'), Tab(text: 'Blue Light'), Tab(text: 'Ed. Limitada')],
          );
        }
      ),
    );
  }
}
