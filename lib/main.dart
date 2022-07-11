import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:flutter_complete_guide/screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/user_edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products_provider.dart';
import './screens/orders_screen.dart';
import 'package:flutter_complete_guide/providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // only the widgets the are listing will be rebuild not all material app!!
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        //proxy provider is a provide that depend on another provider
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          update: (ctx, auth, previuosProductProvider) => ProductsProvider(
              auth.token,
              auth.userId,
              previuosProductProvider == null
                  ? []
                  : previuosProductProvider.items),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previuosOrder) => Orders(auth.token, auth.userId,
              previuosOrder == null ? [] : previuosOrder.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato",
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
