import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "product-detail";

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as String; // the id
    final loadedProduct = Provider.of<ProductsProvider>(context)
        .items
        .firstWhere((prod) => productId == prod.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
