import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/adapters/item_adapter.dart';
import 'package:grocery_app_admin/models/app_user.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/utils/constants.dart';
import 'package:grocery_app_admin/utils/db_helper.dart';
import 'package:grocery_app_admin/utils/hex_color.dart';
import 'package:grocery_app_admin/utils/methods.dart';

class ItemDetails extends StatefulWidget {

  Item item;
  int selectedCount;
  bool showWholesalePrice;

  ItemDetails({this.item, this.showWholesalePrice, this.selectedCount});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();

}

class _ItemDetailsState extends State<ItemDetails> {

  int cartCount;

  List<Item> relatedProducts = [];

  String stock = "";
  bool inStock = false;

  bool isLoading = false;

  var db_helper = DbHelper();
  AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.black,),
        ),
        actions: [
          InkWell(
            onTap: () {

            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/cart.png",),
                cartCount == 0 ? Container(width: 0, height: 0,) : Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.topRight,
                  child: Container(
                    alignment: Alignment.center,
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: HexColor("#66906A"),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      "${cartCount.toString()}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontFamily: 'inter-medium',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(width: 20,),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(right: 5),
                alignment: Alignment.centerRight,
                child: Icon(widget.item.favorite == "true" ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: widget.item.favorite == "true" ? Colors.red : Colors.grey,),
              ),
              Container(height: 5,),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Image.network(widget.showWholesalePrice ? widget.item.wholesaleImage : widget.item.image, width: 330, height: 235,)
              ),
              Container(height: 10,),
              Text(widget.item.itemName, style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-bold',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),),
              Container(height: 5,),
              widget.showWholesalePrice && widget.item.retailPrice == 0 ? Container(width: 0, height: 0,) : Text("${Constants.CURRENCY}${widget.item.retailPrice}", style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-bold',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                decoration: widget.showWholesalePrice ? TextDecoration.lineThrough : TextDecoration.none,
              ),),
              Container(height: 5,),
              widget.showWholesalePrice ? Text("${Constants.CURRENCY}${widget.item.wholesalePrice}", style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-bold',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),) : Container(width: 0, height: 0,),
              Container(height: 8,),
              Text(stock, style: TextStyle(
                color: inStock ? Colors.green : Colors.red,
                fontFamily: 'inter-medium',
                fontWeight: FontWeight.w500,
                fontSize: 8,
              )),
              Container(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.selectedCount != 0) {
                        if (widget.showWholesalePrice) {
                          widget.selectedCount = int.parse((widget.selectedCount - widget.item.wholesaleUnit).toString());
                        }
                        else {
                          widget.selectedCount--;
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
                        color: widget.selectedCount == 0 ? Colors.grey : Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Icon(CupertinoIcons.minus, color: Colors.white, size: 20,),
                    ),
                  ),
                  Text("${widget.selectedCount}", style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'inter-bold',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),),
                  GestureDetector(
                    onTap: () {
                      if (widget.selectedCount != widget.item.stockCount) {
                        if (widget.showWholesalePrice) {
                          widget.selectedCount = int.parse((widget.selectedCount + widget.item.wholesaleUnit).toString());
                        }
                        else {
                          widget.selectedCount++;
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
                        color: widget.selectedCount == widget.item.stockCount ? Colors.grey : Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Icon(CupertinoIcons.plus, color: Colors.white, size: 20,),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 35,
                    alignment: Alignment.center,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: MaterialButton(
                      color: HexColor("#66906A"),
                      onPressed: () async {
                        if (widget.selectedCount != 0) {
                          await db_helper.saveCart(
                            widget.item.id,
                            widget.selectedCount,
                            widget.showWholesalePrice.toString(),
                            user.phoneNumber,
                          );
                          showToast("Cart saved");
                          Navigator.pop(context);
                        }
                        else {
                          showToast("Select at least one");
                        }
                      },
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      elevation: 5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/images/cart_.png", width: 24, height: 24,),
                          const Text("Add to cart", style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'inter-medium',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Container(height: 10,),
              relatedProducts.length == 0 ? Container(width: 0, height: 0,) : Text("Related products", style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-bold',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),),
              Container(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: isLoading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
                    shrinkWrap: true,
                    itemCount: relatedProducts.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) => ItemAdapter(item: relatedProducts[index], showWholesalePrice: widget.showWholesalePrice,),
              ),
              )],
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
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
    user = await db_helper.getUser();
    List<Item> cart = await db_helper.getCart();
    cartCount = cart.length;
    relatedProducts = await db_helper.getRelatedProducts(widget.item, widget.item.category);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

}
