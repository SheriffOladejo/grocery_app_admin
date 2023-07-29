class Item {

  int stockCount;
  int id;

  String itemName;
  String description;
  String category;
  String image;
  String isBuyingWholesale;
  String wholesaleImage;
  String favorite;

  double wholesalePrice;
  int wholesaleUnit;
  int buyingCount;
  double retailPrice;
  double discount;

  Item({
    this.id,
    this.isBuyingWholesale,
    this.wholesaleImage,
    this.stockCount,
    this.itemName,
    this.category,
    this.description,
    this.image,
    this.buyingCount,
    this.discount,
    this.wholesaleUnit,
    this.wholesalePrice,
    this.retailPrice,
    this.favorite,
  });

}