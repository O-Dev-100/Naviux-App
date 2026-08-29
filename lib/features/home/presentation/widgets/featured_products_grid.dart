import 'package:flutter/material.dart';
import '../../../../data/models/product_model.dart';
import '../../../shop/presentation/widgets/product_card.dart';

class FeaturedProductsGrid extends StatelessWidget {
  final List<ProductModel> products;

  const FeaturedProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length > 4 ? 4 : products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          heroPrefix: 'featured-',
        );
      },
    );
  }
}
