import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/custom_date.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:sevenemirates/components/flashbar.dart';

import '../user/product_list.dart';
import '../user/product_view_screen.dart';

// import '../user/product_list.dart';
class PlacesScreen extends StatefulWidget {
  // List productList1 = [];
  var getProducts  ;
  String cid;  String sid;

  String lable='';
  double minPrice=0;
  double maxPrice=100000;
  String usage='';


  // int i = 0;

  PlacesScreen({
    Key? key,
    required this.getProducts,
    // required this.productList1,
    required this.cid
  ,this.sid='', this.minPrice=0,this.maxPrice=100000,this.lable='',this.usage='',
    // required this.i,
  });

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;

  String UserId = '', name = '', phone = '';
  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  List productList = [];
  int orderFilter = 0;
  Map data = Map();
  int itemCount = 0;

  List selectedSubCatList=[];
  String selectedSubCat='';
  String catid='';

  String mapAddress='';
  String mapLat='';
  String mapLng='';
  String mapCity='';
   @override
  void initState() {
    catid=widget.cid;
    // selectedSubCat=widget.sid;
    getSharedStore();
    super.initState();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserId = prefs.getString(Const.UID) ?? '';
      name = prefs.getString(Const.NAME) ?? '';
      phone = prefs.getString(Const.PHONE) ?? '';
      mapAddress = prefs.getString(Const.MAPADDRESS) ?? '';
      mapLat = prefs.getString(Const.MAPLAT) ?? '';
      mapLng = prefs.getString(Const.MAPLNG) ?? '';
      mapCity = prefs.getString(Const.MAPCITY) ?? '';

      mapAddress= Provider.of<AppSetting>(context, listen: false).mapAddress;
      mapLat= Provider.of<AppSetting>(context, listen: false).maplat;
      mapLng=  Provider.of<AppSetting>(context, listen: false).maplon;
      mapCity= Provider.of<AppSetting>(context, listen: false).mapCity;
      selectedSubCatList=selectedSubCat.split(',');
      apiTest('Sub Cat'+selectedSubCatList.toString());

      _getProducts(pageCount);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount = pageCount + 1;
          });
          _getProducts(pageCount);
        }
      });
    });
  }

  _getProducts(int pagenumber) async {

    showProgress = true;
    final response = await http.post(Uri.parse(Urls.ProductList), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "cid": catid,
      "sid": selectedSubCat,
      "minprice": widget.minPrice.toStringAsFixed(0),
      "maxprice": widget.maxPrice.toStringAsFixed(0),
      "lable": widget.lable,
      "usage": widget.usage,
      "ord": orderFilter.toString(),
      "page": pageCount.toString(),
    });
    data = json.decode(response.body);
    // List tempList = [];
    // for (int i = 0; i < data["productlist"].length; i++) {
    //
    //   tempList.add(data["productlist"][i]);
    //   // tempList.add(data["productlist"][i]);
    //   // productList.add(tempList);
    // }

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        apiTest(data.toString());
         productList.addAll(data["productlist"]);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }
  _reloadScreen(){
    // Navigator.pushReplacement(context, OpenScreen(widget: ProductList(cid: catid,sid: selectedSubCat,)));
    Navigator.pushReplacement(context, OpenScreen(widget: ProductListScreen(cid: catid,sid: selectedSubCat,)));
  }
   cardSubCatMenu(int i){
    return  GestureDetector(
      onTap: (){
        setState(() {

          if (selectedSubCatList.contains(Const.subcategoryList[i]["sc_id"].toString())) {
            selectedSubCatList.removeAt(selectedSubCatList.indexOf(Const.subcategoryList[i]["sc_id"].toString()));
          } else {
            selectedSubCatList.add(Const.subcategoryList[i]["sc_id"].toString());
          }



          selectedSubCat='';
          for(int j=0;j<selectedSubCatList.length;j++){
            selectedSubCat=selectedSubCat+selectedSubCatList[j].toString()+",";
          }

          if(selectedSubCat.length!=0){
            selectedSubCat=selectedSubCat.substring(0,selectedSubCat.length - 1);
          }
          _reloadScreen();


        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0,2,2,2),
        padding: EdgeInsets.fromLTRB(10,5,10,5),
        decoration: decoration_round((selectedSubCatList.contains(Const.subcategoryList[i]["sc_id"]))?TheamPrimary:Colors.grey.shade200,  3, 3, 3, 3),
        child: Text(Const.subcategoryList[i]['sc_title$cur_Lang'],style: ts_Regular(12, (selectedSubCatList.contains(Const.subcategoryList[i]["sc_id"]))?fc_bg:fc_3),),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 18,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          // Lang(" ${lable}  ", "${lable}  "),
          Lang(" CHOOSE AD TYPE  ", " اختر نوع الإعلان "),
          style: ts_Regular(15, fc_1),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            size: 15,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   color: Colors.transparent,
            //   width: Width(context),
            //   // margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
            //   padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
            //   //alignment: Alignment.center,
            //   child: Column(
            //     children: [
            //       Divider(
            //         color: Colors.white24,
            //         thickness: .5,
            //       ),
            //       SingleChildScrollView(
            //         scrollDirection: Axis.horizontal,
            //         child: Container(
            //           color: Colors.transparent,
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               for (int index =0 ;   index < productList.length-1;  index++)
            //               // for (int i = 0;   i < Const.subcategoryList.length && i < 7;  i++)
            //               // ...List.generate(productList.length,
            //               //     (index) =>
            //                       GestureDetector(
            //                       child: Container(
            //                         color: Colors.transparent,
            //                         padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            //                         margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            //                         child:
            //                             // Column(
            //                             //   children: [
            //                             // Image.network(
            //                             //        Urls.imageLocation +
            //                             //            Const.categoryList[i]["c_image"].toString(),
            //                             //        width: Width(context)/9,
            //                             //        height: Width(context)/9,
            //                             //        fit: BoxFit.fill,
            //                             //       ),
            //
            //                             // SizedBox(
            //                             //   height: 10,
            //                             // ),
            //                             Text(productList[index]["sc_title$cur_Lang"]
            //                               // Const.categoryList[1]["c_name$cur_Lang"]
            //                               .toString(),
            //                           style: ts_Bold(12, fc_6),
            //                           textAlign: TextAlign.center,
            //                           maxLines: 1,
            //                         ),
            //                         // Text(
            //                         //   Const.categoryList[1]["countproducts"]
            //                         //       .toString() +
            //                         //       ' ' +
            //                         //       Lang('items', 'عناصر'),
            //                         //   style: ts_Regular(11, Colors.black),
            //                         //   textAlign: TextAlign.center,
            //                         //   maxLines: 1,
            //                         // ),
            //                         //   ],
            //                         // ),
            //                       ),
            //                       onTap: () {
            //                         print(productList[index]['sc_id']);
            //                         print(productList[index]);
            //
            //                         // Navigator.push(
            //                         // context,
            //                         // OpenScreen(
            //                         //     widget: ProductListScreen(
            //                         //   cid: Const.categoryList[i]["c_id"],
            //                         // )));
            //                         // print('productList //${ Const.subcategoryList }');
            //                         // Navigator.push(
            //                         //     context,
            //                         //     OpenScreen(
            //                         //         widget: PlacesScreen(
            //                         //           getProducts: Const.subcategoryList,
            //                         //
            //                         //         )));
            //                       }),
            //               // GestureDetector(
            //               //     child: Container(
            //               //       padding:
            //               //       EdgeInsets.fromLTRB(0,0,0,0),
            //               //       margin:
            //               //       EdgeInsets.fromLTRB(0,0,0,0),
            //               //       alignment: Alignment.center,
            //               //       child: Container(
            //               //         margin: EdgeInsets.all(0),
            //               //         height: Width(context) * 0.12,
            //               //         width: Width(context) * 0.12,
            //               //         alignment: Alignment.center,
            //               //         decoration: decoration_round(
            //               //             TheamPrimary, 50,50,50,50),
            //               //         child: ClipRRect(
            //               //           borderRadius: BorderRadius.circular( 50),
            //               //           child: Text(
            //               //             Lang(" View all", "مشاهدة الكل "),
            //               //             style: ts_Regular(12, fc_bg),
            //               //             textAlign: TextAlign.center,
            //               //             maxLines: 2,
            //               //           ),
            //               //         ),
            //               //       ),
            //               //     ),
            //               //     onTap: () {
            //               //       Navigator.push(
            //               //           context, OpenScreen(widget: CategoryScreen()));
            //               //     }),
            //             ],
            //           ),
            //         ),
            //       ),
            //       Divider(
            //         color: Colors.white24,
            //         thickness: .5,
            //       ),
            //     ],
            //   ),
            // ),
            Container(
                width: Width(context),
                child:Row(

                  children: [
                    Expanded(child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          for(int k=0;k<Const.subcategoryList.length;k++)
                            if((selectedSubCatList.contains(Const.subcategoryList[k]["sc_id"])) )
                              cardSubCatMenu(k),

                          for(int i=0;i<Const.subcategoryList.length;i++)
                            if((catid==Const.subcategoryList[i]['c_id'] || catid=='') && !(selectedSubCatList.contains(Const.subcategoryList[i]["sc_id"])))
                              cardSubCatMenu(i)
                        ],
                      ),
                    ),),
                    // SizedBox(width:5,),
                    // GestureDetector(
                    //   onTap: (){
                    //     // _popShort(context);
                    //   },
                    //   child: Icon(
                    //     Icons.sort_rounded,
                    //     // size: sy(xl),
                    //     color: fc_1,
                    //   ),
                    // ),
                    // SizedBox(width:5,),

                  ],
                )
            ),


            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                    itemCount: productList.length,
                    // itemCount:  places.length,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // productItems = getProducts[i]['products'];

                      if ( productList.length != 0) {
                        return InkWell(
                          child: Card(color: Colors.white,
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  // color: Colors.red,
                                  color: Colors.transparent,

                                  width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Positioned(
                                      child: CustomImage(
                                        image: Urls.imageLocation +productList[index]["p_image"]
                                                .toString(),
                                        // image: places[index] ??
                                        //     '',
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                        top: 7,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                50,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.black
                                                    .withOpacity(.6)),
                                            child: IconButton(
                                                onPressed: () async {},
                                                icon: const Icon(
                                                    Icons.star_border_outlined,
                                                    size: 25),
                                                color: Colors.white))),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10, left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text( productList[index]
                                                      ["sc_title$cur_Lang"]

                                                  // Const.categoryList[1]["c_name$cur_Lang"]
                                                  .toString() + ' (' + productList[index]['p_quantity'] +") ",
                                              // Text('\$ 29.46649',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            // Text(
                                            //   'contact ✉️',
                                            //   style: TextStyle(
                                            //       fontWeight: FontWeight.w500,
                                            //       fontSize: 16),
                                            // ),
                                          ]),
                                      Text( productList[index]["c_detail$cur_Lang"]??'',
                                        // '8 Beds .9 Baths .631 sqm',
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(.7),
                                            fontSize: 15,
                                          // overflow: TextOverflow.ellipsis
                                           ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: ' ' +  productList[index]["p_address$cur_Lang"]??'',
                                              style: TextStyle(
                                                color: Colors.grey.withOpacity(.9),
                                                fontSize: 13,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ".   "+ productList[index]["p_city$cur_Lang"]??'',
                                              style: TextStyle(
                                                color: Colors.black.withOpacity(.7),
                                                fontSize: 15,
// overflow: TextOverflow.ellipsis
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                      // Text(
                                      //  productList[index]["p_city$cur_Lang"],
                                      //   // '8 Beds .9 Baths .631 sqm',
                                      //   style: TextStyle(
                                      //       color: Colors.black.withOpacity(.7),
                                      //       fontSize: 15,
                                      //     // overflow: TextOverflow.ellipsis
                                      //      ),
                                      // ),
                                      // Text(productList[index]["p_address$cur_Lang"],
                                      //   style: TextStyle(
                                      //       color: Colors.grey.withOpacity(.9),
                                      //       fontSize: 13,
                                      //       // overflow: TextOverflow.ellipsis
                                      //   ),
                                      // ),
                                      Text( productList[index]["l_name$cur_Lang"] ??
                                            '',
                                        style: ts_Regular(20, Colors.white),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    //p_lat: 30.629771547428714, p_lng: 31.07936605811119,
                                                  },
                                                  icon: const Icon(
                                                      Icons.location_on_outlined,
                                                      color: Colors.black)),
                                              Container(

                                                padding: EdgeInsets.only(
                                                    top: 20, bottom: 20),
                                                child: Text(
                                                  Lang('Location','المواقع'),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      overflow:
                                                          TextOverflow.ellipsis),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            CustomeDate.ago( productList[index]
                                            ["p_dated"]
                                                .toString()),
                                            style: ts_Regular(12, fc_5),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10,)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetails(product: null,)));

                            // Get.to(AreaDetailsScreen(
                            //     index: controller.places[index]));
                          },
                        );
                      }
                    })),
          ],
        ),
      ),
      // floatingActionButton:   Padding(
      //   padding:   EdgeInsets.only(bottom: 18.0),
      //   child: FloatingActionButton.extended(
      //       elevation: 50,
      //       backgroundColor:fc_3,
      //       autofocus: true,
      //       onPressed: () async {
      //         // await controller.addMarkers();
      //         // Get.to(AllPlacesMapScreen());
      //       },
      //       label: const Text('SHOW MAP'),
      //       icon: const Icon(Icons.location_on_outlined)),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

List places = [
  'https://img.jamesedition.com/listing_images/2022/01/31/14/38/36/966d469b-1385-4d5b-a4a2-694abaf8002f/je/760xxsxm.jpg',
  'https://img.jamesedition.com/listing_images/2022/01/31/14/38/36/966d469b-1385-4d5b-a4a2-694abaf8002f/je/760xxsxm.jpg',
  'https://img.jamesedition.com/listing_images/2022/01/31/14/38/36/966d469b-1385-4d5b-a4a2-694abaf8002f/je/760xxsxm.jpg',
  'https://img.jamesedition.com/listing_images/2022/01/31/14/38/36/966d469b-1385-4d5b-a4a2-694abaf8002f/je/760xxsxm.jpg',
];

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;

  const CustomImage(
      {this.image,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.placeholder = "assets/images/no_image.png"});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: CachedNetworkImage(
        imageUrl: image!,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CupertinoActivityIndicator(
              color: Colors.black,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
            "assets/images/no_image.png",
            height: height,
            width: width,
            fit: fit),
      ),
    );

  }
}
