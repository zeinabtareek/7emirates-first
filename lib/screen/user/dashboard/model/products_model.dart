class ProductList {
  bool success;
  List<Product> productlist;

  ProductList({required this.success, required this.productlist});

  factory ProductList.fromJson(Map<String, dynamic> json) {
    var productListJson = json['productlist'] as List;
    List<Product> products = productListJson.map((productJson) => Product.fromJson(productJson)).toList();
    return ProductList(
      success: json['success'],
      productlist: products,
    );
  }
}

class Product {
  String pId;
  String uId;
  String cId;
  String scId;
  String code;
  String lId;
  String pTitle;
  String pType;
  String pDetail;
  String pImage;
  String pMrp;
  String pSell;
  String pUsed;
  String pUnit;
  String pUnitArab;
  String pQuantity;
  String pMultiQuantity;
  String pSingleBuy;
  String pLat;
  String pLng;
  String pAddress;
  String pCity;
  String complete;
  String likes;
  String views;
  String pRating;
  String pCount;
  String pPaid;
  String pExpire;
  String pStatus;
  String name;
  String phone;
  String pDated;

  Product({
    required this.pId,
    required this.uId,
    required this.cId,
    required this.scId,
    required this.code,
    required this.lId,
    required this.pTitle,
    required this.pType,
    required this.pDetail,
    required this.pImage,
    required this.pMrp,
    required this.pSell,
    required this.pUsed,
    required this.pUnit,
    required this.pUnitArab,
    required this.pQuantity,
    required this.pMultiQuantity,
    required this.pSingleBuy,
    required this.pLat,
    required this.pLng,
    required this.pAddress,
    required this.name,
    required this.phone,
    required this.pCity,
    required this.complete,
    required this.likes,
    required this.views,
    required this.pRating,
    required this.pCount,
    required this.pPaid,
    required this.pExpire,
    required this.pStatus,
    required this.pDated,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pId: json['p_id']??'',
      uId: json['u_id']??'',
      cId: json['c_id']??'',
      scId: json['sc_id']??'',
      code: json['code']??'',
      lId: json['l_id']??'',
      pTitle: json['p_title']??'',
      pType: json['p_type']??'',
      pDetail: json['p_detail']??'',
      pImage: json['p_image']??'',
      pMrp: json['p_mrp']??'',
      pSell: json['p_sell']??'',
      pUsed: json['p_used']??'',
      pUnit: json['p_unit']??'',
      pUnitArab: json['p_unit_arab']??'',
      pQuantity: json['p_quantity']??'',
      pMultiQuantity: json['p_multi_quantity']??'',
      pSingleBuy: json['p_single_buy']??'',
      pLat: json['p_lat']??'',
      pLng: json['p_lng']??'',
      pAddress: json['p_address']??'',
      pCity: json['p_city']??'',
      complete: json['complete']??'',
      likes: json['likes']??'',
      name: json['name']??'',
      phone: json['phone']??'',
      views: json['views']??'',
      pRating: json['p_rating']??'',
      pCount: json['p_count']??'',
      pPaid: json['p_paid']??'',
      pExpire: json['p_expire']??'',
      pStatus: json['p_status']??'',
      pDated: json['p_dated']??'',
    );
  }
}