import 'package:flutter/material.dart';
import 'package:grocery_app_admin/models/app_user.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/models/order_detail.dart';
import 'package:grocery_app_admin/utils/constants.dart';
import 'package:grocery_app_admin/utils/db_helper.dart';
import 'package:grocery_app_admin/utils/hex_color.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class OrderHistoryAdapter extends StatefulWidget {

  OrderDetail order;

  OrderHistoryAdapter({
    this.order,
  });

  @override
  State<OrderHistoryAdapter> createState() => _OrderHistoryAdapterState();

}

class _OrderHistoryAdapterState extends State<OrderHistoryAdapter> {

  int selectedItems = 0;

  DbHelper db_helper = DbHelper();
  AppUser user;

  String image = "";

  var status_controller = TextEditingController();
  var desc_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.order.timestamp);
    DateFormat formatter = DateFormat('d MMM y');
    String formattedDate = formatter.format(dateTime);

    Color statusColor;
    if (widget.order.paymentStatus == 'processing') {
      statusColor = Colors.grey;
    }
    else if (widget.order.paymentStatus == 'cancelled') {
      statusColor = Colors.red;
    }
    else if (widget.order.paymentStatus == 'delivered') {
      statusColor = Colors.green;
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Order details'),
              content: SingleChildScrollView(
                child: Container(
                  height: 400,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Email: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Text(user.email, style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                        ],
                      ),
                      Container(height: 5,),
                      Row(
                        children: [
                          Text('Phone: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Text(user.phoneNumber, style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                        ],
                      ),
                      Container(height: 5,),
                      Row(
                        children: [
                          Text('Payment status: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Text(widget.order.paymentStatus, style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                        ],
                      ),
                      Container(height: 5,),
                      Row(
                        children: [
                          Text('Delivery status: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Text(widget.order.deliveryStatus, style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                        ],
                      ),
                      Container(height: 5,),
                      Row(
                        children: [
                          Text('Desc: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Text(widget.order.desc, style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                        ],
                      ),
                      Container(height: 5,),
                      Container(
                        child: Text("Delivery: " + user.deliveryAddress, style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-medium',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ), overflow: TextOverflow.ellipsis, maxLines: 3,),
                      ),
                      Container(height: 5,),
                      Row(
                        children: [
                          Text('Delivery status: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Container(width: 100, child: TextFormField(
                            controller: status_controller,
                          ),)
                        ],
                      ),
                      Container(height: 5,),
                      Row(
                        children: [
                          Text('Set description: ', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),),
                          Container(width: 100, child: TextFormField(
                            controller: desc_controller,
                          ),)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String desc = desc_controller.text.trim();
                    String status = status_controller.text.trim();
                    if (status.isNotEmpty) {
                      widget.order.deliveryStatus = status;
                    }
                    if (desc.isNotEmpty) {
                      widget.order.desc = desc;
                    }
                    await db_helper.updateOrderStatus(widget.order.orderID, widget.order.invoice_id, widget.order.paymentStatus, widget.order.deliveryStatus, widget.order.desc, widget.order.ownerID);
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Container(
          margin: const EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Image.network(image, width: 60, height: 50,),
              Container(width: 15,),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(formattedDate, style: TextStyle(
                    color: HexColor("#000000"),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'inter-medium',
                  ),),
                  Container(height: 10,),
                  Text("Selected items (${selectedItems.toString()})", style: TextStyle(
                    color: HexColor("#808080"),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'inter-medium',
                  ),),
                  Container(height: 15,),
                  Text("Delivery", style: TextStyle(
                    color: HexColor("#808080"),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'inter-medium',
                  ),),
                  Container(height: 15,),
                  Text("Order total", style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'inter-medium',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),),
                ],
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${Constants.CURRENCY} ${widget.order.totalItemsCost.toStringAsFixed(2)}", style: TextStyle(
                    color: HexColor("#808080"),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'inter-medium',
                  ),),
                  Container(height: 15,),
                  Text("${Constants.CURRENCY} ${widget.order.deliveryPrice.toStringAsFixed(2)}", style: TextStyle(
                    color: HexColor("#808080"),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'inter-medium',
                  ),),
                  Container(height: 15,),
                  Text("${Constants.CURRENCY} ${widget.order.orderTotal.toStringAsFixed(1)}", style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'inter-medium',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> init () async {
    var jsonData = json.decode(widget.order.selectedItems);
    for (var item in jsonData) {
      selectedItems++;
      Item i = await db_helper.getItemByID(item);
      image = i.image;
    }
    user = await db_helper.getUserByID(widget.order.ownerID);
    setState(() {

    });
  }

  @override
  void initState () {
    super.initState();
    init();
  }

}


