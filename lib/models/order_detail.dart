class OrderDetail {

  String orderID;
  int timestamp;
  String invoice_id;
  double deliveryPrice;
  double totalItemsCost;
  double orderTotal;
  String ownerID;
  String paymentStatus;
  String deliveryStatus;
  String desc;
  String selectedItems;

  OrderDetail({
    this.orderID,
    this.invoice_id,
    this.ownerID,
    this.timestamp,
    this.paymentStatus,
    this.deliveryStatus,
    this.desc,
    this.orderTotal,
    this.totalItemsCost,
    this.deliveryPrice,
    this.selectedItems,
  });

}