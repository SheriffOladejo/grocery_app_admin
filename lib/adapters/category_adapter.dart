import 'package:flutter/material.dart';
import 'package:grocery_app_admin/models/category.dart';

class CategoryAdapter extends StatefulWidget {

  Category category;
  Function callback;

  CategoryAdapter({this.category, this.callback});

  @override
  State<CategoryAdapter> createState() => _CategoryAdapterState();

}

class _CategoryAdapterState extends State<CategoryAdapter> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await widget.callback(widget.category.title);
      },
      child: Container(
        width: 55,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(45)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35.0), // Adjust the radius value as per your requirement
                child: widget.category.title == "all" ? Image.asset("assets/images/cat_all.png") : Image.network(
                  widget.category.image, // Replace with your image asset path
                  width: 70.0, // Adjust the width as per your requirement
                  height: 70.0, // Adjust the height as per your requirement
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(height: 10,),
            Text(
              widget.category.title.replaceRange(0, 1, widget.category.title.substring(0, 1).toUpperCase()),
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter-medium',
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
