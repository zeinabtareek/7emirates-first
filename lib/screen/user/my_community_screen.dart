import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/screen/user/store_product_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/relative_scale.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/currency_convert.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';

class MyCommunityScreen extends StatefulWidget {
  @override
  _MyCommunityScreenState createState() => _MyCommunityScreenState();
}

class _MyCommunityScreenState extends State<MyCommunityScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  Map data = Map();
  List productList = [];
  String phone = '',
      uId = '',
      ProfilePic = '',
      Name = '',
      vendorType = '',
      vendor = '',
      stage = '0';
  int currentTabIndex = 0;
  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = prefs.getString(Const.PHONE) ?? '';
      uId = prefs.getString(Const.UID) ?? '';
      Name = prefs.getString(Const.NAME) ?? '';
      ProfilePic = prefs.getString(Const.PROFILE) ?? '';
    });

    _myProducts();

  }

  _myProducts() async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.UserCommunity),
        headers: {
          HttpHeaders.acceptHeader: Const.POSTHEADER
        },
        body: {
          "key": Const.APPKEY,
          "phone": phone,
          "uid": uId,
        });
    data = json.decode(response.body);


    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        productList=data['products'];
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _liveStatus(int itemIndex, String pid, String val) async {
    apiTest(pid);
    showProgress = true;
    final response =
        await http.post(Uri.parse(Urls.ChangeProductStatus), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": pid,
      "val": val.toString(),
    });
    data = json.decode(response.body);
    debugPrint("Request--" + data["sql"].toString());
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        productList[itemIndex]['p_status'] = val;
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: Scaffold(
              key: _scaffoldKey,
              //   resizeToAvoidBottomPadding: false,
              bottomNavigationBar: BottomNavigationWidget(mcontext: context,ishome: false,order: 0,),
              body: Stack(
                children: <Widget>[
                  _screenBody(),
                ],
              )),
        ),
      ),
    );
  }

  _screenBody() {
    return Container(
      width: Width(context),
      height: Height(context),
      color: fc_bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          titlebar(),
          Expanded(child:Container(
            width: Width(context),
            color: fc_bg_mild,
            child:  SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Container(
                width: Width(context),
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if(showProgress==true)LoadingPlacement(width: Width(context), height:  Width(context)),
                    if (productList.length == 0 && showProgress!=true) emptyCart(),
                    if (productList.length != 0) productListing(),
                    SizedBox(
                      height: sy(80),
                      width: 50,
                    )
                  ],
                ),
              ),
            ),
          ))

        ],
      ),
    );
  }

  titlebar() {
    return Container(
      width: Width(context),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sy(3),),
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: sy(l),
              color: fc_1,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          SizedBox(height: sy(3),),
          Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                Lang("Your Community  ", "مجتمعك  "),
                  style: ts_Bold(sy(xl), fc_1),
                ),
                SizedBox(
                  height: sy(5),
                ),
                Text(
                  Lang(" Let host your service ", " دعنا نستضيف خدمتك "),
                  style: ts_Bold(sy(xl), fc_1),
                ),
                SizedBox(
                  height: sy(10),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  productListing() {
    return AnimationLimiter(
      child: SingleChildScrollView(
        child: Wrap(
          verticalDirection: VerticalDirection.down,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              for (var i = 0; i < productList.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _productViewOption(productList[i]["p_id"].toString(),
                          productList[i]["c_id"].toString());
                    },
                    child: getProductItem(i),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  getProductItem(int i) {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(5), sy(3), sy(3), sy(3)),
      child:  Container(
        padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
        decoration:
        decoration_round(fc_bg, sy(3), sy(3), sy(3), sy(3)),
        child:  Container(

          height: Width(context) * 0.32,
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration:
                  decoration_round(fc_bg, sy(0), sy(0), sy(0), sy(0)),
                  //  padding: EdgeInsets.all(sy(1)),

                  width: Width(context) * 0.27,
                  height: Width(context) * 0.30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sy(0)),
                    child: CustomeImageView(
                      image: Urls.imageLocation +
                          productList[i]["p_image"].toString(),
                      placeholder: Urls.DummyImageBanner,
                      fit: BoxFit.cover,
                      blurBackground: false,
                      height: Width(context) * 0.30,
                      width: Width(context) * 0.2,
                      radius: sy(2),
                    ),
                  )),
              SizedBox(
                width: sy(8),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            productList[i]["p_title"].toString(),
                            style: ts_Bold(sy(n), fc_3),
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        Text(
                          CustomeDate.ago(productList[i]["p_dated"].toString()),
                          style: ts_Regular(sy(s), fc_5),
                        ),
                      ],
                    ),

                    SizedBox(height: sy(5),),
                    Text(
                      productList[i]["p_detail"].toString(),
                      style: ts_Regular(sy(s), fc_4),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sy(3),),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                            decoration: decoration_round(Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                            child:  Text(
                              productList[i]["c_name"].toString(),
                              style: ts_Regular(sy(s-1), fc_5),
                              maxLines: 1,
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.fromLTRB(sy(1), 0, sy(1), 0),
                            child: Icon(Icons.arrow_right,size: sy(n),color: fc_5,),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                            decoration: decoration_round(Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                            child: Text(
                              productList[i]["sc_title"].toString(),
                              style: ts_Regular(sy(s-1), fc_5),
                              maxLines: 1,
                            ),
                          ),

                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(child: Text(
                          PriceUtils.convert(productList[i]["p_sell"].toString()),
                          style: ts_Bold(sy(n), fc_2),
                        ),),
                        Text(
                          getLableText(productList[i]['p_status'].toString()),
                          style: ts_Regular(
                              sy(s),
                              (productList[i]['p_status'].toString() == 'A')
                                  ? Colors.green[500]
                                  : Colors.red[500]),
                        ),
                        Switch(
                          value:
                          statusCheck(productList[i]['p_status'].toString()),
                          onChanged: (val) {
                            if (productList[i]['p_status'].toString() == 'A') {
                              _showStatusOption(
                                  i, productList[i]['p_id'].toString());
                            } else {
                              _liveStatus(
                                  i, productList[i]['p_id'].toString(), 'A');
                            }
                          },
                          activeColor: Colors.green,
                          activeTrackColor: Colors.lightGreenAccent,
                          inactiveThumbColor: Colors.grey[300],
                          inactiveTrackColor: Colors.grey[500],
                        )
                      ],
                    ),


                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );


  }

  getLableText(String status) {
    if (status == 'A') {
      return Lang('In Stock', 'في المخزن');
    } else if (status == 'D') {
      return Lang('Hidden', 'مخفي');
    } else {
      return Lang('Out of stock', 'غير متوفر بالمخزن');
    }
  }

  bool statusCheck(String status) {
    if (status == 'A') {
      return true;
    } else {
      return false;
    }
  }

  _showStatusOption(int index, String pid) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Wrap(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(sy(20), sy(10), sy(5), sy(5)),
                    alignment: Alignment.centerLeft,
                    child: Text(
                        Lang('Please select your type',
                            "الرجاء تحديد النوع الخاص بك"),
                        style: ts_Regular(sy(12), Colors.black),
                        textAlign: TextAlign.left)),
                Divider(),
                ListTile(
                    leading: Icon(Icons.visibility_off),
                    title: Text(Lang('Hide', 'إخفاء')),
                    subtitle: Text(Lang(
                        'This will hide the product from the store.',
                        "سيؤدي هذا إلى إخفاء المنتج من المتجر")),
                    onTap: () =>
                        {Navigator.pop(context), _liveStatus(index, pid, 'D')}),
                ListTile(
                    leading: Icon(Icons.block),
                    title: Text(Lang('Out of stock', 'غير متوفر بالمخزن')),
                    subtitle: Text(Lang(
                        'This product will be shown on the store but as out of stock.',
                        "سيتم عرض هذا المنتج في المتجر ولكنه غير متوفر بالمخزن ")),
                    onTap: () =>
                        {Navigator.pop(context), _liveStatus(index, pid, 'O')}),
                SizedBox(
                  height: sy(10),
                )
              ],
            ),
          );
        });
  }


  emptyCart() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: sy(30),
          ),
          Image.asset(
            'assets/images/emptyimg.png',
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
          ),
          SizedBox(
            height: sy(10),
          ),
          Text(
                 Lang(" No service found ", " لا توجد خدمة ") ,
            style: ts_Regular(sy(n), fc_2),
          ),
        ],
      ),
    );
  }

  _productViewOption(String pid, String cid) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Wrap(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(sy(20), sy(10), sy(5), sy(5)),
                    alignment: Alignment.centerLeft,
                    child: Text(
                        Lang('Please select your choice',
                            "الرجاء تحديد اختيارك"),
                        style: ts_Regular(sy(12), Colors.black),
                        textAlign: TextAlign.left)),
                Divider(),
                ListTile(
                    leading: Icon(Icons.remove_red_eye),
                    title: Text(Lang('View product', 'عرض المنتج')),
                    onTap: () => {
                          Navigator.pop(context),

                             Navigator.push(context, OpenScreen(widget: StoreProductViewScreen(pid: pid,pimage: '',pname: 'Loading',))),
                        }),
                ListTile(
                    leading: Icon(Icons.edit),
                    title: Text(Lang('Edit Product', 'تعديل المنتج')),
                    onTap: () => {
                          Navigator.pop(context),
                        //  Navigator.pushReplacement(context, OpenScreen(widget: EditProductScreen(pid: pid, cid: cid,))),
                        }),
                SizedBox(
                  height: sy(10),
                )
              ],
            ),
          );
        });
  }
}
