import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/adapters/order_details_adapter.dart';
import 'package:grocery_app_admin/models/order_detail.dart';
import 'package:grocery_app_admin/utils/db_helper.dart';

import '../adapters/order_history_adapter.dart';

class OrderHistory extends StatefulWidget {

  @override
  State<OrderHistory> createState() => _OrderHistoryState();

}

class _OrderHistoryState extends State<OrderHistory> {

  DbHelper db_helper = DbHelper();

  bool is_loading = false;

  List<OrderDetail> orders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.black,),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Order history", style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'inter-bold',
        ),),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(15),
        child: is_loading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
          itemCount: orders.length,
          shrinkWrap: true,
          controller: ScrollController(),
          itemBuilder: (context, index) {
            return OrderHistoryAdapter(
              order: orders[index],
            );
          },
        ),
      ),
    );
  }

  Future<void> init () async {
    setState(() {
      is_loading = true;
    });
    final order = await FirebaseDatabase.instance.ref().child('data/orders').get();
    if (order != null) {
      final orderValues = order.children;
      orderValues.forEach((element) async {
        String orderID = element.child("orderID").value;
        int timestamp = int.parse(element.child("orderTimestamp").value.toString());
        double deliveryPrice = double.parse(element.child("deliveryPrice").value.toString());
        double totalItemsCost = double.parse(element.child("totalItemsCost").value.toString());
        double orderTotal = double.parse(element.child("orderTotal").value.toString());
        String ownerID = element.child("ownerID").value;
        String paymentStatus = element.child("paymentStatus").value;
        String desc = element.child("desc").value;
        String selectedItems = element.child("selectedItems").value;
        String invoiceID = element.child("invoiceID").value;
        String deliveryStatus = element.child("deliveryStatus").value;
        OrderDetail order = OrderDetail(
            orderID: orderID,
            orderTotal: orderTotal,
            timestamp: timestamp,
            deliveryStatus: deliveryStatus,
            deliveryPrice: deliveryPrice,
            totalItemsCost: totalItemsCost,
            ownerID: ownerID,
            paymentStatus: paymentStatus,
            desc: desc,
            selectedItems: selectedItems,
            invoice_id: invoiceID
        );
        orders.add(order);
      });
    }
    orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState () {
    super.initState();
    init();
  }

}
