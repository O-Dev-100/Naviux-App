import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/cart_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../data/repositories/product_repository.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../favorites/application/favorites_provider.dart';
import '../../../../features/try_on/try_on_widgets.dart';
import '../../../../features/try_on/try_on_models.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  final int? productId;
  final String heroPrefix;

  const ProductDetailScreen({
    super.key,
    this.product,
    this.productId,
    this.heroPrefix = '',
  }) : assert(product != null || productId != null, 'Debe proporcionar un producto o un productId');

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> with SingleTickerProviderStateMixin {
  ProductModel? _currentProduct;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _selectedImageIndex = 0;
  final Map<String, String> _selectedAttributes = {};
  List<ProductVariation> _variations = [];
  List<ProductModel> _siblingProducts = [];
  bool _isLoadingVariations = false;
  bool _isLoadingInitialProduct = false;
  ProductVariation? _currentVariation;

  @override
  void initState() {
    // inicialización del estado y controladores de animación
    super.initState();
    if (widget.product != null) {
      _currentProduct = widget.product;
      _loadAllData();
    } else {
      _loadProductById();
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProductById() async {
    // carga los datos del producto usando su id
    if (widget.productId == null) return;
    
    setState(() => _isLoadingInitialProduct = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final product = await repo.getProductById(widget.productId!);
      if (mounted) {
        setState(() {
          _currentProduct = product;
          _isLoadingInitialProduct = false;
        });
        _loadAllData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitialProduct = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar producto: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadAllData({bool loadSiblings = true}) async {
    // carga variaciones y productos relacionados
    if (!mounted || _currentProduct == null) return;
    setState(() => _isLoadingVariations = true);

    await Future.wait([
      if (_currentProduct!.type == 'variable') _fetchVariations(),
      if (loadSiblings) _fetchSiblings(),
    ]);

    if (!mounted) return;
    setState(() => _isLoadingVariations = false);
  }

  Future<void> _fetchVariations() async {
    // obtiene las variaciones disponibles del producto
    if (_currentProduct == null) return;
    try {
      final repo = ref.read(productRepositoryProvider);
      final vars = await repo.getProductVariations(_currentProduct!.id);

      if (!mounted) return;
      setState(() {
        _variations = vars;
        if (_variations.isNotEmpty) {
          _preselectFirstVariation();
        }
      });
    } catch (e) {
      debugPrint('Error fetching variations: $e');
    }
  }

  Future<void> _fetchSiblings() async {
    // busca productos que son versiones del mismo modelo
    if (_currentProduct == null) return;
    try {
      final baseName = _getBaseName(_currentProduct!.name);
      final repo = ref.read(productRepositoryProvider);
      final siblings = await repo.getSiblingProducts(baseName);

      siblings.sort((a, b) {
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();
        final aHasC = aName.contains(' c');
        final bHasC = bName.contains(' c');
        if (!aHasC && bHasC) return -1;
        if (aHasC && !bHasC) return 1;
        return aName.compareTo(bName);
      });

      if (!mounted) return;
      setState(() => _siblingProducts = siblings);
    } catch (e) {
      debugPrint('Error fetching siblings: $e');
    }
  }

  String _getBaseName(String name) {
    return name.split(RegExp(r'[\s\-]+c\s?\d+', caseSensitive: false)).first.trim();
  }

  void _switchToSibling(ProductModel sibling) {
    // cambia la vista a un producto relacionado
    if (sibling.id == _currentProduct?.id) return;

    final List<ProductModel> savedSiblings = List.from(_siblingProducts);

    setState(() {
      _currentProduct = sibling;
      _variations = [];
      _currentVariation = null;
      _selectedAttributes.clear();
      _selectedImageIndex = 0;
      _siblingProducts = savedSiblings;
    });

    _loadAllData(loadSiblings: false);
  }

  bool _isStatusAvailable(String? status) {
    if (status == null) return false;
    final s = status.toLowerCase().trim();
    return s == 'instock' || s == 'onbackorder' || s == 'variable' || s == '';
  }

  bool _isVariationInStock(ProductVariation v) {
    // verifica la disponibilidad de una variación específica
    if (!_isStatusAvailable(v.stockStatus)) return false;

    final manage = v.manageStock;
    final isManaging = manage == true || manage == 'yes' || manage == '1' || manage == 1;

    if (isManaging) {
      if (v.stockQuantity != null && v.stockQuantity! <= 0) {
        if (v.stockStatus != 'onbackorder') return false;
      }
    }
    return true;
  }

  String _normalize(String text) {
    var str = text.toLowerCase();
    str = str.replaceAll(RegExp(r'[áàäâ]'), 'a');
    str = str.replaceAll(RegExp(r'[éèëê]'), 'e');
    str = str.replaceAll(RegExp(r'[íìïî]'), 'i');
    str = str.replaceAll(RegExp(r'[óòöô]'), 'o');
    str = str.replaceAll(RegExp(r'[úùüû]'), 'u');
    str = str.replaceAll(RegExp(r'[ñ]'), 'n');
    return str.trim();
  }

  bool _compareValues(String uiValue, String wcValue) {
    // compara valores de atributos normalizando el texto
    final s1 = _normalize(uiValue);
    final s2 = _normalize(wcValue);
    if (s1 == s2) return true;

    final isPlano1 = s1 == 'plano' || s1 == '0.00' || s1 == '0,00' || s1 == '0' || s1 == '0.0';
    final isPlano2 = s2 == 'plano' || s2 == '0.00' || s2 == '0,00' || s2 == '0' || s2 == '0.0';
    if (isPlano1 && isPlano2) return true;

    double? d1 = _toDouble(s1);
    double? d2 = _toDouble(s2);
    if (d1 != null && d2 != null && (d1 - d2).abs() < 0.001) return true;

    final clean1 = s1.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final clean2 = s2.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (clean1.isNotEmpty && clean1 == clean2) return true;

    return s1.replaceAll(' ', '-') == s2 ||
        s2.replaceAll(' ', '-') == s1 ||
        s1.replaceAll('-', '') == s2.replaceAll('-', '') ||
        s1.replaceAll(' ', '') == s2.replaceAll(' ', '') ||
        s1.replaceAll(' ', '-') == s2.replaceAll('_', '-');
  }

  double? _toDouble(String s) {
    String normalized = s.replaceAll(',', '.');
    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    }
    
    bool isNegative = normalized.startsWith('-');
    String absolute = isNegative ? normalized.substring(1) : normalized;
    
    if (absolute.contains('-')) {
      absolute = absolute.replaceFirst('-', '.');
    }
    
    normalized = (isNegative ? '-' : '') + absolute;
    normalized = normalized.replaceAll(RegExp(r'[^0-9.\-]'), '');
    
    return double.tryParse(normalized);
  }

  String? _findInVMap(Map<String, String> vMap, String key) {
    final normalizedKey = _normalize(key).replaceAll('pa_', '').replaceAll(' ', '-').replaceAll('_', '-');

    for (var entry in vMap.entries) {
      String rawKey = entry.key;

      try {
        rawKey = Uri.decodeComponent(rawKey);
      } catch (_) {}

      final vKey = _normalize(rawKey)
          .replaceAll('pa_', '')
          .replaceAll('attribute_', '')
          .replaceAll(' ', '-')
          .replaceAll('_', '-');

      if (vKey == normalizedKey) return entry.value;
    }
    return null;
  }

  void _preselectFirstVariation() {
    // selecciona automáticamente la primera variación disponible
    if (_variations.isEmpty) return;
    ProductVariation? target;
    try {
      target = _variations.firstWhere((v) => _isVariationInStock(v));
    } catch (_) {
      target = _variations.first;
    }

    _selectedAttributes.clear();
    final vMap = target.attributeMap;
    if (_currentProduct == null) return;
    
    for (var attr in _currentProduct!.attributes) {
      final vVal = _findInVMap(vMap, attr.name);
      if (vVal != null && vVal.isNotEmpty) {
        for (var opt in attr.options) {
          if (_compareValues(opt, vVal)) {
            _selectedAttributes[attr.name] = opt;
            break;
          }
        }
      }
    }
    _currentVariation = target;
  }

  void _onAttributeSelected(String name, String value) {
    // gestiona la selección de atributos por el usuario
    setState(() {
      _selectedAttributes[name] = value;
      _updateCurrentVariation();
      
      if (_currentVariation == null) {
        _fixInvalidSelection(name, value);
      }
    });
  }

  void _fixInvalidSelection(String changedAttrName, String newValue) {
    // intenta encontrar una combinación válida si la selección actual no existe
    try {
      final firstValidVar = _variations.firstWhere((v) {
        final vVal = _findInVMap(v.attributeMap, changedAttrName);
        return vVal == null || vVal.isEmpty || _compareValues(newValue, vVal);
      });

      final vMap = firstValidVar.attributeMap;
      for (var attr in _currentProduct!.attributes) {
        if (attr.name == changedAttrName) continue;
        final vVal = _findInVMap(vMap, attr.name);
        if (vVal != null && vVal.isNotEmpty) {
          for (var opt in attr.options) {
            if (_compareValues(opt, vVal)) {
              _selectedAttributes[attr.name] = opt;
              break;
            }
          }
        }
      }
      _currentVariation = firstValidVar;
    } catch (_) {
      _currentVariation = null;
    }
  }

  void _updateCurrentVariation() {
    // actualiza la variación activa basada en los atributos seleccionados
    if (_variations.isEmpty) return;
    ProductVariation? matchedVar;
    try {
      matchedVar = _variations.firstWhere((v) {
        final vMap = v.attributeMap;
        return _selectedAttributes.entries.every((entry) {
          final vVal = _findInVMap(vMap, entry.key);
          if (vVal == null || vVal.isEmpty) return true;
          return _compareValues(entry.value, vVal);
        });
      });
    } catch (_) {
      matchedVar = null;
    }
    setState(() => _currentVariation = matchedVar);
  }


  @override
  Widget build(BuildContext context) {
    // construcción de la interfaz principal de detalle de producto
    if (_isLoadingInitialProduct || _currentProduct == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final product = _currentProduct!;
    final theme = Theme.of(context);
    final List<String> currentImages = (_currentVariation?.images.isNotEmpty == true)
        ? _currentVariation!.images.map((i) => i.src).toList()
        : product.images.map((i) => i.src).toList();

    final displayPrice = _currentVariation?.price ?? product.price;
    final isFavorite = ref.watch(favoritesProvider).any((p) => p.id == product.id);

    final bool parentInStock = _isStatusAvailable(product.stockStatus);
    bool isInStock = parentInStock;

    if (product.type == 'variable') {
      if (_currentVariation != null) {
        isInStock = _isVariationInStock(_currentVariation!);
      } else {
        isInStock = parentInStock;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildCircleButton(icon: Icons.arrow_back_ios_new, onPressed: () => Navigator.pop(context)),
        actions: [
          _buildCircleButton(
            icon: Icons.share_outlined,
            onPressed: () => _shareProduct(),
          ),
          _buildCircleButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : AppColors.primary,
            onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
          ).animate(target: isFavorite ? 1 : 0)
              .scale(duration: 400.ms, curve: Curves.elasticOut, begin: const Offset(0.8, 0.8))
              .tint(color: Colors.red, duration: 200.ms)
              .shake(hz: 3, offset: const Offset(2, 2), duration: 500.ms),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGallery(currentImages, key: ValueKey(_currentVariation?.id ?? product.id)),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(product).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text('$displayPrice €', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))
                      .animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                  _buildTryOnRecommendation().animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),

                  if (_isLoadingVariations) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                  if (!isInStock && !_isLoadingVariations) _buildOutOfStockWarning().animate().shake(hz: 4, curve: Curves.easeInOut),

                  if (_siblingProducts.isNotEmpty) _buildColorSelector(product).animate().fadeIn(delay: 400.ms),

                  ...product.attributes
                      .where((a) => a.variation && !a.name.toLowerCase().contains('color'))
                      .map((attr) => _buildAttributeSelector(product, attr).animate().fadeIn(delay: 500.ms)),

                  const SizedBox(height: 32),
                  const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  HtmlWidget(
                    product.shortDescription.isNotEmpty ? product.shortDescription : product.description,
                    textStyle: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildTryOnFAB(product),
      bottomNavigationBar: _buildBottomAction(product, displayPrice, isInStock),
    );
  }

  Widget _buildTitleRow(ProductModel product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        if (product.name.toLowerCase().contains(' c'))
          TextButton.icon(
            onPressed: () {
              final base = _siblingProducts.firstWhere((p) => !p.name.toLowerCase().contains(' c'), orElse: () => _siblingProducts.first);
              _switchToSibling(base);
            },
            icon: const Icon(Icons.home_filled, size: 16),
            label: const Text('BASE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            style: TextButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1), foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          ),
      ],
    );
  }

  Widget _buildAttributeSelector(ProductModel product, ProductAttribute attr) {
    // selector para atributos como graduación, diámetro, etc.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Selecciona ${attr.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: attr.options.map((opt) {
            final isSel = _selectedAttributes[attr.name] == opt;
            
            bool exists = false;
            bool inStock = false;
            
            if (_variations.isEmpty) {
              exists = true;
              inStock = _isStatusAvailable(product.stockStatus);
            } else {
              exists = _variations.any((v) {
                final vVal = _findInVMap(v.attributeMap, attr.name);
                return vVal == null || vVal.isEmpty || _compareValues(opt, vVal);
              });
              
              if (exists) {
                final testAttributes = Map<String, String>.from(_selectedAttributes);
                testAttributes[attr.name] = opt;
                inStock = _variations.any((v) {
                  final vMap = v.attributeMap;
                  bool matches = true;
                  for (var entry in testAttributes.entries) {
                    final val = _findInVMap(vMap, entry.key);
                    if (val != null && val.isNotEmpty && !_compareValues(entry.value, val)) {
                      matches = false; break;
                    }
                  }
                  return matches && _isVariationInStock(v);
                });
                
                if (!inStock) {
                   inStock = _variations.any((v) {
                     final vVal = _findInVMap(v.attributeMap, attr.name);
                     final matchesAttr = vVal == null || vVal.isEmpty || _compareValues(opt, vVal);
                     return matchesAttr && _isVariationInStock(v);
                   });
                }
              }
            }

            return _buildOptionChip(attr.name, opt, isSel, exists, inStock);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionChip(String attrName, String option, bool isSel, bool exists, bool inStock) {
    // elemento individual de selección de atributo
    final bool isSelectable = exists; 
    
    return Stack(
      alignment: Alignment.center,
      children: [
        ChoiceChip(
          label: Text(option),
          selected: isSel,
          onSelected: isSelectable ? (_) => _onAttributeSelected(attrName, option) : null,
          selectedColor: AppColors.primary.withValues(alpha: 0.1),
          disabledColor: Colors.grey.shade100,
          labelStyle: TextStyle(
            color: isSelectable 
                ? (inStock ? (isSel ? AppColors.primary : Colors.black87) : Colors.grey.shade500)
                : Colors.grey.shade300,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            decoration: exists ? null : TextDecoration.lineThrough,
          ),
        ),
        if (!exists)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: DiagonalCrossPainter(),
              ),
            ),
          ),
        if (exists && !inStock)
           Positioned(
             right: 0, top: 0,
             child: Container(
               padding: const EdgeInsets.all(2),
               decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
               child: const Icon(Icons.info_outline, size: 8, color: Colors.white),
             ),
           ),
      ],
    );
  }

  Widget _buildColorSelector(ProductModel product) {
    // selector de otros colores o versiones del mismo modelo
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Otras Versiones / Colores', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _siblingProducts.length,
            separatorBuilder: (_, ___) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final sibling = _siblingProducts[index];
              final isSel = sibling.id == product.id;
              final bool inStock = sibling.stockStatus == 'instock';
              final image = sibling.images.isNotEmpty ? sibling.images.first.src : '';

              return GestureDetector(
                onTap: () => _switchToSibling(sibling),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 65, height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSel ? AppColors.primary : Colors.grey.shade300, width: isSel ? 3 : 1),
                          ),
                          child: ClipOval(
                            child: ColorFiltered(
                              colorFilter: inStock ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                              child: CachedNetworkImage(imageUrl: image, fit: BoxFit.cover, errorWidget: (_,__,___) => const Icon(Icons.image)),
                            ),
                          ),
                        ),
                        if (!inStock)
                          Icon(
                            Icons.close,
                            color: Colors.red.withValues(alpha: 0.9),
                            size: 48,
                            shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_getColorName(sibling.name), style: TextStyle(fontSize: 10, color: inStock ? Colors.black87 : Colors.grey, decoration: inStock ? null : TextDecoration.lineThrough)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getColorName(String name) {
    final matches = RegExp(r'c\s?(\d+)', caseSensitive: false).allMatches(name);
    if (matches.isNotEmpty) {
      return 'C${matches.last.group(1)}'.toUpperCase();
    }
    if (name.toLowerCase().contains(' c ') || name.toLowerCase().endsWith(' c')) {
      return 'C';
    }
    return 'BASE';
  }

  Widget _buildGallery(List<String> images, {required Key key}) {
    // galería de imágenes del producto
    return Container(
      key: key, height: 400, color: Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _selectedImageIndex = i),
            itemBuilder: (context, i) => CachedNetworkImage(imageUrl: images[i], fit: BoxFit.contain, placeholder: (_,__) => const Center(child: CircularProgressIndicator())),
          ),
          if (images.length > 1) Positioned(bottom: 20, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(images.length, (i) => _buildDot(i)))),
        ],
      ),
    );
  }

  Widget _buildDot(int i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: _selectedImageIndex == i ? 18 : 6, height: 6, decoration: BoxDecoration(color: _selectedImageIndex == i ? AppColors.primary : Colors.grey.shade300, borderRadius: BorderRadius.circular(3)));

  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed, Color? color}) => Padding(padding: const EdgeInsets.all(8), child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9), child: IconButton(icon: Icon(icon, size: 18, color: color ?? Colors.black87), onPressed: onPressed)));

  Widget _buildOutOfStockWarning() => Container(margin: const EdgeInsets.symmetric(vertical: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade100)), child: const Row(children: [Icon(Icons.info_outline, color: Colors.red, size: 20), SizedBox(width: 10), Text("Agotado temporalmente", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]));

  Widget _buildTryOnRecommendation() => Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                  "Ideal para rostros Ovalados y Cuadrados",
                  style: TextStyle(fontSize: 13, color: AppColors.primary)
              ),
            )
          ]
      )
  );

  Widget _buildTryOnFAB(ProductModel product) => FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VirtualTryOnView(glassesAsset: product.images.isNotEmpty ? product.images.first.src : '', initialFaceType: FaceType.oval))), backgroundColor: AppColors.primary, icon: const Icon(Icons.face_retouching_natural, color: Colors.white), label: const Text("PROBADOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));

  Widget _buildBottomAction(ProductModel product, String price, bool inStock) => Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: SafeArea(
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: ElevatedButton(
            onPressed: inStock ? () => _addToCart(product) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: inStock ? AppColors.secondary : Colors.grey,
              minimumSize: const Size(double.infinity, 58),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              inStock ? 'AÑADIR AL CARRITO' : 'AGOTADO',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );

  void _addToCart(ProductModel product) {
    // añade el producto al carrito con feedback táctil
    HapticFeedback.mediumImpact();
    
    ref.read(cartNotifierProvider.notifier).addCartItem(CartItem(
        product: product,
        quantity: 1,
        selectedAttributes: _selectedAttributes,
        variationId: _currentVariation?.id,
        price: _currentVariation?.price ?? product.price));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('¡Añadido al carrito!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VER CARRITO',
          textColor: Colors.white,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _shareProduct() {
    // comparte el enlace del producto
    if (_currentProduct == null) return;
    final String url = 'https://naviux.es/producto/${_currentProduct!.id}';
    Share.share(
      '¡Mira estas gafas en Naviux!: ${_currentProduct!.name}\n$url',
      subject: 'Descubre las ${_currentProduct!.name} en Naviux',
    );
  }
}

class DiagonalCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
