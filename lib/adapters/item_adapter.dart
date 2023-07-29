import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/utils/constants.dart';
import 'package:grocery_app_admin/utils/hex_color.dart';
import 'package:grocery_app_admin/views/item_details.dart';

class ItemAdapter extends StatefulWidget {

  Item item;
  bool showWholesalePrice = false;

  ItemAdapter({
    this.item,
    this.showWholesalePrice,
  });

  @override
  State<ItemAdapter> createState() => _ItemAdapterState();

}

class _ItemAdapterState extends State<ItemAdapter> {

  int selectedCount = 0;
  String stock = "";
  bool inStock = false;

  double totalDiscount = 0;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetails(
          item: widget.item,
          showWholesalePrice: widget.showWholesalePrice,
          selectedCount: selectedCount
        )));
      },
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        elevation: 3,
        child: SizedBox(
          height: 220,
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              totalDiscount != 0 ?
              Container(
                width: 120,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: HexColor("#ED893E"),
                ),
                child: Text(
                  "Save ${Constants.CURRENCY}${(totalDiscount)} on wholesale",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'inter-regular',
                  ),
                ),
              ) : Container(width: 0, height: 0,),
              Container(
                width: 240,
                margin: const EdgeInsets.only(right: 5),
                alignment: Alignment.centerRight,
                child: Icon(widget.item.favorite == "true" ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: widget.item.favorite == "true" ? Colors.red : Colors.grey,),
              ),
              Container(
                alignment: Alignment.center,
                width: 150,
                child: widget.showWholesalePrice ? Image.network(widget.item.wholesaleImage, width: 120, height: 90,) : Image.network(widget.item.image, width: 120, height: 90,)
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(widget.item.itemName.replaceRange(0, 1, widget.item.itemName.substring(0, 1).toUpperCase()), style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter-medium',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),),
              ),
              Container(height: 5,),
              widget.showWholesalePrice && widget.item.retailPrice == 0 ? Container(width: 0, height: 0,) : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("${Constants.CURRENCY}${widget.item.retailPrice}", style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter-bold',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  decoration: widget.showWholesalePrice ? TextDecoration.lineThrough : TextDecoration.none,
                ),),
              ),
              Container(height: 5,),
              widget.showWholesalePrice ? Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("${Constants.CURRENCY}${widget.item.wholesalePrice}", style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter-bold',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),),
              ) : Container(width: 0, height: 0,),
              Container(height: 8,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(stock, style: TextStyle(
                  color: inStock ? Colors.green : Colors.red,
                  fontFamily: 'inter-medium',
                  fontWeight: FontWeight.w500,
                  fontSize: 8,
                )),
              ),
              Container(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (selectedCount != 0) {
                          if (widget.showWholesalePrice) {
                            selectedCount = int.parse((selectedCount - widget.item.wholesaleUnit).toString());
                          }
                          else {
                            selectedCount--;
                          }
                          setState(() {

                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selectedCount == 0 ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Icon(CupertinoIcons.minus, color: Colors.white, size: 20,),
                      ),
                    ),
                    Text("$selectedCount", style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'inter-bold',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),),
                    GestureDetector(
                      onTap: () {
                        if (selectedCount != widget.item.stockCount) {
                          if (widget.showWholesalePrice) {
                            selectedCount = int.parse((selectedCount + widget.item.wholesaleUnit).toString());
                          }
                          else {
                            selectedCount++;
                          }
                          setState(() {

                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selectedCount == widget.item.stockCount ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Icon(CupertinoIcons.plus, color: Colors.white, size: 20,),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ),
        ),
      ),
    );
  }

  Future<void> init () async {
    if (widget.item.stockCount > 5) {
      stock = "In stock";
      inStock = true;
    }
    else if (widget.item.stockCount <= 5) {
      stock = "${widget.item.stockCount} left";
      inStock = false;
    }
    else if (widget.item.stockCount == 0) {
      stock = "Out of stock";
      inStock = false;
      // delete item from db
    }

    if (widget.item.retailPrice != 0 && widget.item.wholesalePrice != 0) {
      double normalPrice = widget.item.retailPrice * widget.item.wholesaleUnit;
      totalDiscount = ((normalPrice - widget.item.wholesalePrice) / normalPrice);
      selectedCount = int.parse(widget.item.wholesaleUnit.toString());
      print("total discount: $totalDiscount}");
    }

    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

}
