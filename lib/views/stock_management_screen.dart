import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/adapters/stock_adapter.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/utils/db_helper.dart';
import 'package:grocery_app_admin/utils/hex_color.dart';
import 'package:grocery_app_admin/utils/methods.dart';
import 'package:grocery_app_admin/views/add_item.dart';

class StockManagementScreen extends StatefulWidget {

  const StockManagementScreen({Key key}) : super(key: key);

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();

}

class _StockManagementScreenState extends State<StockManagementScreen> {

  List<Item> stockList = [];
  var db_helper = DbHelper();

  var search_controller = TextEditingController();
  List<Item> searchList = [];

  bool isLoading = false;

  Future<void> search (String search) async {
    searchList.clear();
    if (search.isNotEmpty) {
      for (var i = 0; i < stockList.length; i++) {
        if (stockList[i].itemName.contains(search)) {
          searchList.add(stockList[i]);
        }
      }
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Stock management", style: TextStyle(
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
        margin: const EdgeInsets.all(15),
        child: isLoading ? Center(child: CircularProgressIndicator(),) : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[500],
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      onChanged: (val) async {
                        await search(search_controller.text);
                      },
                      controller: search_controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 15,),
            Container(
              height: 500,
              child: ListView.builder(
                itemCount: searchList.isNotEmpty ? searchList.length : stockList.length,
                shrinkWrap: true,
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  return StockAdapter(
                    item: searchList.isNotEmpty ? searchList[index] : stockList[index],
                    callback: callback,
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: HexColor("#66906A"),
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          await Navigator.push(context, slideLeft(AddItem()));
          stockList = await db_helper.getItems();
          setState(() {

          });
        },
      ),
    );
  }

  Future<void> callback () async {
    stockList = await db_helper.getItems();
    setState(() {

    });
  }

  Future<void> getItems () async {
    setState(() {
      isLoading = true;
    });
    final snapshot = await FirebaseDatabase.instance.ref().child('data/items/').get();
    final list = snapshot.children;
    list.forEach((element) async {
      var i = Item(
        id: int.parse(element.child("id").value.toString()),
        stockCount: element.child("stockCount").value,
        itemName: element.child("itemName").value,
        description: element.child("description").value,
        category: element.child("category").value,
        image: element.child("image").value,
        isBuyingWholesale: element.child("isBuyingWholesale").value,
        wholesaleImage: element.child("image").value,
        favorite: element.child("favorite").value,
        wholesalePrice: double.parse(element.child("wholesalePrice").value.toString()),
        wholesaleUnit: element.child("wholesaleUnit").value,
        buyingCount: element.child("buyingCount").value,
        retailPrice: double.parse(element.child("retailPrice").value.toString()),
        discount: double.parse(element.child("discount").value.toString()),
      );
      await db_helper.saveItem(i);
    });
    stockList = await db_helper.getItems();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> init () async {
    stockList = await db_helper.getItems();
    if (stockList.isEmpty) {
      await getItems();
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
