import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/layout/product_card_community.dart';
import 'package:sevenemirates/layout/product_card_main.dart';
import 'package:sevenemirates/maps/map_screen.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/user/filter_screen.dart';
import 'package:sevenemirates/screen/user/product_view_screen.dart';
import 'package:sevenemirates/screen/user/search_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/bottom_navigation.dart';
import '../../components/widget_help.dart';

class ProductListScreen extends StatefulWidget {

  String cid;
  String sid;

  String lable='';
  double minPrice=0;
  double maxPrice=100000;
  String usage='';

  ProductListScreen(
      {Key? key,
      this.cid = '',this.sid='', this.minPrice=0,this.maxPrice=100000,this.lable='',this.usage=''})
      : super(key: key);
  @override
  _ProductListScreenState createState() {
    return _ProductListScreenState();
  }
}

class _ProductListScreenState extends State<ProductListScreen> with RelativeScale {
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
    super.initState();
    catid=widget.cid;
    selectedSubCat=widget.sid;
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
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
    List tempList = [];
    for (int i = 0; i < data["productlist"].length; i++) {
      tempList.add(data["productlist"][i]);
    }

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        apiTest(data.toString());
        productList.addAll(tempList);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initRelativeScaler(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: Provider.of<AppSetting>(context).appTheam,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection:
              Const.AppLanguage == 0 ? TextDirection.ltr : TextDirection.rtl,
          child: child!,
        );
      },
      home: Container(
        color: fc_bg,
        child: SafeArea(
        top: false,
        child: Scaffold(
          bottomNavigationBar:  BottomNavigationWidget(ishome: false,mcontext: context,order: 2),
          key: _scaffoldKey,
          //   resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            backgroundColor: fc_bg_mild,
            centerTitle: true,
            leading:IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              icon:Icon(
                Icons.arrow_back,
                size: sy(xl),
                color: fc_1,
              ),
            ),
            title: Text(WidgetHelp.getNameFromId(widget.cid, Const.categoryList, 'c_id', 'c_name'),
              style: ts_Bold(sy(l), fc_1),
            ),
            actions: [
              Container(
                margin: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, OpenScreen(widget: FilterScreen(cid: widget.cid,sid: widget.sid,minPrice: widget.minPrice,maxPrice: widget.maxPrice,lable: widget.lable,usage: widget.usage,)));
                      },
                      child:Container(
                        padding: EdgeInsets.fromLTRB(sy(8), sy(3), sy(8), sy(3)),
                        decoration: decoration_round((widget.lable!='' || widget.usage!='' || widget.minPrice.toStringAsFixed(0)!='0'|| widget.maxPrice.toStringAsFixed(0)!='100000')?Colors.green.shade200:Colors.grey.shade200, sy(3), sy(3), sy(3), sy(3)),
                        child: Text(Lang("Filter  ", "فلتر"),style: ts_Regular(sy(n-1), fc_2),),
                      )
                  ),
                ),
              )
            ],
            titleSpacing: 0,
            elevation: 0,
          ),
          body: Container(
            color: fc_bg_mild,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: _screenBody(),
                  top: sy(0) ,
                  left: 0,
                  right: 0,
                  bottom: sy(0),
                ),


                // Positioned(
                //   bottom: 0,
                //   left: 0,
                //   right: 0,
                //   child: topFIlters(),)
                //  MyProgressLayout(showProgress),
              ],
            ),
          ),
        ),
      ),
    ),
      );
  }

  _topBars(){
    return Container(
      margin: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
      child: Column(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(sy(3)),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sy(3)),
              elevation: 1,
              child: Container(
                height: sy(28),
                width: Width(context),
                child: Row(
                  children: [

                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _openMap();
                        });
                      },
                      child: Container(
                          height: sy(28),
                          color: TheamPrimary,
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.place,size: sy(n),color: fc_bg,),
                              SizedBox(width: sy(5),),
                              Text(mapCity==''?Lang(" Select City ", "اختر مدينة  "):mapCity,style: ts_Regular(sy(n-1), fc_bg),),
                            ],
                          )
                      ),
                    ),
                    SizedBox(width: sy(5),),
                    Expanded(child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: (){
                        Navigator.push(context, OpenScreen(widget: SearchScreen()));
                      },
                      child: Container(
                          height: sy(28),
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(Lang(" Search ", " بحث "),style: ts_Regular(sy(n-1), Colors.grey.shade400),),
                              Spacer(),
                              Icon(Icons.search,size: sy(l+1),color: Colors.grey.shade400,),
                            ],
                          )
                      ),
                    )),


                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: sy(5),),
          Container(
            width: Width(context),
            child:Row(
              children: [
                Expanded(child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:  Row(
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
                SizedBox(width: sy(5),),
                GestureDetector(
                  onTap: (){
                    _popShort(context);
                  },
                  child: Icon(
                    Icons.sort_rounded,
                    size: sy(xl),
                    color: fc_1,
                  ),
                ),
                SizedBox(width: sy(2),),

              ],
            )
          )

        ],
      ),
    );
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
        margin: EdgeInsets.fromLTRB(sy(0), sy(2), sy(5), sy(2)),
        padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
        decoration: decoration_round((selectedSubCatList.contains(Const.subcategoryList[i]["sc_id"]))?TheamPrimary:Colors.grey.shade200, sy(3), sy(3), sy(3), sy(3)),
        child: Text(Const.subcategoryList[i]['sc_title$cur_Lang'],style: ts_Regular(sy(s), (selectedSubCatList.contains(Const.subcategoryList[i]["sc_id"]))?fc_bg:fc_3),),
      ),
    );
  }
  _screenBody() {
    return Container(
      width: Width(context),
      height: Height(context),
      child: Column(
        children: [
          _topBars(),
          Expanded(child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            child: Container(
              color: fc_bg_mild,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // filterAndCount(),
                  SizedBox(
                    height: sy(5),
                  ),
                  if (productList.length != 0) productItems(),
                  if (productList.length == 0 && showProgress == false) emptyCart(),

                  if (showProgress == true)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: sy(40),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: sy(15),
                        height: sy(15),
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                            new AlwaysStoppedAnimation<Color>(TheamPrimary)),
                      ),
                    ),
                  SizedBox(
                    height: sy(40),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  productItems() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: AnimationLimiter(
        child: Wrap(
          direction: Axis.horizontal,
          //   spacing: sy(2),
          runSpacing: sy(3),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width / 2,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              for (var i = 0; i < productList.length; i++)
                Container(
                  margin: EdgeInsets.fromLTRB(sy(7), sy(2), sy(7), sy(3)),
                  child:  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          OpenScreen(
                              widget: ProductViewScreen(
                                pid:productList[i]["p_id"],
                                pname:productList[i]["p_title"],
                                pimage:productList[i]["p_image"],
                              )));
                    },
                    style: elevatedButtonTrans(),
                    child:
                    (productList[i]['c_id']!=Const.COMMUNITY_ID && productList[i]['c_id']!=Const.JOBS_ID)?
                    ProductCardMain(i: i, getProducts: productList):
                    ProductCardCommunityMain(i: i, getProducts: productList,mcontext: context,),

                  ),
                ),


            ],
          ),
        ),
      ),
    );
  }

  _popShort(BuildContext mcontext) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(0))),
        context: mcontext,
        builder: (mcontext) {
          return StatefulBuilder(
            builder: (mcontext, setState) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: sy(35),
                    child: ListTile(
                      tileColor: fc_bg,
                      title: Text(
                        Lang("Sort By", "ترتيب حسب"),
                        textAlign: TextAlign.left,
                        style: ts_Bold(sy(l), Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    top: sy(35.5),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(mcontext).size.width,
                        color: fc_bg,
                        child: Wrap(
                          runSpacing: sy(2),
                          children: <Widget>[
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.all_inbox,
                                size: sy(xl),
                                color: fc_1,
                              ),
                              title: Text(
                                Lang('Default order', 'ترتيب افتراضي'),
                                style: ts_Regular(sy(n), fc_1),
                              ),
                              trailing: Container(
                                width: sy(15),
                                height: sy(15),
                                decoration: decoration_border(
                                    (orderFilter == 0)
                                        ? TheamPrimary
                                        : Colors.white,
                                    TheamPrimary,
                                    sy(1),
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                child: Container(
                                  width: sy(5),
                                  height: sy(5),
                                  decoration: decoration_border(
                                      Colors.white,
                                      Colors.white,
                                      sy(1),
                                      sy(10),
                                      sy(10),
                                      sy(10),
                                      sy(10)),
                                ),
                              ),
                              onTap: () {
                                _setShort(0);
                              },
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.new_releases_outlined,
                                size: sy(xl),
                                color: fc_1,
                              ),
                              title: Text(
                                Lang("Latest Post  ", "أحدث مشاركة  "),
                                style: ts_Regular(sy(n), fc_1),
                              ),
                              trailing: Container(
                                width: sy(15),
                                height: sy(15),
                                decoration: decoration_border(
                                    (orderFilter == 1)
                                        ? TheamPrimary
                                        : Colors.white,
                                    TheamPrimary,
                                    sy(1),
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                child: Container(
                                  width: sy(5),
                                  height: sy(5),
                                  decoration: decoration_border(
                                      Colors.white,
                                      Colors.white,
                                      sy(1),
                                      sy(10),
                                      sy(10),
                                      sy(10),
                                      sy(10)),
                                ),
                              ),
                              onTap: () {
                                _setShort(1);
                              },
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.star_border,
                                size: sy(xl),
                                color: fc_1,
                              ),
                              title: Text(
                                Lang('Popularity', 'شعبية'),
                                style: ts_Regular(sy(n), fc_1),
                              ),
                              trailing: Container(
                                width: sy(15),
                                height: sy(15),
                                decoration: decoration_border(
                                    (orderFilter == 2)
                                        ? TheamPrimary
                                        : Colors.white,
                                    TheamPrimary,
                                    sy(1),
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                child: Container(
                                  width: sy(5),
                                  height: sy(5),
                                  decoration: decoration_border(
                                      Colors.white,
                                      Colors.white,
                                      sy(1),
                                      sy(10),
                                      sy(10),
                                      sy(10),
                                      sy(10)),
                                ),
                              ),
                              onTap: () {
                                _setShort(2);
                              },
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.remove_red_eye_outlined,
                                size: sy(xl),
                                color: fc_1,
                              ),
                              title: Text(
                              Lang('Most visited', 'الأكثر زيارة'),
                                style: ts_Regular(sy(n), fc_1),
                              ),
                              trailing: Container(
                                width: sy(15),
                                height: sy(15),
                                decoration: decoration_border(
                                    (orderFilter == 3)
                                        ? TheamPrimary
                                        : Colors.white,
                                    TheamPrimary,
                                    sy(1),
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                child: Container(
                                  width: sy(5),
                                  height: sy(5),
                                  decoration: decoration_border(
                                      Colors.white,
                                      Colors.white,
                                      sy(1),
                                      sy(10),
                                      sy(10),
                                      sy(10),
                                      sy(10)),
                                ),
                              ),
                              onTap: () {
                                _setShort(3);
                              },
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.trending_up,
                                size: sy(xl),
                                color: fc_1,
                              ),
                              title: Text(
                                   Lang('Price - Low to High',
                                    'السعر - من الأقل إلى الأعلى'),
                                style: ts_Regular(sy(n), fc_1),
                              ),
                              trailing: Container(
                                width: sy(15),
                                height: sy(15),
                                decoration: decoration_border(
                                    (orderFilter == 4)
                                        ? TheamPrimary
                                        : Colors.white,
                                    TheamPrimary,
                                    sy(1),
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                child: Container(
                                  width: sy(5),
                                  height: sy(5),
                                  decoration: decoration_border(
                                      Colors.white,
                                      Colors.white,
                                      sy(1),
                                      sy(10),
                                      sy(10),
                                      sy(10),
                                      sy(10)),
                                ),
                              ),
                              onTap: () {
                                _setShort(4);
                              },
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.trending_down,
                                size: sy(xl),
                                color: fc_1,
                              ),
                              title: Text(
                                   Lang('Price - High to Low',
                                    'السعر الاعلى الى الأقل'),
                                style: ts_Regular(sy(n), fc_1),
                              ),
                              trailing: Container(
                                width: sy(15),
                                height: sy(15),
                                decoration: decoration_border(
                                    (orderFilter == 5)
                                        ? TheamPrimary
                                        : Colors.white,
                                    TheamPrimary,
                                    sy(1),
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                child: Container(
                                  width: sy(5),
                                  height: sy(5),
                                  decoration: decoration_border(
                                      Colors.white,
                                      Colors.white,
                                      sy(1),
                                      sy(10),
                                      sy(10),
                                      sy(10),
                                      sy(10)),
                                ),
                              ),
                              onTap: () {
                                _setShort(5);
                              },
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  _setShort(int getval) {
    setState(() {
      orderFilter = getval;
      Navigator.of(context).pop(true);
      pageCount = 1;
      productList.clear();
      _getProducts(pageCount);
    });
  }

  emptyCart() {
    return Container(
      color: fc_bg_mild,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: sy(50),
          ),
          Image.asset(
            'assets/images/emptyimg.png',
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          SizedBox(
            height: sy(10),
          ),
          Text(
            Lang('No items found', 'لم يتم العثور على العناصر'),
            style: ts_Regular(sy(n), fc_1),
          ),
        ],
      ),
    );
  }

  _reloadScreen(){
    Navigator.pushReplacement(context, OpenScreen(widget: ProductListScreen(cid: catid,sid: selectedSubCat,)));
  }



  Future _openMap() async {
    var location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }else{
        _openMap();
      }
    }else{
      Map results=Map();
      try{
        results = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapScreen()));;
        if (results != null  ) {
          setState(() {

            mapAddress=results['address'].toString();
            mapLat=results['lat'].toString();
            mapLng=results['long'].toString();
            mapCity=results['city'].toString();

            SharedStoreUtils.setValue(Const.MAPADDRESS, results['address'].toString());
            SharedStoreUtils.setValue(Const.MAPLAT, results['lat'].toString());
            SharedStoreUtils.setValue(Const.MAPLNG, results['long'].toString());
            SharedStoreUtils.setValue(Const.MAPCITY, results['city'].toString());

            Provider.of<AppSetting>(context, listen: false).mapAddress=mapAddress;
            Provider.of<AppSetting>(context, listen: false).maplat=mapLat;
            Provider.of<AppSetting>(context, listen: false).maplon=mapLng;
            Provider.of<AppSetting>(context, listen: false).mapCity=mapCity;
            _reloadScreen();
          });
        }
      }catch(e){
        print('cancel');
      }
    }

  }




}

