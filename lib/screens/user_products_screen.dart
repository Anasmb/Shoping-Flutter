import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/user_edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/user_product_item.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchProductsFromServer(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot == ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<ProductsProvider>(
                  builder: (context, productsData, _) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          UserProductItem(
                            productsData.items[index].id,
                            productsData.items[index].title,
                            productsData.items[index].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
