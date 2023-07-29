import 'package:flutter/material.dart';
import 'package:grocery_app_admin/models/category.dart';

class CategoryAdapter2 extends StatefulWidget {

  Category category;
  Function callback;
  BuildContext context;
  CategoryAdapter2({
    this.category,
    this.callback,
    this.context
  });

  @override
  State<CategoryAdapter2> createState() => _CategoryAdapter2State();

}

class _CategoryAdapter2State extends State<CategoryAdapter2> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await widget.callback(widget.category.title);
        Navigator.pop(widget.context);
      },
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        elevation: 3,
        child: Container(
          width: MediaQuery.of(context).size.width - 25,
          margin: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(45)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35.0), // Adjust the radius value as per your requirement
                  child: widget.category.title == "all" ? Image.asset("assets/images/cat_all.png") :  Image.network(
                    widget.category.image, // Replace with your image asset path
                    width: 70.0, // Adjust the width as per your requirement
                    height: 70.0, // Adjust the height as per your requirement
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(width: 15,),
              Text(
                widget.category.title,
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
      ),
    );
  }

}
