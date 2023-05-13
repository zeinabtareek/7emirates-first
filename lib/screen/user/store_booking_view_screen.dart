import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/screen/user/chat_screen.dart';
import 'package:sevenemirates/screen/user/store_booking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/relative_scale.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/currency_convert.dart';
import '../../utils/style_sheet.dart';
import '../../utils/translation_widget.dart';
import '../../utils/urls.dart';

class StoreBookingViewScreen extends StatefulWidget {
  String oid = '';
  StoreBookingViewScreen({Key? key, this.oid = ''}) : super(key: key);
  @override
  _StoreBookingViewScreenState createState() => _StoreBookingViewScreenState();
}

class _StoreBookingViewScreenState extends State<StoreBookingViewScreen>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  Map data = Map();
  List ordersDetail = [];
  String phone = '', uId = '', ProfilePic = '', Name = '';
  // ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  TextEditingController ETaddress = TextEditingController();
  late GoogleMapController _Mapcontroller;

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
    final response =
        await http.post(Uri.parse(Urls.StoreBookingView), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "oid": widget.oid,
    });
    data = json.decode(response.body);

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        ordersDetail = data['orders'];
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _updateOrderStatus(String val, String dated) async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.UpdateOrder), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId.toString(),
      "val": val.toString(),
      "actiondate": dated.toString(),
      "oid": widget.oid.toString()
    });
    data = json.decode(response.body);

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        Navigator.pushReplacement(
            context,
            OpenScreen(
                widget: StoreBookingViewScreen(
              oid: widget.oid,
            )));
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
//    debugPrint("category --" + productList.toString());
  }

  popWarning(BuildContext context, String lable, String val, String datelable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Lang('Proceed to ', 'الشروع في ') + lable,
          style: ts_Bold(sy(l), fc_1),
          textAlign: TextAlign.left,
        ),
        content: Text(
          Lang(
              'Are you sure want to proceed action?. You cannot revit back once it confirmed',
              'هل أنت متأكد أنك تريد المضي قدما في العمل ؟. لا يمكنك العودة مرة أخرى بمجرد تأكيدها'),
          style: ts_Regular(sy(n), fc_2),
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              child: Text(
                Lang("Later", "لاحقا"),
                style: ts_Regular(sy(l), fc_3),
              ),
              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(false);
              _updateOrderStatus(val, datelable);
            },
            child: Container(
              child: Text(
                lable,
                style: ts_Regular(sy(l), fc_1),
              ),
              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initRelativeScaler(context);
    return WillPopScope(
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: Provider.of<AppSetting>(context).appTheam,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme,
            builder: (context, child) {
              return Directionality(
                textDirection: Const.AppLanguage == 0
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: child!,
              );
            },
            home: Container(
              color: fc_bg,
              child: SafeArea(
                child: ScaffoldMessenger(
                  key: _scaffoldKey,
                  child: Scaffold(
                      //   resizeToAvoidBottomPadding: false,
                      bottomNavigationBar:
                          (ordersDetail.length != 0) ? bottomButton() : null,
                      body: Stack(
                        children: <Widget>[
                          _screenBody(),
                        ],
                      )),
                ),
              ),
            )),
        onWillPop: () => _backBtn());
  }

  _backBtn() {
    Navigator.pushReplacement(
        context, OpenScreen(widget: StoreBookingScreen()));
  }

  _screenBody() {
    return Container(
      width: Width(context),
      height: Height(context),
      color: fc_bg_mild,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titlebar(),
          Expanded(
              child: Container(
            width: Width(context),
            color: fc_bg_mild,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Container(
                width: Width(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (showProgress == true)
                      LoadingPlacement(
                          width: Width(context), height: Width(context)),
                    if (ordersDetail.length != 0) orderWidget(),
                    SizedBox(
                      height: sy(20),
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
          SizedBox(
            height: sy(3),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: sy(l),
              color: fc_1,
            ),
            onPressed: () {
              _backBtn();
            },
          ),
          SizedBox(
            height: sy(3),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "#7EB0${widget.oid}",
                  style: ts_Bold(sy(xl), fc_1),
                ),
                SizedBox(
                  height: sy(5),
                ),
                Text(
                  Lang("Your Order  ", "طلبك  "),
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

  orderWidget() {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomeImageView(
            image: Urls.imageLocation + ordersDetail[0]['p_image'],
            width: Width(context),
            height: Width(context) * .5,
            radius: sy(10),
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: sy(10),
          ),
          TranslationWidget(
            message: ordersDetail[0]['p_title'],
            style: ts_Bold(sy(l), fc_2),
          ),
          SizedBox(
            height: sy(3),
          ),
          Text(
            '7EP0' + ordersDetail[0]['p_id'],
            style: ts_Regular(sy(n), fc_3),
          ),
          SizedBox(
            height: sy(3),
          ),
          Row(
            children: [
              TranslationWidget(
                message: ordersDetail[0]['varname'] ?? '',
                style: ts_Regular(sy(n), fc_2),
              ),
              SizedBox(
                width: sy(10),
              ),
              if (ordersDetail[0]['color'] != null)
                Container(
                  height: sy(10),
                  width: sy(10),
                  decoration: decoration_border(
                      Color(int.parse("0xFF" + ordersDetail[0]['color'])),
                      Colors.transparent,
                      4,
                      3,
                      3,
                      3,
                      3),
                ),
              if (ordersDetail[0]['color'] == null)
                TranslationWidget(
                  message: ordersDetail[0]['varname'] ?? '',
                  style: ts_Regular(sy(n), fc_2),
                ),
              Spacer(),
              cardOrderStatus(ordersDetail[0]['method']),
              SizedBox(
                width: sy(5),
              ),
              cardOrderStatus(ordersDetail[0]['o_status'])
            ],
          ),
          actionButton(),
          divLine(sy(10), sy(10)),
          addressBlock(),
          SizedBox(
            height: sy(10),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(sy(5), sy(10), sy(5), sy(5)),
            decoration: decoration_round(fc_bg, sy(10), sy(10), sy(10), sy(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                  child: Text(
                    Lang(" Order Summary ", "ملخص الطلب  "),
                    style: ts_Bold(sy(n), fc_2),
                  ),
                ),
                SizedBox(
                  height: sy(3),
                ),
                cardMoreDetail(Lang("Method  ", " طريقة "),
                    ordersDetail[0]['method'].toString()),
                cardMoreDetail(
                    Lang(" Order ", " طلب "),
                    CustomeDate.datedaymonth(
                        ordersDetail[0]['o_dated'].toString())),
                cardMoreDetail(Lang("Price  ", "سعر  "),
                    PriceUtils.convert(ordersDetail[0]['price'].toString())),
                cardMoreDetail(Lang(" Quantity ", "كمية  "),
                    ordersDetail[0]['quantity'].toString() + ' ' + 'items'),
                cardMoreDetail(
                    Lang(" Tax (5%) ", " الضريبة (5٪) "),
                    '+ ' +
                        PriceUtils.convert(ordersDetail[0]['tax'].toString())),
                SizedBox(
                  height: sy(3),
                ),
                cardMoreDetail(
                    Lang(" TOTAL PRICE ", " السعر الكلي "),
                    PriceUtils.convert(
                        ordersDetail[0]['total_price'].toString())),
              ],
            ),
          ),
          SizedBox(
            height: sy(10),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(sy(5), sy(10), sy(5), sy(5)),
            decoration: decoration_round(fc_bg, sy(10), sy(10), sy(10), sy(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                  child: Text(
                    Lang(" User Summary ", "ملخص المستخدم  "),
                    style: ts_Bold(sy(n), fc_2),
                  ),
                ),
                SizedBox(
                  height: sy(3),
                ),
                cardMoreDetail(Lang("Name  ", " اسم "),
                    ordersDetail[0]['name'].toString()),
                cardMoreDetail(Lang("City  ", " مدينة "),
                    ordersDetail[0]['city'].toString()),
                GestureDetector(
                  onTap: () {
                    UrlOpenUtils.call(
                        _scaffoldKey, ordersDetail[0]['phone'].toString());
                  },
                  child: cardMoreDetail(Lang("Phone  ", " رقم الهاتف "),
                      ordersDetail[0]['phone'].toString()),
                ),
                cardMoreDetail(Lang(" Email ", "البريد الإلكتروني  "),
                    ordersDetail[0]['email'].toString()),
              ],
            ),
          )
        ],
      ),
    );
  }

  divLine(double top, double bottom) {
    return Container(
      color: Colors.grey.shade200,
      width: Width(context),
      height: sy(1),
      margin: EdgeInsets.fromLTRB(sy(0), top, sy(0), bottom),
    );
  }

  cardMoreDetail(String qes, String ans) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
        decoration: decoration_border(
            fc_bg, fc_bg, 0.0, sy(15), sy(15), sy(15), sy(15)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.double_arrow,
                  size: sy(l - 1),
                  color: fc_4,
                ),
                SizedBox(
                  width: sy(8),
                ),
                Text(
                  qes.toString(),
                  style: ts_Regular(sy(n - 1), fc_3),
                ),
                Spacer(),
                TranslationWidget(
                  message: ans.toString(),
                  style: ts_Regular(sy(n - 1), fc_2),
                ),
              ],
            ),
          ],
        ));
  }

  bottomButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ordersDetail[0]['o_status'] != 'D' &&
                  ordersDetail.length != 0)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                    child: TextButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sy(5)),
                          ),
                        ),
                        onPressed: () {
                          popWarning(
                              context,
                              Lang('Cancel Order', 'الغاء الطلب'),
                              'P',
                              'cancel_date');
                        },
                        child: Text(
                          Lang('Cancel Order', 'الغاء الطلب'),
                          style: ts_Bold(sy(n), Colors.red),
                        )),
                  ),
                ),
              //PendingScreen Buttons
              if (ordersDetail[0]['o_status'] == 'P' &&
                  ordersDetail.length != 0)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sy(5)),
                          ),
                        ),
                        onPressed: () {
                          popWarning(
                              context,
                              Lang('Accept Order', "قبول الطلب"),
                              'A',
                              'accept_date');
                        },
                        child: Text(
                          Lang('Accept Order', "قبول الطلب"),
                          style: ts_Bold(sy(n), Colors.white),
                        )),
                  ),
                ),

              //AcceptedOrder Buttons
              if (ordersDetail[0]['o_status'] == 'A' &&
                  ordersDetail.length != 0)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sy(5)),
                          ),
                        ),
                        onPressed: () {
                          popWarning(context, Lang('Ship Order', 'شحن الطلب'),
                              'S', 'sent_date');
                        },
                        child: Text(
                          Lang('Ship Order', 'شحن الطلب'),
                          style: ts_Bold(sy(n), Colors.white),
                        )),
                  ),
                ),

              if (ordersDetail[0]['o_status'] == 'S' &&
                  ordersDetail.length != 0)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sy(5)),
                          ),
                        ),
                        onPressed: () {
                          popWarning(
                              context,
                              Lang('Delivered Order', "تم تسليم الطلب"),
                              'D',
                              'delivery_date');
                        },
                        child: Text(
                          Lang('Delivered Order', "تم تسليم الطلب"),
                          style: ts_Bold(sy(n), Colors.white),
                        )),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  actionButton() {
    return Container(
        width: Width(context),
        // color: fc_bg,
        padding: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(0)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: tabbutton(
                    Icons.add_call,
                    Lang(
                      'Call',
                      'اتصال',
                    )),
                onTap: () {
                  UrlOpenUtils.call(_scaffoldKey, ordersDetail[0]['phone']);
                  //Navigator.push(context, OpenScreen(widget: SellerProfileScreen(seller: productDetail[0]['u_id'],)));
                },
              ),
              GestureDetector(
                child: tabbutton(
                    FontAwesomeIcons.whatsapp, Lang('Whatsapp', 'ال WhatsApp')),
                onTap: () {
                  UrlOpenUtils.whatsappShop(_scaffoldKey,
                      ordersDetail[0]['country_id'] + ordersDetail[0]['phone']);
                },
              ),
              GestureDetector(
                child:
                    tabbutton(Icons.chat_bubble_outline, Lang('Chat', 'دردشة')),
                onTap: () {
                  Navigator.push(
                      context,
                      OpenScreen(
                          widget: ChatScreen(
                        opImage: ordersDetail[0]['profile_pic'].toString(),
                        opName: ordersDetail[0]['name'].toString(),
                        opId: ordersDetail[0]['u_id'],
                      )));
                },
              ),
            ],
          ),
        ));
  }

  tabbutton(IconData icon, String name) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(sy(10), sy(6), sy(15), sy(6)),
      margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
      decoration: decoration_round(fc_6, sy(10), sy(10), sy(10), sy(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: sy(l),
            color: fc_2,
          ),
          SizedBox(
            width: sy(8),
          ),
          Text(
            name,
            style: ts_Regular(sy(n), fc_2),
          ),
        ],
      ),
    );
  }

  addressBlock() {
    List mapLoc = ordersDetail[0]['map'].toString().split(',');
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
      decoration: decoration_round(fc_bg, sy(10), sy(10), sy(10), sy(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Lang(" Shipping Address ", " عنوان الشحن "),
                      style: ts_Bold(sy(n), fc_2),
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    Text(
                      ordersDetail[0]['address'],
                      style: ts_Regular(sy(s), fc_3),
                    ),
                    SizedBox(
                      height: sy(3),
                    ),
                    Text(ordersDetail[0]['city'],
                        style: ts_Regular(sy(s), fc_2)),
                    SizedBox(
                      height: sy(5),
                    ),
                  ],
                ),
              ),
              Container(
                  width: Width(context) * 0.3,
                  height: Width(context) * 0.25,
                  margin: EdgeInsets.fromLTRB(sy(2), sy(5), sy(2), sy(5)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sy(5)),
                    child: GoogleMap(
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      markers: <Marker>[
                        Marker(
                            markerId: MarkerId("Point"),
                            position: LatLng(double.parse(mapLoc[0]),
                                double.parse(mapLoc[1].toString())),
                            icon: BitmapDescriptor.defaultMarker,
                            infoWindow: InfoWindow(title: "Point")),
                      ].toSet(),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(mapLoc[0]),
                            double.parse(mapLoc[1].toString())),
                        zoom: 15.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _Mapcontroller = controller;
                      },
                    ),
                  )),
            ],
          ),
          SizedBox(
            height: sy(5),
          ),
          Text(
            Lang(
                "Please Note. Some products may not delivered to selected address. You can confirm your order once that particular shop accept your order  ",
                " يرجى الملاحظة. قد لا يتم تسليم بعض المنتجات إلى العنوان المحدد. يمكنك تأكيد طلبك بمجرد قبول هذا المتجر المحدد لطلبك "),
            style: ts_Regular(sy(s), Colors.grey.shade500),
          ),
          SizedBox(
            height: sy(5),
          )
        ],
      ),
    );
  }

  cardOrderStatus(String status) {
    Color Darkclr = Colors.green;
    String lable = Lang("Accepted ", "تمت الموافقة ");
    if (status == 'A') {
      Darkclr = Colors.green;
      lable = Lang("Accepted ", "تمت الموافقة ");
    }
    if (status == 'P') {
      Darkclr = Colors.blue;
      lable = Lang("Pending ", "قيد الانتظار ");
    }
    if (status == 'R') {
      Darkclr = Colors.red;
      lable = Lang("Declined ", "تم الرفض ");
    }
    if (status == 'S') {
      Darkclr = Colors.purple;
      lable = Lang("Declined ", "تم الرفض ");
    }
    if (status == 'D') {
      Darkclr = Colors.grey;
      lable = Lang("Declined ", "تم الرفض ");
    }

    if (status == 'D') {
      Darkclr = Colors.grey;
      lable = Lang("Declined ", "تم الرفض ");
    }
    if (status == 'COD') {
      Darkclr = Colors.teal;
      lable = Lang("COD ", "الدفع نقدا عند التسليم");
    }
    if (status == 'PAID') {
      Darkclr = Colors.green;
      lable = Lang("PAID ", "تم الدفع ");
    }
    return Container(
      decoration: decoration_round(
          Darkclr.withOpacity(0.3), sy(3), sy(3), sy(3), sy(3)),
      padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
      child: Text(
        lable,
        style: ts_Regular(sy(s), Darkclr),
      ),
    );
  }
}
