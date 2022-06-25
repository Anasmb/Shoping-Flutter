import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "product-detail";

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as String; // the id
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findById(
            productId); // listen argument the default is true, if it false it means that this widget will not rebuild if ProductsProviders changed.
    // we set it to false if we only need the data one time

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
