import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

//alternative way of didChangedependencies , we use FutureBuilder which we we dont need to use statful class
  //@override
  //void didChangeDependencies() {
  // if (_isInit) {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   Provider.of<Orders>(context, listen: false)
  //       .fetchOrdersFromServer()
  //       .then((_) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }
  // _isInit = false;
  //  super.didChangeDependencies();
  //}

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context); //to avoid infinite loop we use consumer
    print("building orders");
    return Scaffold(
      appBar: AppBar(title: Text("Your Orders")),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Orders>(context, listen: false).fetchOrdersFromServer(),
        builder: (context, dataSnapshot) {
          //means we are currently loading
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              //error handling
              return Center(
                child: Text("error occured"),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) =>
                      OrderItem(orderData.orders[index]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
