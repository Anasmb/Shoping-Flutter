import 'dart:convert';

import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  );
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrdersFromServer() async {
    final url =
        "https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=" +
            authToken;
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
            orderId,
            orderData["amount"],
            (orderData["products"] as List<dynamic>)
                .map((e) => CartItem(
                      id: e["id"],
                      price: e["price"],
                      quantity: e["quantity"],
                      title: e["title"],
                    ))
                .toList(),
            DateTime.parse(
              orderData["dateTime"],
            )));
      });
      //to display the order in most recent order on orders_screen we  use reversed
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    try {
      final url =
          "https://flutter-project-c3fdd-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=" +
              authToken;
      final response = await http.post(url,
          body: jsonEncode({
            "amount": total,
            "dateTime": timeStamp.toIso8601String(),
            "products": cartProducts
                .map((e) => {
                      "id": e.id,
                      "title": e.title,
                      "quantity": e.quantity,
                      "price": e.price
                    })
                .toList(),
          }));
      _orders.insert(
          0,
          OrderItem(
            json.decode(response.body)["name"],
            total,
            cartProducts,
            timeStamp,
          ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
