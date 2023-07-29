import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/adapters/category_adapter2.dart';
import 'package:grocery_app_admin/models/category.dart';
import 'package:grocery_app_admin/models/item.dart';
import 'package:grocery_app_admin/utils/hex_color.dart';
import 'package:grocery_app_admin/utils/methods.dart';
import 'package:grocery_app_admin/utils/db_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddItem extends StatefulWidget {

  Item item;
  Function callback;
  AddItem({
    this.item,
    this.callback,
  });

  @override
  State<AddItem> createState() => _AddItemState();

}

class _AddItemState extends State<AddItem> {

  int stockCount = 0;

  var name_controller = TextEditingController();
  var description_controller = TextEditingController();
  var wholesale_unit_controller = TextEditingController();
  var category_controller = TextEditingController();
  var price_controller = TextEditingController();

  File _image;
  String _uploadedImageUrl;

  bool isWholeSale = false;

  List<Category> categoryList = [];

  final form_key = GlobalKey<FormState>();

  bool isLoading = false;

  var db_helper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: GestureDetector(
          onTap: () async {
            await widget.callback();
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.black,),
        ),
        title: Text("Add item", style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'inter-bold',
        ),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: form_key,
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              elevation: 3,
              child: Container(
                margin: const EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width,
                child: isLoading ? Center(child: CircularProgressIndicator(),) : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _getImage();
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(70)),
                              color: HexColor("#33000000"),
                            ),
                            child: widget.item != null ? Image.network(widget.item.image) : _image != null ? ClipRRect(
                              borderRadius: BorderRadius.circular(35.0), // Adjust the radius value as per your requirement
                              child: Image.file(
                                _image, // Replace with your image asset path
                                width: 70.0, // Adjust the width as per your requirement
                                height: 70.0, // Adjust the height as per your requirement
                                fit: BoxFit.cover,
                              ),
                            ) : Image.asset("assets/images/add_gallery.png"),
                          ),
                        ),
                        Spacer(),
                        widget.item == null ? Container(width: 0, height: 0,) : Image.asset("assets/images/trash.png")
                      ],
                    ),
                    Container(height: 10,),
                    widget.item != null ?
                    Text("You have ${widget.item.stockCount.toString()} in stock", style: TextStyle(
                      color: HexColor("#808080"),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontFamily: 'inter-medium',
                    ),) :
                        Container(width: 0, height: 0,),
                    Container(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (stockCount != 0) {
                                stockCount--;
                                setState(() {

                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: stockCount == 0 ? Colors.grey : Colors.green,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Icon(CupertinoIcons.minus, color: Colors.white, size: 20,),
                            ),
                          ),
                          Container(width: 20,),
                          Text("$stockCount", style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter-bold',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),),
                          Container(width: 20,),
                          GestureDetector(
                            onTap: () {
                              stockCount++;
                              setState(() {

                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Icon(CupertinoIcons.plus, color: Colors.white, size: 20,),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 10,),
                    Row(
                      children: [
                        Text("Is this a wholesale product?", style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-medium',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),),
                        Container(width: 20,),
                        Checkbox(
                          value: isWholeSale,
                          onChanged: (bool value) {
                            setState(() {
                              isWholeSale = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Container(height: 10,),
                    Container(
                      height: 70,
                      child: TextFormField(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CategoryDialog(
                                categoryList: categoryList,
                                context: context,
                                callback: callback,
                              );
                            },
                          );
                        },
                        readOnly: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        controller: category_controller,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-regular',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Category",
                          hintStyle: TextStyle(
                            color: HexColor("#1B1C1E66"),
                            fontFamily: 'inter-regular',
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.only(left: 15),
                          label: Text(
                            "Category",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'inter-regular',
                              fontSize: 14,
                            ),
                          ),
                          enabledBorder: enabledBorder(),
                          //disabledBorder: disabledBorder(),
                          //errorBorder: errorBorder(),
                          focusedBorder: focusedBorder(),
                        ),
                      ),
                    ),
                    Container(
                      height: 70,
                      child: TextFormField(
                        readOnly: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        controller: name_controller,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-regular',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Name",
                          hintStyle: TextStyle(
                            color: HexColor("#1B1C1E66"),
                            fontFamily: 'inter-regular',
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.only(left: 15),
                          label: Text(
                            "Name",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'inter-regular',
                              fontSize: 14,
                            ),
                          ),
                          enabledBorder: enabledBorder(),
                          //disabledBorder: disabledBorder(),
                          //errorBorder: errorBorder(),
                          focusedBorder: focusedBorder(),
                        ),
                      ),
                    ),
                    Container(
                      height: 70,
                      child: TextFormField(
                        readOnly: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        controller: description_controller,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-regular',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Description",
                          hintStyle: TextStyle(
                            color: HexColor("#1B1C1E66"),
                            fontFamily: 'inter-regular',
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.only(left: 15),
                          label: Text(
                            "Description",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'inter-regular',
                              fontSize: 14,
                            ),
                          ),
                          enabledBorder: enabledBorder(),
                          //disabledBorder: disabledBorder(),
                          //errorBorder: errorBorder(),
                          focusedBorder: focusedBorder(),
                        ),
                      ),
                    ),
                    isWholeSale ?
                    Container(
                      height: 70,
                      child: TextFormField(
                        readOnly: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        controller: wholesale_unit_controller,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-regular',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Wholesale unit",
                          hintStyle: TextStyle(
                            color: HexColor("#1B1C1E66"),
                            fontFamily: 'inter-regular',
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.only(left: 15),
                          label: Text(
                            "Wholesale unit",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'inter-regular',
                              fontSize: 14,
                            ),
                          ),
                          enabledBorder: enabledBorder(),
                          //disabledBorder: disabledBorder(),
                          //errorBorder: errorBorder(),
                          focusedBorder: focusedBorder(),
                        ),
                      ),
                    ) : Container(width: 0, height: 0,),
                    Container(
                      height: 70,
                      child: TextFormField(
                        readOnly: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        controller: price_controller,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'inter-regular',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: isWholeSale ? "Wholesale price" : "Retail price",
                          hintStyle: TextStyle(
                            color: HexColor("#1B1C1E66"),
                            fontFamily: 'inter-regular',
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.only(left: 15),
                          label: Text(
                            isWholeSale ? "Wholesale price" : "Retail price",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'inter-regular',
                              fontSize: 14,
                            ),
                          ),
                          enabledBorder: enabledBorder(),
                          //disabledBorder: disabledBorder(),
                          //errorBorder: errorBorder(),
                          focusedBorder: focusedBorder(),
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 35,
                      alignment: Alignment.center,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: MaterialButton(
                        color: HexColor("#66906A"),
                        onPressed: () async {

                          await saveItem();
                        },
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        elevation: 5,
                        child: const Text("Save", style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'inter-medium',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> callback(String category) async {
    category_controller.text = category;
    setState(() {

    });
  }

  Future<void> init () async {
    if (widget.item != null) {
      stockCount = widget.item.stockCount;
      name_controller.text = widget.item.itemName;
      description_controller.text = widget.item.description;
      category_controller.text = widget.item.category;
      if (widget.item.wholesalePrice == 0) {
        price_controller.text = widget.item.retailPrice.toStringAsFixed(2);
      }
      else {
        price_controller.text = widget.item.wholesalePrice.toStringAsFixed(2);
        isWholeSale = true;
      }
    }
    if (widget.item != null) {
      await getDetails();
    }
    await getCategories();
  }

  Future<void> getCategories () async {
    categoryList = await db_helper.getCategories();
    int last_id = 0;
    if (categoryList.isNotEmpty) {
      last_id = categoryList[categoryList.length - 1].id;
    }
    final snapshot = await FirebaseDatabase.instance.ref().child('data/categories/').get();
    final list = snapshot.children;
    list.forEach((element) async {
      var i = Category(
        id: int.parse(element.child("id").value.toString()),
        image: element.child("image").value,
        title: element.child("title").value,
      );
      if (i.id > last_id) {
        await db_helper.saveCategory(i);
      }
    });
    categoryList = await db_helper.getCategories();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> _uploadImage() async {
    // Upload image to Firebase Storage
    if (_image != null) {
      Reference storageReference =
      FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
      UploadTask uploadTask = storageReference.putFile(_image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  Future<void> getDetails() async {
    Item i = await db_helper.getFirebaseItemByID(widget.item.id);
    await db_helper.updateItem(i);
    widget.item = i;
    stockCount = widget.item.stockCount;
    setState(() {

    });
  }

  Future<void> saveItem() async {
    if (form_key.currentState.validate() && stockCount > 0) {
      setState(() {
        isLoading = true;
      });
      if (widget.item != null) {
        String category = category_controller.text.toString();
        String name = name_controller.text.toString();
        String desc = description_controller.text.toString();
        String image = widget.item.image;
        if (_image != null) {
          await _uploadImage();
          image = _uploadedImageUrl;
        }
        String id = widget.item.id.toString();
        double wholesalePrice;
        double retailPrice;
        int wholesaleUnit;

        if (isWholeSale) {
          wholesalePrice = double.parse(price_controller.text.toString());
          wholesaleUnit = int.parse(wholesale_unit_controller.text.toString());
        }
        else {
          retailPrice = double.parse(price_controller.text.toString());
        }

        final params = {
          "id": id,
          "category": category,
          "itemName": name,
          "description": desc,
          "image": image,
          "isBuyingWholesale": "false",
          "wholesaleImage": image,
          "favorite": "false",
          "wholesalePrice": isWholeSale ? wholesalePrice : 0,
          "wholesaleUnit": isWholeSale ? wholesaleUnit : 0,
          "buyingCount": 0,
          "retailPrice": !isWholeSale ? retailPrice : 0,
          "discount": 0,
          "stockCount": stockCount,
        };

        Item item = Item(
          id: int.parse(id),
          stockCount: stockCount,
          itemName: name,
          description: desc,
          category: category,
          image: image,
          isBuyingWholesale: "false",
          wholesaleImage: image,
          favorite: "false",
          wholesalePrice: isWholeSale ? wholesalePrice : 0,
          wholesaleUnit: isWholeSale ? wholesaleUnit : 0,
          retailPrice: !isWholeSale ? retailPrice : 0,
          buyingCount: 0,
          discount: 0,
        );
        await db_helper.updateItem(item);
        DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/items/$id");
        await ref.update(params);

        _image = null;
        stockCount = 0;
        category_controller.text = "";
        name_controller.text = "";
        description_controller.text = "";
        wholesale_unit_controller.text = "";
        price_controller.text = "";
        isWholeSale = false;
        showToast("Item updated");
        await widget.callback();
        Navigator.pop(context);
      }
      else {
        String category = category_controller.text.toString();
        String name = name_controller.text.toString();
        String desc = description_controller.text.toString();
        await _uploadImage();
        String image = _uploadedImageUrl;
        String id = DateTime.now().millisecondsSinceEpoch.toString();

        double wholesalePrice;
        double retailPrice;
        int wholesaleUnit;

        if (isWholeSale) {
          wholesalePrice = double.parse(price_controller.text.toString());
          wholesaleUnit = int.parse(wholesale_unit_controller.text.toString());
        }
        else {
          retailPrice = double.parse(price_controller.text.toString());
        }

        final params = {
          "id": id,
          "category": category,
          "itemName": name,
          "description": desc,
          "image": image,
          "isBuyingWholesale": "false",
          "wholesaleImage": image,
          "favorite": "false",
          "wholesalePrice": isWholeSale ? wholesalePrice : 0,
          "wholesaleUnit": isWholeSale ? wholesaleUnit : 0,
          "buyingCount": 0,
          "retailPrice": !isWholeSale ? retailPrice : 0,
          "discount": 0,
          "stockCount": stockCount,
        };

        Item item = Item(
          id: int.parse(id),
          stockCount: stockCount,
          itemName: name,
          description: desc,
          category: category,
          image: image,
          isBuyingWholesale: "false",
          wholesaleImage: image,
          favorite: "false",
          wholesalePrice: isWholeSale ? wholesalePrice : 0,
          wholesaleUnit: isWholeSale ? wholesaleUnit : 0,
          retailPrice: !isWholeSale ? retailPrice : 0,
          buyingCount: 0,
          discount: 0,
        );
        await db_helper.saveItem(item);

        DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/items/$id");
        await ref.set(params);

        _image = null;
        stockCount = 0;
        category_controller.text = "";
        name_controller.text = "";
        description_controller.text = "";
        wholesale_unit_controller.text = "";
        price_controller.text = "";
        isWholeSale = false;
        showToast("Item uploaded");
        Navigator.pop(context);
      }

      setState(() {
        isLoading = false;
      });
    }
    else {
      showToast("Add at least one stock");
    }
  }

}

class CategoryDialog extends StatefulWidget {

  List<Category> categoryList;
  BuildContext context;
  Function callback;

  CategoryDialog({
    this.categoryList,
    this.context,
    this.callback,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();

}

class _CategoryDialogState extends State<CategoryDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return CategoryAdapter2(category: widget.categoryList[index], callback: widget.callback, context: context,);
                },
                shrinkWrap: true,
                controller: ScrollController(),
                itemCount: widget.categoryList.length,
              )
            ),
            SizedBox(height: 16.0),
            Container(
              width: 80,
              height: 35,
              alignment: Alignment.center,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 20),
              child: MaterialButton(
                color: HexColor("#66906A"),
                onPressed: () {
                  Navigator.pop(widget.context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddCategoryDialog(categoryList: widget.categoryList, callback: callback,);
                    },
                  );
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                elevation: 5,
                child: const Text("Add new", style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'inter-medium',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> callback () async {
    setState(() {

    });
  }

}

class AddCategoryDialog extends StatefulWidget {

  List<Category> categoryList;
  Function callback;

  AddCategoryDialog({this.categoryList, this.callback});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();

}

class _AddCategoryDialogState extends State<AddCategoryDialog> {

  final TextEditingController _textEditingController = TextEditingController();
  File _image;
  String _uploadedImageUrl;

  var db_helper = DbHelper();

  Future<void> _uploadImage() async {
    // Upload image to Firebase Storage
    if (_image != null) {
      Reference storageReference =
      FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
      UploadTask uploadTask = storageReference.putFile(_image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  Future<void> saveCategory() async {
    String title = _textEditingController.text.toString().trim();
    if (title.isEmpty) {
      showToast("Title is required");
    }
    else {
      if (_image == null) {
        showToast("Image is required");
      }
      else {
        String id = DateTime.now().millisecondsSinceEpoch.toString();
        await _uploadImage();
        var cat = Category(id: int.parse(id), image: _uploadedImageUrl, title: title);
        final params = {
          "id": cat.id,
          "title": cat.title,
          "image": cat.image
        };
        await db_helper.saveCategory(cat);
        await widget.categoryList.add(cat);
        DatabaseReference ref = FirebaseDatabase.instance.ref().child("data/categories/$title");
        await ref.set(params);
        showToast("Category added");
        widget.callback();
        Navigator.pop(context);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Category name',
            ),
          ),
          SizedBox(height: 16.0),
          if (_image != null)
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(45)),
              ),
              child: Image.file(
                _image,
                height: 200,
              ),
            ),
          ElevatedButton(
            onPressed: _getImage,
            child: Text('Select Image'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saveCategory,
          child: Text('Save'),
        ),
      ],
    );
  }

}


