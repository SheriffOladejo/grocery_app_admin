import 'package:firebase_database/firebase_database.dart';
import 'package:grocery_app_admin/models/app_user.dart';
import 'package:grocery_app_admin/models/category.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/models/order_detail.dart';
import 'package:grocery_app_admin/utils/methods.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {

  DbHelper._createInstance();

  String db_name = "grocery_app.db";

  static Database _database;
  static DbHelper helper;

  String category_table = "category_table";
  String col_cat_id = "id";
  String col_cat_title = "title";
  String col_cat_image = "image";

  String item_table = "item_table";
  String col_item_id = "id";
  String col_item_name = "name";
  String col_item_desc = "description";
  String col_item_category = "category";
  String col_item_image = "image";
  String col_item_wholesale_image = "wholesale_image";
  String col_item_stock_count = "stock_count";
  String col_item_wholesale_price = "wholesale_price";
  String col_wholesale_unit = "unit";
  String col_retail_price = "retail_price";

  String user_table = "user_table";
  String col_email = "email";
  String col_userID = "userID";
  String col_deliveryAddress = "deliveryAddress";
  String col_phoneNumber = "phoneNumber";
  String col_date_joined = "dateJoined";
  String col_stripe_id = "stripeID";
  String col_favorites = "favorites";

  String cart_table = "cart_table";
  String col_cart_item_id = "id";
  String col_buying_count = "buying_count";
  String col_buying_wholesale = "buying_wholesale";

  String order_table = "order_table";
  String col_invoice_id = "invoiceID";
  String col_order_id = "orderID";
  String col_order_timestamp = "timestamp";
  String col_delivery_price = "deliveryPrice";
  String col_total_items_cost = "totalItemsCost";
  String col_order_total = "orderTotal";
  String col_owner_id = "ownerID";
  String col_order_payment_status = "paymentStatus";
  String col_order_delivery_status = "deliveryStatus";
  String col_order_desc = "desc";
  String col_selected_items = "selectedItems";

  Future createDb(Database db, int version) async {

    String create_order_table = "create table $order_table ("
        "$col_order_id text,"
        "$col_invoice_id text,"
        "$col_order_timestamp integer,"
        "$col_delivery_price double,"
        "$col_total_items_cost double,"
        "$col_order_total double,"
        "$col_order_payment_status varchar(20),"
        "$col_order_delivery_status varchar(20),"
        "$col_order_desc text,"
        "$col_owner_id text,"
        "$col_selected_items text)";

    String create_cart_table = "create table $cart_table ("
        "$col_cart_item_id integer,"
        "$col_buying_count integer,"
        "$col_buying_wholesale varchar(10))";

    String create_category_table = "create table $category_table ("
        "$col_cat_id integer primary key,"
        "$col_cat_title varchar(20),"
        "$col_cat_image text)";

    String create_user_table = "create table $user_table ("
        "$col_userID text,"
        "$col_deliveryAddress text,"
        "$col_phoneNumber text,"
        "$col_email text,"
        "$col_date_joined integer,"
        "$col_stripe_id text,"
        "$col_favorites text)";

    String create_items_table = "create table $item_table ("
        "$col_item_name varchar(20),"
        "$col_item_id integer primary key,"
        "$col_item_desc text,"
        "$col_item_category varchar(20),"
        "$col_item_image text,"
        "$col_item_wholesale_image text,"
        "$col_item_wholesale_price double,"
        "$col_wholesale_unit integer,"
        "$col_retail_price double,"
        "$col_item_stock_count integer)";

    await db.execute(create_cart_table);
    await db.execute(create_category_table);
    await db.execute(create_items_table);
    await db.execute(create_user_table);
    await db.execute(create_order_table);
  }

  Future<void> saveOrder (OrderDetail order, bool exist, bool update) async {
    Database db = await database;
    String query = "insert into $order_table ($col_order_id, $col_order_timestamp, "
        "$col_delivery_price, $col_total_items_cost, $col_order_total, $col_owner_id, "
        "$col_order_payment_status, $col_order_desc, $col_selected_items, $col_invoice_id, $col_order_delivery_status) values ('${order.orderID}', "
        "${order.timestamp}, ${order.deliveryPrice}, ${order.totalItemsCost}, "
        "${order.orderTotal}, '${order.ownerID}', '${order.paymentStatus}', '${order.desc}', '${order.selectedItems}', '${order.invoice_id}', '${order.deliveryStatus}')";
    try {
      if (!update) {
        await db.execute(query);
      }
      final params = {
        "orderID": order.orderID,
        "orderTimestamp": order.timestamp,
        "deliveryPrice": order.deliveryPrice,
        "totalItemsCost": order.totalItemsCost,
        "orderTotal": order.orderTotal,
        "ownerID": order.ownerID,
        "paymentStatus": order.paymentStatus,
        "desc": order.desc,
        "selectedItems": order.selectedItems,
        "invoiceID": order.invoice_id,
        "deliveryStatus": order.deliveryStatus
      };
      AppUser user = await getUser();
      DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/${user.phoneNumber}/orders/${order.orderID}");
      DatabaseReference ref2 = FirebaseDatabase.instance.ref().child("data/orders/${order.orderID}");
      if (!exist) {
        await ref.set(params);
        await ref2.set(params);
      }
    }
    catch(e) {
      print("db_helper.saveOrder error: ${e.toString()}");
      showToast("Order not saved");
    }
  }

  Future<void> updateOrderStatus (String orderID, String invoiceID, String status, String deliveryStatus, String desc, String phone) async {
    Database db = await database;
    String query = "update $order_table set $col_order_payment_status = '$status',"
        "$col_order_delivery_status = '$deliveryStatus', $col_order_desc = '$desc' where $col_invoice_id = '$invoiceID'";
    await db.execute(query);
    final params = {
      "orderID": orderID,
      "paymentStatus": status,
      "invoiceID": invoiceID,
      "deliveryStatus": deliveryStatus,
      "desc": desc
    };
    AppUser user = await getUser();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/${phone}/orders/${orderID}");
    DatabaseReference ref2 = FirebaseDatabase.instance.ref().child("data/orders/${orderID}");
    await ref.update(params);
    await ref2.update(params);
  }

  Future<List<OrderDetail>> getOrders () async {
    List<OrderDetail> orders = [];
    Database db = await database;
    String query = "select * from $order_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      String orderID = result[i][col_order_id];
      int timestamp = int.parse(result[i][col_order_timestamp].toString());
      String invoiceID = result[i][col_invoice_id].toString();
      double deliveryPrice = double.parse(result[i][col_delivery_price].toString());
      double totalItemsCost = double.parse(result[i][col_total_items_cost].toString());
      String ownerID = result[i][col_owner_id];
      String paymentStatus = result[i][col_order_payment_status];
      String deliveryStatus = result[i][col_order_delivery_status];
      String desc = result[i][col_order_desc];
      String selectedItems = result[i][col_selected_items];

      var order = OrderDetail(
        orderID: orderID,
        timestamp: timestamp,
        invoice_id: invoiceID,
        deliveryPrice: deliveryPrice,
        totalItemsCost: totalItemsCost,
        ownerID: ownerID,
        paymentStatus: paymentStatus,
        deliveryStatus: deliveryStatus,
        desc: desc,
        selectedItems: selectedItems,
      );

      orders.add(order);

    }
    return orders;
  }

  Future<void> deleteCart (int itemID, String phoneNumber) async {
    Database db = await database;
    String query = "delete from $cart_table where $col_cart_item_id = $itemID";
    await db.execute(query);
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/$phoneNumber/cart/$itemID");
    await ref.remove();
  }

  Future<void> updateCart (int itemID, int buyingCount, phoneNumber) async {
    Database db = await database;
    String query = "update $cart_table set $col_buying_count = $buyingCount where $col_cart_item_id = $itemID";
    await db.execute(query);
    final params = {
      "itemID": itemID,
      "buyingCount": buyingCount,
    };
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/$phoneNumber/cart/$itemID");
    await ref.update(params);
  }

  Future<void> saveCart (int itemID, int buyingCount, String buyingWholesale, String phoneNumber) async {
    Database db = await database;
    String query = "insert into $cart_table ($col_cart_item_id, $col_buying_count, $col_buying_wholesale) values ("
        "$itemID, $buyingCount, '$buyingWholesale')";
    try {
      await db.execute(query);
      final params = {
        "itemID": itemID,
        "buyingCount": buyingCount,
        "buyingWholeSale": buyingWholesale,
      };
      DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/$phoneNumber/cart/$itemID");
      await ref.set(params);
    }
    catch(e) {
      print("db_helper.saveCart error: ${e.toString()}");
      showToast("Cart not saved");
    }
  }

  Future<List<Item>> getCart () async {
    List<Item> cart = [];
    Database db = await database;
    String query = "select * from $cart_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      int id = result[i][col_item_id];
      int buyingCount = result[i][col_buying_count];
      String buying_wholesale = result[i][col_buying_wholesale];
      Item item = await getItemByID(id);
      item.buyingCount = buyingCount;
      item.isBuyingWholesale = buying_wholesale;
      cart.add(item);
    }
    return cart;
  }

  Future<void> saveCategory (Category cat) async {
    Database db = await database;
    String query = "insert into $category_table ($col_cat_id, $col_cat_image, $col_cat_title) values ("
        "${cat.id}, '${cat.image}', '${cat.title}')";
    try {
      await db.execute(query);
    }
    catch(e) {
      print("db_helper.saveCategory error: ${e.toString()}");
      showToast("Category not saved");
    }
  }

  Future<List<Category>> getCategories () async {
    List<Category> list = [Category(
        title: "all",
        image: "",
        id: 1
    )];
    Database db = await database;
    String query = "select * from $category_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Category cat = Category(
        id: result[i][col_cat_id],
        image: result[i][col_cat_image],
        title: result[i][col_cat_title],
      );
      list.add(cat);
    }
    return list;
  }

  Future<AppUser> getUser () async {
    Database db = await database;
    String query = "select * from $user_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    AppUser user;
    for (int i = 0; i < result.length; i++) {
      user = AppUser(
        userID: result[i][col_userID].toString(),
        email: result[i][col_email].toString(),
        phoneNumber: result[i][col_phoneNumber].toString(),
        deliveryAddress: result[i][col_deliveryAddress].toString(),
        dateJoined: result[i][col_date_joined],
        stripeID: result[i][col_stripe_id],
      );
    }
    return user;
  }

  Future<AppUser> getUserByID (String phoneNumber) async {
    final snapshot = await FirebaseDatabase.instance.ref().child('data/users/$phoneNumber').get();
    Map<dynamic, dynamic> values = snapshot.value;
    AppUser u;
    u = AppUser(
        userID: values["userID"].toString(),
        dateJoined: int.parse(values["dateJoined"].toString()),
        email: values["email"].toString(),
        phoneNumber: values["phoneNumber"].toString(),
        deliveryAddress: values["deliveryAddress"].toString()
    );
    return u;
  }

  Future<void> saveUser (AppUser user, bool exist) async {
    Database db = await database;
    String query = "insert into $user_table ($col_userID, $col_deliveryAddress, $col_phoneNumber, "
        "$col_email, $col_date_joined, $col_stripe_id) values ('${user.userID}', '${user.deliveryAddress}', "
        "'${user.phoneNumber}', '${user.email}', ${user.dateJoined}, '${user.stripeID}')";
    try {
      await db.execute(query);
      final params = {
        "userID": user.userID,
        "deliveryAddress": user.deliveryAddress,
        "phoneNumber": user.phoneNumber,
        "email": user.email,
        "dateJoined": user.dateJoined
      };
      DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/${user.phoneNumber}");
      if (!exist) {
        await ref.set(params);
      }
    }
    catch(e) {
      print("db_helper.saveUser error: ${e.toString()}");
      showToast("User not saved");
    }
  }

  Future<void> updateAddress (AppUser user) async {
    Database db = await database;
    String query = "update $user_table set $col_deliveryAddress = '${user.deliveryAddress}'";
    await db.execute(query);
    final params = {
      "deliveryAddress": user.deliveryAddress,
    };
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/users/${user.phoneNumber}");
    await ref.update(params);
  }

  Future<void> saveItem (Item item) async {
    Database db = await database;
    String query = "insert into $item_table ($col_item_id, $col_item_name, $col_item_desc, $col_item_category, "
        "$col_item_image, $col_item_wholesale_image, $col_item_stock_count, $col_item_wholesale_price, $col_wholesale_unit, "
        "$col_retail_price) values ('${item.id}', '${item.itemName}', '${item.description}', '${item.category}', "
        "'${item.image}', '${item.wholesaleImage}', '${item.stockCount}', '${item.wholesalePrice}', '${item.wholesaleUnit}', "
        "'${item.retailPrice}')";
    try {
      await db.execute(query);
    }
    catch(e) {
      print("db_helper.saveItem error: ${e.toString()}");
      showToast("Item not saved");
    }
  }

  Future<void> updateItem (Item item) async {
    Database db = await database;
    String query = "update $item_table set $col_item_name = '${item.itemName}', $col_item_desc = '${item.description}', "
        "$col_item_category = '${item.category}', $col_item_image = '${item.image}', $col_item_wholesale_image = '${item.wholesaleImage}', "
        "$col_item_stock_count = '${item.stockCount}', $col_item_wholesale_price = '${item.wholesalePrice}', $col_wholesale_unit = '${item.wholesaleUnit}', "
        "$col_retail_price = '${item.retailPrice}' where $col_item_id = ${item.id}";
    try {
      await db.execute(query);
    }
    catch(e) {
      print("db_helper.updateItem error: ${e.toString()}");
      showToast("Item not updated");
    }
  }

  Future<List<Item>> getWholesaleItemsByCategory (String category) async {
    List<Item> list = [];
    Database db = await database;
    String query = "select * from $item_table where $col_item_category = '$category'";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Item item = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
      if (item.wholesalePrice != 0) {
        if (item.wholesalePrice != 0 && item.wholesaleUnit > 1) {
          double originalPrice = item.retailPrice * item.wholesaleUnit;
          double discount = ((item.wholesalePrice - originalPrice) / originalPrice) * 100;
          item.discount = discount;
        }
        list.add(item);
      }
    }
    return list;
  }

  Future<List<Item>> getWholesaleItems () async {
    List<Item> list = [];
    Database db = await database;
    String query = "select * from $item_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Item item = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
      if (item.wholesalePrice != 0) {
        if (item.wholesalePrice != 0 && item.wholesaleUnit > 1) {
          double originalPrice = item.retailPrice * item.wholesaleUnit;
          double discount = ((item.wholesalePrice - originalPrice) / originalPrice) * 100;
          item.discount = discount;
        }
        list.add(item);
      }
    }
    return list;
  }

  Future<List<Item>> getRetailItemsByCategory (String category) async {
    List<Item> list = [];
    Database db = await database;
    String query = "select * from $item_table where $col_item_category = '$category'";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Item item = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
      if (item.retailPrice != 0) {
        if (item.wholesalePrice != 0 && item.wholesaleUnit > 1) {
          double originalPrice = item.retailPrice * item.wholesaleUnit;
          double discount = ((item.wholesalePrice - originalPrice) / originalPrice) * 100;
          item.discount = discount;
        }
        list.add(item);
      }
    }
    return list;
  }

  Future<List<Item>> getRetailItems () async {
    List<Item> list = [];
    Database db = await database;
    String query = "select * from $item_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Item item = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
      if (item.retailPrice != 0) {
        if (item.wholesalePrice != 0 && item.wholesaleUnit > 1) {
          double originalPrice = item.retailPrice * item.wholesaleUnit;
          double discount = ((item.wholesalePrice - originalPrice) / originalPrice) * 100;
          item.discount = discount;
        }
        list.add(item);
      }
    }
    return list;
  }

  Future<Item> getFirebaseItemByID (int id) async {
    Item item;
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
      if (i.id == id) {
        item = i;
      }
    });
    return item;
  }

  Future<List<Item>> getItems() async {
    List<Item> list = [];
    Database db = await database;
    String query = "select * from $item_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Item item = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
      print("dbhelper item id: ${item.id} and price ${item.retailPrice}");
      list.add(item);
    }
    return list;
  }

  Future<List<Item>> getRelatedProducts (Item item, String category) async {
    List<Item> list = [];
    Database db = await database;
    String query = "select * from $item_table where $col_item_category = '$category'";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      Item it = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
      if (it.id != item.id) {
        list.add(it);
      }
    }
    return list;
  }

  Future<Item> getItemByID (int id) async {
    var item = null;
    Database db = await database;
    String query = "select * from $item_table where $col_item_id = $id";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for (int i = 0; i < result.length; i++) {
      item = Item(
        favorite: '',
        discount: 0,
        buyingCount: 0,
        retailPrice: result[i][col_retail_price],
        wholesaleUnit: result[i][col_wholesale_unit],
        wholesalePrice: result[i][col_item_wholesale_price],
        id: result[i][col_item_id],
        isBuyingWholesale: "",
        wholesaleImage: result[i][col_item_wholesale_image],
        itemName: result[i][col_item_name],
        description: result[i][col_item_desc],
        category: result[i][col_item_category],
        image: result[i][col_item_image],
        stockCount: result[i][col_item_stock_count],
      );
    }
    return item;
  }

  factory DbHelper(){
    if(helper == null){
      helper = DbHelper._createInstance();
    }
    return helper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    final db_path = await getDatabasesPath();
    final path = join(db_path, db_name);
    return await openDatabase(path, version: 1, onCreate: createDb);
  }

}