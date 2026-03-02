import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product.dart';

part 'mock_repository.g.dart';

@riverpod
class MockRepository extends _$MockRepository {
  @override
  List<Product> build() {
    return [
      Product(
        id: '1',
        name: 'Gafas de Sol Aviator',
        description: 'Clásico diseño de aviador con protección UV400.',
        price: 120.0,
        imageUrl: 'assets/images/logo-naviux.jpg', // Placeholder
        category: 'sol',
      ),
      Product(
        id: '2',
        name: 'Gafas Graduadas Minimal',
        description: 'Montura ligera y resistente para el día a día.',
        price: 95.0,
        imageUrl: 'assets/images/logo-naviux.jpg',
        category: 'graduadas',
      ),
      Product(
        id: '3',
        name: 'Gafas de Sol Sport',
        description: 'Perfectas para actividades al aire libre.',
        price: 85.0,
        imageUrl: 'assets/images/logo-naviux.jpg',
        category: 'sol',
      ),
       Product(
        id: '4',
        name: 'Gafas Graduadas Retro',
        description: 'Estilo vintage con materiales modernos.',
        price: 110.0,
        imageUrl: 'assets/images/logo-naviux.jpg',
        category: 'graduadas',
      ),
    ];
  }

  List<Product> getProductsByCategory(String category) {
    return state.where((p) => p.category == category).toList();
  }
}
