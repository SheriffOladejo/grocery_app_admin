import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/models/order_detail.dart';
import 'package:grocery_app_admin/utils/db_helper.dart';
import 'package:grocery_app_admin/utils/hex_color.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class OrderDetailsAdapter extends StatefulWidget {

  OrderDetail order;

  OrderDetailsAdapter({this.order});

  @override
  State<OrderDetailsAdapter> createState() => _OrderDetailsAdapterState();

}

class _OrderDetailsAdapterState extends State<OrderDetailsAdapter> {

  List<int> ids = [];

  DbHelper db_helper = DbHelper();

  @override
  Widget build(BuildContext context) {

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.order.timestamp);
    DateFormat formatter = DateFormat('d MMM y');
    String formattedDate = formatter.format(dateTime);

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 3,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate, style: TextStyle(
              color: HexColor("#808080"),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: 'inter-medium',
            ),),
            Container(height: 8,),
            Text(widget.order.paymentStatus, style: TextStyle(
              color: Colors.black,
              fontFamily: 'inter-medium',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),),
            Container(height: 8,),
            Text(widget.order.desc, style: TextStyle(
              color: HexColor("#808080"),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: 'inter-medium',
            ),),
            Container(height: 5,),
            Divider(),
            Container(height: 5,),
            ListView.builder(
              itemCount: ids.length,
              shrinkWrap: true,
              controller: ScrollController(),
              itemBuilder: (context, index) {
                return OrderItem(
                  id: ids[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkStatus (String invoice_id) async {
    final params = {
      "invoice_id": invoice_id,
      "public_key": "ISPubKey_live_849e32a1-7214-46b4-9b1b-cdce60c43142"
    };

    var url = Uri.parse('https://payment.intasend.com/api/v1/payment/status/');

    var headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Basic ZDhzdFI1WEFBNEtYWFdnQjluclhzN1ZZR2ZkamQ1dEQ6bnV5ZWZtYlNDWDZCZDJVeg==',
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        print(response.body.toString());
        Map<String, dynamic> data = jsonDecode(response.body.toString());
        String invoiceID = data["invoice"]["invoice_id"];
        String status = data["invoice"]["state"];
        await db_helper.updateOrderStatus(widget.order.orderID, invoiceID, status, widget.order.deliveryStatus, widget.order.desc, widget.order.ownerID);
      } else {
        print('Error posting data: ${response.body.toString()}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }

  }

  Future<void> init () async {
    ids = widget.order.selectedItems
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(' ', '')
        .split(',')
        .map((e) => int.parse(e))
        .toList();
    if (widget.order.paymentStatus != "Pay on delivery" || widget.order.deliveryStatus != "Pay on delivery") {
      await checkStatus(widget.order.invoice_id);
    }

  }

  @override
  void initState () {
    super.initState();
    init();
  }

}

class OrderItem extends StatefulWidget {

  int id;
  OrderItem({
    this.id
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  Item item;
  var db_helper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          Image.network(item.image, width: 25, height: 20,),
          Container(width: 10,),
          Text(item.itemName, style: TextStyle(
            color: Colors.black,
            fontFamily: 'inter-medium',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),),
        ],
      ),
    );
  }

  Future<void> init () async {
    item = await db_helper.getItemByID(widget.id);
    setState(() {

    });
  }

  @override
  void initState () {
    super.initState();
    init();
  }

}

