import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/maps/map_screen.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/tap_payment_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/image_viewer.dart';
import '../../components/toast_utils.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/currency_convert.dart';
import '../../utils/style_sheet.dart';
import '../../utils/translation_widget.dart';
import '../../utils/urls.dart';
import 'dashboard.dart';

class AddProduct extends StatefulWidget {
  String pid = '';

  AddProduct({Key? key, this.pid = ''}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  Map data = Map();

  TextEditingController ETname = TextEditingController();
  TextEditingController ETsell = TextEditingController();
  TextEditingController ETquantity = TextEditingController();
  TextEditingController ETdetail = TextEditingController();

  TextEditingController ETsname = TextEditingController();
  TextEditingController ETssell = TextEditingController();
  TextEditingController ETsqty = TextEditingController();
  TextEditingController ETphone = TextEditingController();
  TextEditingController ETaddress = TextEditingController();

  List<TextEditingController> ETlist = [];

  List imageList = [];
  List sizeList = [];
  List colorList = [];
  List lableList = [];
  bool vname = false;

  bool vmrp = false;
  bool vsell = false;
  bool vquantity = false;
  bool vdetail = false;
  bool vlatitude = false;
  bool vlongitude = false;
  bool vphone = false;
  double sell = 0;
  String coverPhoto = "";
  double ssell = 0;
  double soffer = 0;

  int quantity = 0;
  String quantityUnit = '';
  String quantityUnitInt = '';
  String quantityUnitArab = '';
  String singleOrMultiSelection = '';

  Color currentColor = Colors.limeAccent;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  String subCategoryName = '', subCategoryID = '';
  String categoryName = '', categoryID = '';
  String phone = '', uId = '', Name = '';
  String Pid = '';
  int stage = 1;
  List subcategoryList = [];
  List userDetail = [];
  int currentPage = 0;
  String dropdownValue = 'None';
  String dropdownValue1 = 'None';
  String productLabelColor = '';
  List<Widget> _screenPages = [];
  List<Widget> _screenPagesIcons = [];
  var imagepath;
  CroppedFile? _image;
  late File finalImage;
  String multiQuantity = '0';
  String singlePurchase = '0';
  String usedProduct = '0';
  List fieldList = [];
  String fieldQestionString = '';
  String fieldAnswerString = '';
  bool _keyboardVisible = false;

  String mapAddress = '', mapLat = '', mapLng = '', mapCity = '';
  late GoogleMapController _Mapcontroller;
  List<Widget> oneStageIcon = [];
  List<Widget> twoStageIcon = [];
  List<Widget> threeStageIcon = [];
  List<Widget> fourStageIcon = [];
  List<Widget> fiveStageIcon = [];
  List<Widget> sixStageIcon = [];
  String skipSignup = '';
  String paid = '0';
  String expire = '20220616';
  String _response = '';
  String _loading = "Loading...";
  var sessionIdValue = "";
  bool changePack = false;
  late MFPaymentCardView mfPaymentCardView;
  List productDetail = [];

  @override
  void initState() {
    // log('init');
    // if (Const.PAYMENTGATEWAYAPITEST.isEmpty) {
    //   setState(() {
    //     _response =
    //         "Missing API Token Key.. You can get it from here: https://myfatoorah.readme.io/docs/test-token";
    //   });
    //   return;
    // }
    // MFSDK.init(Const.PAYMENTGATEWAYAPITEST, MFCountry.UNITED_ARAB_EMIRATES,
    //     MFEnvironment.TEST);
    // // initiateSession();
    super.initState();
    categoryName = '';
    categoryID = '';
    getSharedStore();
  }

  void initiateSession() {
    MFSDK.initiateSession(
        null,
        (MFResult<MFInitiateSessionResponse> result) => {
              if (result.isSuccess())
                {
                  mfPaymentCardView.load(result.response!),
                  print(result.response.toString()),
                  //loadApplePay(result.response!)
                }
              else
                {
                  setState(() {
                    print("Response: " +
                        result.error!.toJson().toString().toString());
                    _response = result.error!.message!;
                  })
                }
            });
  }

  void executeRegularPayment(String price, String days) {
    // The value 1 is the paymentMethodId of KNET payment method.
    // You should call the "initiatePayment" API to can get this id and the ids of all other payment methods
    int paymentMethod = 6;

    var request =
        new MFExecutePaymentRequest(paymentMethod, double.parse(price));

    MFSDK.executePayment(context, request, MFAPILanguage.EN,
        onInvoiceCreated: (String invoiceId) =>
            {print("invoiceId: " + invoiceId)},
        onPaymentResponse: (String invoiceId,
                MFResult<MFPaymentStatusResponse> result) =>
            {
              if (result.isSuccess())
                {
                  setState(() {
                    print("invoiceId: " + invoiceId);
                    print("Response: " + result.response!.toJson().toString());
                    _response = result.response!.toJson().toString().toString();
                    // _booking('PAID', invoiceId.toString());
                    paid = '1';
                    expire = CustomeDate.expdate(addDays: int.parse(days));
                  })
                }
              else
                {
                  setState(() {
                    print("invoiceId: " + invoiceId);
                    print("Response: " + result.error!.toJson().toString());
                    _response = result.error!.message!;
                    //   paid='1';
                    //  expire=CustomeDate.expdate(addDays: int.parse(days));
                    Pop.errorTop(
                        context,
                        Lang("Payment Failed ", "عملية الدفع فشلت "),
                        Icons.warning);
                  })
                }
            });

    setState(() {
      _response = _loading;
    });
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
      mapLat = Provider.of<AppSetting>(context, listen: false).maplat;
      mapLng = Provider.of<AppSetting>(context, listen: false).maplon;
      mapAddress = Provider.of<AppSetting>(context, listen: false).mapAddress;
      mapCity = Provider.of<AppSetting>(context, listen: false).mapCity;
      ETaddress.text = mapAddress;
    });
    print("ffffffff" + uId);
    _getData();
  }

  _getData() async {
    print('uId-' + uId);
    print('Pid-' + Pid);

    showProgress = true;
    final response =
        await http.post(Uri.parse(Urls.GetDataForProduct), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": Pid.toString(),
      "cid": categoryID.toString(),
    });
    data = json.decode(response.body);

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        imageList = data["images"];
        sizeList = data["size"];
        colorList = data["color"];

        if (imageList.length == 1) {
          coverPhoto = imageList[0]['pi_image'];
        }

        if (widget.pid != '') {
          productDetail = data["product"];
          productDetail = data["field"];
          //START
          categoryID = productDetail[0]['c_id'];
          ETname.text = productDetail[0]['p_title'];
          subCategoryID = productDetail[0]['sc_id'];
          coverPhoto = productDetail[0]['p_image'];
          sell = productDetail[0]['p_sell'];
          quantity = productDetail[0]['p_quantity'];
          quantityUnit = productDetail[0]['p_unit'];
          quantityUnitArab = productDetail[0]['p_unit_arab'];
          ETdetail.text = productDetail[0]['p_detail'];
          singlePurchase = productDetail[0]['p_single_buy'];
          multiQuantity = productDetail[0]['p_multi_quantity'];
          usedProduct = productDetail[0]['p_used'];
          mapLat = productDetail[0]['p_lat'];
          mapLng = productDetail[0]['p_lng'];
          ETaddress.text = productDetail[0]['p_address'];
          mapCity = productDetail[0]['p_city'];
          paid = productDetail[0]['p_paid'];
          expire = productDetail[0]['p_expire'];

          //"fieldqes": fieldQestionString.toString(),
          // "fieldans": fieldAnswerString.toString(),

          //END
        }
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  addProduct() async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.AddProduct), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "cid": categoryID.toString(),
    });

    data = json.decode(response.body);
    debugPrint("Request--" + response.request.toString());

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        Pid = data["pid"].toString();
        stage = 2;
        pageController.animateToPage(1,
            duration: Duration(milliseconds: 700), curve: Curves.linear);
        print(Pid);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  updateProduct() async {
    showProgress = true;
    var body = {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": Pid.toString(),
      "name": ETname.text.toString(),
      "cid": categoryID.toString(),
      "scid": subCategoryID.toString(),
      "cover": coverPhoto.toString(),
      "mrp": sell.toString(),
      "sell": sell.toString(),
      "quantity": quantity.toString(),
      "quantityunit": quantityUnit.toString(),
      "quantityunitarab": quantityUnitArab.toString(),
      "detail": ETdetail.text.toString(),
      "single": singlePurchase.toString(),
      "multiple": multiQuantity.toString(),
      "used": usedProduct.toString(),
      "fieldqes": fieldQestionString.toString(),
      "fieldans": fieldAnswerString.toString(),
      'latitude': mapLat.toString(),
      'longitude': mapLng.toString(),
      'address': ETaddress.text.toString().replaceAll("'", ""),
      'city': mapCity.toString(),
      'paid': paid.toString(),
      'expire': expire.toString(),
    };
    final response = await http.post(Uri.parse(Urls.UpdateProduct),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
    data = json.decode(response.body);
    debugPrint("Request--" + body.toString());
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        apiTest(data['sql'].toString());
        _Pop_showSuccessMessage(context);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _deleteProduct() async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.deleteProduct), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "pid": Pid,
      "uid": uId,
    });
    data = json.decode(response.body);
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        Navigator.of(context).pop();
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _deleteImage(String id) async {
    setState(() {
      showProgress = true;
    });

    final response =
        await http.post(Uri.parse(Urls.deleteProductImage), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "iid": id,
    });
    data = json.decode(response.body);
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        imageList.clear();
        _getData();
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _UpdateImageMultipart(File finalImage) async {
    setState(() {
      showProgress = true;
    });
    // open a byteStream
    var stream = http.ByteStream(DelegatingStream.typed(finalImage.openRead()));
    // get file length
    var length = await finalImage.length();
    var request = http.MultipartRequest("POST", Uri.parse(Urls.addImage));
    request.fields["key"] = Const.APPKEY;
    request.fields["pid"] = Pid;
    request.fields["uid"] = uId;
    var multipartFile = http.MultipartFile('image', stream, length,
        filename: path.basename(finalImage.path));
    request.files.add(multipartFile);

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        data = json.decode(value);
        if (data["success"] == true) {
          setState(() {
            showProgress = false;
            imageList.clear();
            _getData();
          });
        }
        print(value);
      });
    }).catchError((e) {
      print(e);
    });
  }

  addSize() async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.AddNewSize), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": Pid,
      "name": ETsname.text.toString(),
      "mrp": ETssell.text.toString(),
      "sell": ETssell.text.toString(),
      "qty": '10',
    });
    data = json.decode(response.body);
    debugPrint("Request--" + response.request.toString());
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        ETsname.clear();
        ETssell.clear();
        ETsqty.clear();

        ssell = 0;
        soffer = 0;

        sizeList.clear();
        colorList.clear();
        _getData();
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  updateSize(
      String name, String mrp, String sell, String qty, String id) async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.updateSize), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "iid": id,
      "name": name,
      "mrp": mrp,
      "sell": sell,
      "qty": qty.toString(),
    });
    data = json.decode(response.body);
    debugPrint("Request--" + response.request.toString());
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        ETsname.clear();
        ETssell.clear();
        ETsqty.clear();

        ssell = 0;
        soffer = 0;

        sizeList.clear();
        colorList.clear();
        _getData();

        //  _popCategory(context);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  deleteVar(String id, String mode) async {
    print('id-' + id);
    print('mode-' + mode);
    setState(() {
      showProgress = true;
    });

    final response =
        await http.post(Uri.parse(Urls.deleteProductVar), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "id": id,
      "mode": mode,
    });
    data = json.decode(response.body);
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        imageList.clear();
        sizeList.clear();
        colorList.clear();
        _getData();
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  addVarColor(String code) async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.AddVarColor), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": uId,
      "pid": Pid,
      "color": code,
    });

    data = json.decode(response.body);
    debugPrint("Request--" + response.request.toString());
    debugPrint("Request--" + response.body.toString());
    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        colorList.clear();
        sizeList.clear();
        _getData();
        print('success');

        //  _popCategory(context);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _Pop_showSuccessMessage(BuildContext mcontext) {
    showDialog(
      context: mcontext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            Lang("Success", "نجاح"),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/complete.gif',
                width: 150,
                height: 150,
              ),
              Text(
                  Lang(
                      " Your product added successfully. After verification process, your post and linked images will get listed ",
                      " تمت إضافة منتجك بنجاح. بعد عملية التحقق ، سيتم إدراج منشورك والصور المرتبطة "),
                  textAlign: TextAlign.center),
              SizedBox(
                height: sy(10),
                width: 100,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(TheamPrimary),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(sy(20), sy(5), sy(20), sy(5)),
                  child: Text(Lang("Ok", "موافق"),
                      style: TextStyle(color: Colors.white, fontSize: sy(10))),
                ),
                onPressed: () {
                  Navigator.of(mcontext).pop();
                  Navigator.pushReplacement(
                      mcontext, OpenScreen(widget: Dashboard()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // MFSDK.init(Const.PAYMENTGATEWAYAPITEST, MFCountry.UNITED_ARAB_EMIRATES,
    //     MFEnvironment.TEST);
    initRelativeScaler(context);
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
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
                    // key: _scaffoldKey,
                    //   resizeToAvoidBottomPadding: false,
                    body: Container(
                      decoration: BoxDecoration(
                        color: userDetail.length == 0 ? fc_bg : fc_bg2,
                      ),
                      height: Height(context),
                      width: Width(context),
                      child: Stack(
                        children: <Widget>[
                          //center body

                          //title
                          Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: sy(60),
                                decoration: decoration_round(
                                    fc_bg, 0, 0, sy(10), sy(10)),
                                padding: EdgeInsets.fromLTRB(
                                    sy(10), sy(20), sy(10), sy(5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        Icons.arrow_back,
                                        size: sy(xl),
                                        color: fc_3,
                                      ),
                                      onTap: () {
                                        onBackBtn();
                                      },
                                    ),
                                    Spacer(),
                                    Text(
                                      Lang(" CREATE POST ", " إنشاء منشور "),
                                      style: ts_Regular(sy(n), fc_1),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              )),
                          Positioned(
                            top: sy(45),
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _screenBody(),
                          ),

                          //Bottom
                          if (_keyboardVisible == false)
                            Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      sy(10), sy(10), sy(10), sy(5)),
                                  child: Row(
                                    children: [
                                      if (currentPage != 0)
                                        ElevatedButton(
                                            onPressed: () {
                                              onBackBtn();
                                            },
                                            style: elevatedButton(
                                                TheamPrimary, sy(5)),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: sy(80),
                                              padding: EdgeInsets.fromLTRB(
                                                  sy(15),
                                                  sy(10),
                                                  sy(15),
                                                  sy(10)),
                                              child: Text(
                                                Lang(" Previous ", " سابق "),
                                                style: ts_Regular(sy(n), fc_bg),
                                              ),
                                            )),
                                      Spacer(),
                                      if (currentPage == 0)
                                        ElevatedButton(
                                            onPressed: () {
                                              apiTest(_screenPages.length
                                                  .toString());
                                              apiTest(currentPage.toString());
                                              if (categoryID == '') {
                                                Pop.errorTop(
                                                    context,
                                                    Lang(
                                                        "Please select category  ",
                                                        " الرجاء تحديد الفئة "),
                                                    Icons.warning);
                                              } else {
                                                addProduct();
                                              }
                                            },
                                            style: elevatedButton(
                                                TheamPrimary, sy(5)),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: sy(100),
                                              padding: EdgeInsets.fromLTRB(
                                                  sy(15),
                                                  sy(10),
                                                  sy(15),
                                                  sy(10)),
                                              child: Text(
                                                (categoryID ==
                                                        Const.COMMUNITY_ID)
                                                    ? Lang(" Add Service ",
                                                        "أضف خدمة  ")
                                                    : (categoryID ==
                                                            Const.JOBS_ID)
                                                        ? Lang("Add Job  ",
                                                            " أضف وظيفة ")
                                                        : Lang("Create Now  ",
                                                            " انشئ الأن "),
                                                style: ts_Regular(sy(n), fc_bg),
                                              ),
                                            )),
                                      if (currentPage != 0 &&
                                          currentPage !=
                                              _screenPages.length - 1)
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                pageController.animateToPage(
                                                    currentPage + 1,
                                                    duration: Duration(
                                                        milliseconds: 700),
                                                    curve: Curves.linear);
                                              });
                                            },
                                            style: elevatedButton(
                                                TheamPrimary, sy(5)),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: sy(80),
                                              padding: EdgeInsets.fromLTRB(
                                                  sy(15),
                                                  sy(10),
                                                  sy(15),
                                                  sy(10)),
                                              child: Text(
                                                Lang(" Next ", " التالي "),
                                                style: ts_Regular(sy(n), fc_bg),
                                              ),
                                            )),
                                      if (currentPage ==
                                          _screenPages.length - 1)
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                if (sell == 0) {
                                                  ToastUtils.Error(
                                                      _scaffoldKey,
                                                      Lang(
                                                          'Please check the price',
                                                          "الرجاء التحقق من السعر"));
                                                } else {
                                                  if (quantity == 0 ||
                                                      quantityUnit == '0') {
                                                    ToastUtils.Error(
                                                        _scaffoldKey,
                                                        Lang(
                                                            'Please check the quantity and unit',
                                                            "يرجى التحقق من الكمية والوحدة"));
                                                  } else {
                                                    fieldQestionString = '';
                                                    fieldAnswerString = '';
                                                    for (int j = 0;
                                                        j < fieldList.length;
                                                        j++) {
                                                      fieldQestionString =
                                                          fieldQestionString +
                                                              fieldList[j]
                                                                  ['f_id'] +
                                                              ',';
                                                      fieldAnswerString =
                                                          fieldAnswerString +
                                                              ETlist[j].text +
                                                              ',';
                                                    }

                                                    try {
                                                      fieldAnswerString =
                                                          fieldAnswerString.substring(
                                                              0,
                                                              fieldAnswerString
                                                                      .length -
                                                                  1);
                                                      fieldQestionString =
                                                          fieldQestionString.substring(
                                                              0,
                                                              fieldQestionString
                                                                      .length -
                                                                  1);
                                                    } catch (e) {}

                                                    if (mapLat == '') {
                                                      ToastUtils.Error(
                                                          _scaffoldKey,
                                                          'Please select address');
                                                    } else {
                                                      if (coverPhoto == '') {
                                                        ToastUtils.Error(
                                                            _scaffoldKey,
                                                            'Please add photos');
                                                      } else {
                                                        updateProduct();
                                                      }
                                                    }
                                                  }
                                                }
                                              });
                                            },
                                            style: elevatedButton(
                                                TheamPrimary, sy(5)),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: sy(80),
                                              padding: EdgeInsets.fromLTRB(
                                                  sy(15),
                                                  sy(10),
                                                  sy(15),
                                                  sy(10)),
                                              child: Text(
                                                Lang(" Save ", " حفظ "),
                                                style: ts_Regular(sy(n), fc_bg),
                                              ),
                                            )),
                                    ],
                                  ),
                                )),
                          //Done Button
                          if (_keyboardVisible == true)
                            Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  width: Width(context),
                                  color: TheamPrimary,
                                  padding: EdgeInsets.fromLTRB(
                                      sy(10), sy(4), sy(5), sy(4)),
                                  child: Row(
                                    children: [
                                      Text(
                                        Lang('7Emirate Post Management',
                                            "إدارة بريد 7Emirate"),
                                        style: ts_Regular(sy(s), fc_bg),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          onTap: () {
                                            apiTest(
                                                Const.packageList.toString());
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: decoration_round(fc_bg,
                                                sy(3), sy(3), sy(3), sy(3)),
                                            padding: EdgeInsets.fromLTRB(
                                                sy(10), sy(3), sy(10), sy(3)),
                                            child: Text(
                                              Lang("Done ", "تم "),
                                              style: ts_Regular(
                                                  sy(s), TheamPrimary),
                                            ),
                                          )),
                                    ],
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ),
        onWillPop: () => onBackBtn());
  }

  onBackBtn() {
    setState(() {
      if (Pid == '' || Pid == null) {
        Navigator.pushReplacement(context, OpenScreen(widget: Dashboard()));
      } else {
        if (pageController.page == 1) {
          _deleteProduct();
        } else {
          if (pageController.page == 0) {
            Navigator.of(context).pop();
          } else {
            pageController.animateToPage(currentPage - 1,
                duration: Duration(milliseconds: 700), curve: Curves.linear);
          }
        }
      }
    });
  }

  _screenBody() {
    return Container(
      width: Width(context),
      height: Height(context),
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (val) {
          setState(() {
            currentPage = val;
            apiTest(currentPage.toString());
          });
        },
        children: generateScreen(),
      ),
    );
  }

  generateScreen() {
    setState(() {
      _screenPages = [
        oneCategoryWidget(),
        twoBasicWidget(),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          threeFieldWidget(),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          fourVariantWidget(),
        fivePhotoWidget(),
        sixMapWidget()
      ];
    });
    topIconGenerate();
    return _screenPages;
  }

  topIconGenerate() {
    setState(() {
      oneStageIcon = [
        cardIcon(TheamPrimary, fc_bg!, Icons.widgets),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.receipt),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          cardIcon(Colors.grey.shade300, fc_2!, Icons.business_center),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          cardIcon(Colors.grey.shade300, fc_2!, Icons.local_offer),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.image),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.add_location),
      ];

      twoStageIcon = [
        cardIcon(TheamPrimary, fc_bg!, Icons.widgets),
        cardIcon(TheamPrimary, fc_bg!, Icons.receipt),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          cardIcon(Colors.grey.shade300, fc_2!, Icons.business_center),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          cardIcon(Colors.grey.shade300, fc_2!, Icons.local_offer),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.image),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.add_location),
      ];

      threeStageIcon = [
        cardIcon(TheamPrimary, fc_bg!, Icons.widgets),
        cardIcon(TheamPrimary, fc_bg!, Icons.receipt),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          cardIcon(TheamPrimary, fc_bg!, Icons.business_center),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          cardIcon(Colors.grey.shade300, fc_2!, Icons.local_offer),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.image),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.add_location),
      ];

      fourStageIcon = [
        cardIcon(TheamPrimary, fc_bg!, Icons.widgets),
        cardIcon(TheamPrimary, fc_bg!, Icons.receipt),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          cardIcon(TheamPrimary, fc_bg!, Icons.business_center),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          cardIcon(TheamPrimary, fc_bg!, Icons.local_offer),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.image),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.add_location),
      ];

      fiveStageIcon = [
        cardIcon(TheamPrimary, fc_bg!, Icons.widgets),
        cardIcon(TheamPrimary, fc_bg!, Icons.receipt),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          cardIcon(TheamPrimary, fc_bg!, Icons.business_center),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          cardIcon(TheamPrimary, fc_bg!, Icons.local_offer),
        cardIcon(TheamPrimary, fc_bg!, Icons.image),
        cardIcon(Colors.grey.shade300, fc_2!, Icons.add_location),
      ];

      sixStageIcon = [
        cardIcon(TheamPrimary, fc_bg!, Icons.widgets),
        cardIcon(TheamPrimary, fc_bg!, Icons.receipt),
        if (categoryID != Const.COMMUNITY_ID && fieldList.length != 0)
          cardIcon(TheamPrimary, fc_bg!, Icons.business_center),
        if (categoryID != Const.COMMUNITY_ID && categoryID != Const.JOBS_ID)
          cardIcon(TheamPrimary, fc_bg!, Icons.local_offer),
        cardIcon(TheamPrimary, fc_bg!, Icons.image),
        cardIcon(TheamPrimary, fc_bg!, Icons.add_location),
      ];
    });
  }

  cardIcon(Color bgcolor, Color icocolor, IconData icon) {
    return Container(
      width: sy(25),
      height: sy(25),
      decoration: decoration_round(bgcolor, sy(20), sy(20), sy(20), sy(20)),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: sy(l),
        color: icocolor,
      ),
    );
  }

  oneCategoryWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: sy(30),
            decoration: decoration_round(
                Colors.grey.shade200, sy(8), sy(8), sy(8), sy(8)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: oneStageIcon,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              // padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: sy(15),
                  ),
                  SizedBox(
                    height: sy(20),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(sy(8), sy(5), sy(5), sy(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Lang(" Select Your Product Category ",
                                " حدد فئة المنتج الخاص بك "),
                            style: ts_Bold(sy(n), fc_2),
                          ),
                          SizedBox(
                            height: sy(2),
                          ),
                          Text(
                            Lang(
                                " Choose correct category suit for your product ",
                                "اختر الفئة المناسبة لمنتجك  "),
                            style: ts_Regular(sy(s), fc_4),
                          ),
                        ],
                      )),
                  Container(
                    width: Width(context),
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        for (int i = 0; i < Const.categoryList.length; i++)
                          GestureDetector(
                            child: Container(
                              width: Width(context) * 0.25,
                              child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      sy(0), sy(0), sy(0), sy(0)),
                                  margin: EdgeInsets.fromLTRB(
                                      sy(3), sy(3), sy(3), sy(3)),
                                  decoration: decoration_round(
                                      (categoryID ==
                                              Const.categoryList[i]['c_id']
                                                  .toString())
                                          ? TheamPrimary
                                          : Colors.grey.shade200,
                                      sy(3),
                                      sy(3),
                                      sy(3),
                                      sy(3)),
                                  child: Column(
                                    children: [
                                      CustomeImageView(
                                        image: Urls.imageLocation +
                                            Const.categoryList[i]['c_image'],
                                        width: Width(context) * 0.25,
                                        height: Width(context) * 0.25,
                                        radius: sy(0),
                                        blurBackground: false,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        width: sy(8),
                                      ),
                                      Container(
                                        padding: EdgeInsets.fromLTRB(
                                            sy(3), sy(4), sy(3), sy(3)),
                                        child: Text(
                                          Const.categoryList[i]
                                              ['c_name$cur_Lang'],
                                          style: ts_Regular(
                                              sy(s),
                                              (categoryID ==
                                                      Const.categoryList[i]
                                                              ['c_id']
                                                          .toString())
                                                  ? Colors.white
                                                  : fc_2),
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            onTap: () {
                              setState(() {
                                categoryName = Const.categoryList[i]
                                        ['c_name$cur_Lang']
                                    .toString();
                                categoryID =
                                    Const.categoryList[i]['c_id'].toString();
                                print("george$categoryID");
                                print("george$categoryName");
                                fieldList.clear();
                                //ETlist.clear();
                                for (int i = 0;
                                    i < Const.fieldsList.length;
                                    i++) {
                                  if (Const.fieldsList[i]['c_id'] ==
                                      categoryID) {
                                    fieldList.add(Const.fieldsList[i]);
                                    TextEditingController Ettemp =
                                        TextEditingController();
                                    ETlist.add(Ettemp);
                                  }
                                }
                                topIconGenerate();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: sy(30),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  twoBasicWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: sy(30),
            decoration: decoration_round(
                Colors.grey.shade200, sy(8), sy(8), sy(8), sy(8)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: twoStageIcon,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: sy(20),
                  ),

                  titleCard((categoryID == Const.COMMUNITY_ID)
                      ? Lang(" Service Name ", " اسم الخدمة ")
                      : (categoryID == Const.JOBS_ID)
                          ? Lang(" Job Title ", " مسمى وظيفي ")
                          : Lang("Title  ", "عنوان  ")),
                  Container(
                    decoration: decoration_border(fc_textfield_bg,
                        fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                    height: sy(28),
                    padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(3), sy(0)),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: ETname,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.sentences,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        // counter: Offstage(),
                        isDense: true,
                        hintText: ' ',
                        hintStyle: ts_Regular(sy(n), fc_4),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                      style: ts_Regular(sy(n), fc_2),
                      textInputAction: TextInputAction.next,
                      autofocus: false,
                    ),
                  ),

                  SizedBox(
                    height: sy(15),
                  ),

                  //Product category
                  titleCard(Lang(" Category ", " فئة ")),
                  GestureDetector(
                      onTap: () {
                        _popsubCategory(context);
                      },
                      child: Container(
                        width: Width(context),
                        decoration: decoration_border(fc_textfield_bg,
                            fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                        height: sy(28),
                        padding:
                            EdgeInsets.fromLTRB(sy(5), sy(0), sy(3), sy(0)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (subCategoryID == '')
                              ? Lang(" Select Category ", " اختر الفئة ")
                              : subCategoryName,
                          style: ts_Regular(sy(n), fc_2),
                        ),
                      )),
                  SizedBox(
                    height: sy(15),
                  ),
                  //Pricing
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleCard((categoryID == Const.COMMUNITY_ID)
                                ? Lang(" Service Cost", "تكلفة الخدمة ")
                                : (categoryID == Const.JOBS_ID)
                                    ? Lang("Package per Month ", "حزمة شهريا ")
                                    : Lang("Price ", "سعر ")),
                            Container(
                              decoration: decoration_border(
                                  fc_textfield_bg,
                                  fc_textfield_bg,
                                  sy(1),
                                  sy(5),
                                  sy(5),
                                  sy(5),
                                  sy(5)),
                              height: sy(28),
                              padding: EdgeInsets.fromLTRB(
                                  sy(5), sy(0), sy(5), sy(0)),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: ETsell,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  // counter: Offstage(),
                                  isDense: true,
                                  hintText: ' ',
                                  suffix: Text(
                                    Const.CURRENCY,
                                    style: ts_Regular(sy(s), fc_4),
                                  ),
                                  hintStyle: ts_Regular(sy(n), fc_4),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                ),
                                style: ts_Regular(sy(n), fc_2),
                                textInputAction: TextInputAction.next,
                                autofocus: false,
                                onChanged: (val) {
                                  setState(() {
                                    sell = double.parse(val.toString());
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (categoryID != Const.COMMUNITY_ID &&
                          categoryID != Const.JOBS_ID)
                        SizedBox(
                          width: sy(20),
                        ),
                      if (categoryID != Const.COMMUNITY_ID &&
                          categoryID != Const.JOBS_ID)
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleCard(
                                    Lang(" Used Product ", " منتج مستعمل "),
                                    help: Lang(
                                        " is this product is new or already used ",
                                        "هل هذا المنتج جديد أم مستخدم بالفعل  ")),
                                GestureDetector(
                                    onTap: () {
                                      showSingleOrMultiPop('used');
                                    },
                                    child: Container(
                                      width: Width(context),
                                      decoration: decoration_border(
                                          fc_textfield_bg,
                                          fc_textfield_bg,
                                          sy(1),
                                          sy(5),
                                          sy(5),
                                          sy(5),
                                          sy(5)),
                                      height: sy(28),
                                      padding: EdgeInsets.fromLTRB(
                                          sy(5), sy(0), sy(3), sy(0)),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        usedProduct == '0'
                                            ? Lang(" No ", " لا ")
                                            : Lang("Yes  ", " نعم "),
                                        style:
                                            ts_Regular(sy(n), Colors.grey[800]),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  //quanity
                  SizedBox(
                    height: sy(15),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleCard(
                                (categoryID == Const.COMMUNITY_ID)
                                    ? Lang(
                                        " Service Quantity ", " كمية الخدمة ")
                                    : (categoryID == Const.JOBS_ID)
                                        ? Lang(
                                            " No. Positions ", " عدد المناصب ")
                                        : Lang(" Quantity ", " كمية "),
                                help: Lang(
                                    " Sales quantity for purchase / Service timing or measurements ",
                                    " كمية المبيعات للشراء / توقيت الخدمة أو القياسات ")),
                            Container(
                              decoration: decoration_border(
                                  fc_textfield_bg,
                                  fc_textfield_bg,
                                  sy(1),
                                  sy(5),
                                  sy(5),
                                  sy(5),
                                  sy(5)),
                              height: sy(28),
                              padding: EdgeInsets.fromLTRB(
                                  sy(5), sy(0), sy(5), sy(0)),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: ETquantity,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  // counter: Offstage(),
                                  isDense: true,
                                  hintText: ' ',
                                  suffix: Text(
                                    '',
                                    style: ts_Regular(sy(s), fc_4),
                                  ),
                                  hintStyle: ts_Regular(sy(n), fc_4),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                ),
                                style: ts_Regular(sy(n), fc_2),
                                textInputAction: TextInputAction.next,
                                autofocus: false,
                                onChanged: (val) {
                                  setState(() {
                                    quantity = int.parse(val);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: sy(20),
                      ),
                      categoryName == "Vehicles"
                          ? SizedBox()
                          :
                           Expanded(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    titleCard(Lang("Unit  ", " وحدة ")),
                                    GestureDetector(
                                        onTap: () {
                                          _popUnit(context);
                                        },
                                        child: Container(
                                          width: Width(context),
                                          decoration: decoration_border(
                                              fc_textfield_bg,
                                              fc_textfield_bg,
                                              sy(1),
                                              sy(5),
                                              sy(5),
                                              sy(5),
                                              sy(5)),
                                          height: sy(28),
                                          padding: EdgeInsets.fromLTRB(
                                              sy(5), sy(0), sy(3), sy(0)),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            (quantityUnit == '')
                                                ? Lang(" Select unit ",
                                                    " حدد الوحدة ")
                                                : quantityUnit,
                                            style: ts_Regular(
                                                sy(n), Colors.grey[800]),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(
                    height: sy(5),
                  ),

                  categoryName == "Vehicles"
                      ? SizedBox()
                      :    Row(
                    children: [
                      Text(Lang('Unit : ', 'وحدة  '),
                          style: ts_Regular(sy(8), Colors.grey[900])),
                      Text(
                          Lang('Per ', "لكل") +
                              quantityUnitInt +
                              '  ' +
                              Lang(quantityUnit, quantityUnitArab),
                          style: ts_Regular(sy(8), Colors.grey[600])),
                    ],
                  ),
                  //multi & single selection
                  SizedBox(
                    height: sy(20),
                  ),
                  if (categoryID != Const.COMMUNITY_ID &&
                      categoryID != Const.JOBS_ID)
                    Row(
                      //  mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleCard(
                                    Lang(
                                        "  Multiple Quantity", "كمية متعددة  "),
                                    help: Lang(
                                        " user can increase / decrease quantity of purchase ",
                                        " يمكن للمستخدم زيادة / تقليل كمية الشراء ")),
                                GestureDetector(
                                    onTap: () {
                                      showSingleOrMultiPop('quantity');
                                    },
                                    child: Container(
                                      width: Width(context),
                                      decoration: decoration_border(
                                          fc_textfield_bg,
                                          fc_textfield_bg,
                                          sy(1),
                                          sy(5),
                                          sy(5),
                                          sy(5),
                                          sy(5)),
                                      height: sy(28),
                                      padding: EdgeInsets.fromLTRB(
                                          sy(5), sy(0), sy(3), sy(0)),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        multiQuantity == '0'
                                            ? Lang(" No ", " لا ")
                                            : Lang(" Yes ", " نعم "),
                                        style:
                                            ts_Regular(sy(n), Colors.grey[800]),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: sy(20),
                        ),
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // titleCard('Single Purchase',help: 'After purchase, it will shows sold out label'),
                                // GestureDetector(
                                //     onTap: () {
                                //       showSingleOrMultiPop('purchase');
                                //     },
                                //     child: Container(
                                //       width: Width(context),
                                //       decoration: decoration_border(fc_textfield_bg, fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                                //       height: sy(28),
                                //       padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(3), sy(0)),
                                //       alignment: Alignment.centerLeft,
                                //       child: Text(
                                //         singlePurchase == '0' ? 'No' : 'Yes',
                                //         style: ts_Regular(sy(n), Colors.grey[800]),
                                //       ),
                                //     )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (categoryID != Const.COMMUNITY_ID &&
                      categoryID != Const.JOBS_ID)
                    SizedBox(
                      height: sy(20),
                    ),
                  //Detail
                  titleCard(Lang(" Description ", " وصف ")),
                  Container(
                    decoration: decoration_border(fc_textfield_bg,
                        fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                    height: sy(60),
                    padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: ETdetail,
                      keyboardType: TextInputType.multiline,
                      textAlign: TextAlign.left,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        // counter: Offstage(),
                        isDense: true,
                        hintText: ' ',
                        suffix: Text(
                          '',
                          style: ts_Regular(sy(s), fc_4),
                        ),
                        hintStyle: ts_Regular(sy(n), fc_4),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                      style: ts_Regular(sy(n), fc_2),
                      textInputAction: TextInputAction.newline,
                      maxLines: 20,
                      autofocus: false,
                    ),
                  ),

                  SizedBox(
                    height: sy(100),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  threeFieldWidget() {
    fieldList.clear();
    //  ETlist.clear();
    for (int i = 0; i < Const.fieldsList.length; i++) {
      if (Const.fieldsList[i]['c_id'] == categoryID) {
        fieldList.add(Const.fieldsList[i]);
        TextEditingController Ettemp = TextEditingController();
        ETlist.add(Ettemp);
      }
    }

    return Container(
      child: Column(
        children: [
          Container(
            height: sy(30),
            decoration: decoration_round(
                Colors.grey.shade200, sy(8), sy(8), sy(8), sy(8)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: threeStageIcon,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: sy(5),
                  ),
                  for (int i = 0; i < fieldList.length; i++) fieldCard(i)
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  fourVariantWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: sy(30),
            decoration: decoration_round(
                Colors.grey.shade200, sy(8), sy(8), sy(8), sy(8)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: fourStageIcon,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: sy(10),
                  ),

                  //Variants
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  Lang('Add Variants', 'أضف المتغيرات'),
                                  style: ts_Regular(sy(n), fc_1),
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    ssell = 0;
                                    soffer = 0;
                                    _popAddSize(context);
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: sy(l),
                                            color: TheamSecondary,
                                          ),
                                          SizedBox(
                                            width: sy(5),
                                          ),
                                          Text(
                                            Lang('Add', 'إضافة'),
                                            style: ts_Regular(
                                                sy(s), TheamSecondary),
                                          ),
                                        ],
                                      ))),
                            ],
                          ),
                          if (sizeList.length == 0)
                            Container(
                              child: Text(
                                Lang('No variants available',
                                    "لا توجد متغيرات متاحة"),
                                style: ts_Regular(sy(s), fc_3),
                              ),
                              margin: EdgeInsets.fromLTRB(
                                  sy(0), sy(5), sy(0), sy(10)),
                            ),
                          for (int i = 0; i < sizeList.length; i++)
                            sizeCard(
                                i,
                                sizeList[i]['ps_id'].toString(),
                                sizeList[i]['name'],
                                sizeList[i]['mrp'],
                                sizeList[i]['sell'],
                                sizeList[i]['s_qty']),
                        ],
                      )),
                  SizedBox(
                    height: sy(10),
                  ),
                  Divider(
                    color: fc_4,
                  ),
                  SizedBox(
                    height: sy(10),
                  ),
                  //Color
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  Lang('Color', 'اللون'),
                                  style: ts_Regular(sy(n), fc_1),
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    colorSelection(context);
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: sy(l),
                                            color: TheamSecondary,
                                          ),
                                          SizedBox(
                                            width: sy(5),
                                          ),
                                          Text(
                                            Lang("Add  ", " إضافة "),
                                            style: ts_Regular(
                                                sy(s), TheamSecondary),
                                          ),
                                        ],
                                      ))),
                            ],
                          ),
                          if (colorList.length == 0)
                            Container(
                              child: Text(
                                Lang(" No colors available ",
                                    " لا توجد ألوان متاحة "),
                                style: ts_Regular(sy(s), fc_3),
                              ),
                              margin: EdgeInsets.fromLTRB(
                                  sy(0), sy(5), sy(0), sy(10)),
                            ),
                          for (int i = 0; i < colorList.length; i++)
                            colorCard(i, colorList[i]['pv_id'].toString(),
                                colorList[i]['color']),
                        ],
                      )),
                  SizedBox(
                    height: sy(60),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  fivePhotoWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: sy(30),
            decoration: decoration_round(
                Colors.grey.shade200, sy(8), sy(8), sy(8), sy(8)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: fiveStageIcon,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: sy(10),
                  ),
                  Container(
                    width: Width(context),
                    padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
                    color: Colors.white,
                    child: Text(
                      Lang(" Photo Gallery ", "معرض الصور  "),
                      style: ts_Regular(sy(10), Colors.grey[700]),
                    ),
                  ),
                  Container(
                    width: Width(context),
                    //   padding: EdgeInsets.fromLTRB(sy(10), sy(20), sy(10), sy(5)),
                    color: Colors.white,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        GestureDetector(
                          child: Container(
                            width: Width(context) * 0.5,
                            height: Width(context) * 0.35,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                  sy(5), sy(5), sy(5), sy(5)),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                                borderRadius: BorderRadius.circular(sy(5)),
                              ),
                              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey[700],
                                size: sy(30),
                              ),
                            ),
                          ),
                          onTap: () {
                            _showPop();
                          },
                        ),
                        for (int i = 0; i < imageList.length; i++)
                          Container(
                            width: Width(context) * 0.5,
                            height: Width(context) * 0.35,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    sy(5), sy(5), sy(5), sy(5)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(sy(5)),
                                  child: Stack(
                                    children: [
                                      CustomeImageView(
                                        image: Urls.imageLocation +
                                            imageList[i]["pi_image"],
                                        width: Width(context),
                                        height: Width(context),
                                        placeholder: Urls.DummyImageBanner,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 5,
                                        left: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            _deleteImage(imageList[i]["pi_id"]
                                                .toString());
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (imageList[i]["pi_image"].toString() !=
                                          coverPhoto)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                coverPhoto = imageList[i]
                                                        ["pi_image"]
                                                    .toString();
                                              });
                                            },
                                            child: Container(
                                              color: TheamSecondary,
                                              padding: EdgeInsets.all(5),
                                              alignment: Alignment.center,
                                              child: Text(
                                                Lang("Make as Cover Photo",
                                                    "تحديد كصورة الغلاف"),
                                                style: ts_Regular(
                                                    10, Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (imageList[i]["pi_image"].toString() ==
                                          coverPhoto)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            child: Container(
                                              color: TheamPrimary,
                                              padding: EdgeInsets.all(5),
                                              alignment: Alignment.center,
                                              child: Text(
                                                Lang("Default", "إفتراضي"),
                                                style: ts_Regular(
                                                    10, Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: sy(10),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  sixMapWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: sy(30),
            decoration: decoration_round(
                Colors.grey.shade200, sy(8), sy(8), sy(8), sy(8)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: sixStageIcon,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: sy(10),
                  ),
                  Text(
                    Lang("Confirm Location  ", " تأكيد الموقع "),
                    style: ts_Bold(sy(n), fc_2),
                  ),
                  SizedBox(
                    height: sy(10),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: decoration_border(
                              fc_textfield_bg,
                              fc_textfield_bg,
                              sy(1),
                              sy(5),
                              sy(5),
                              sy(5),
                              sy(5)),
                          height: sy(80),
                          padding:
                              EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: ETaddress,
                            maxLines: 20,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              // counter: Offstage(),
                              isDense: true,
                              hintText: ' ',
                              hintStyle: ts_Regular(sy(n), fc_4),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                            ),
                            style: ts_Regular(sy(s), fc_2),
                            textInputAction: TextInputAction.newline,
                            autofocus: false,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: sy(5),
                      ),
                      Container(
                          width: Width(context) * 0.3,
                          height: sy(80),
                          margin:
                              EdgeInsets.fromLTRB(sy(2), sy(5), sy(2), sy(5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(sy(5)),
                            child: GoogleMap(
                              mapType: MapType.normal,
                              zoomControlsEnabled: false,
                              markers: _createMarker(
                                  double.tryParse(mapLat.toString()) ?? 0.0,
                                  double.tryParse(mapLng.toString()) ?? 0.0),
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
                  GestureDetector(
                    onTap: () {
                      _openMap();
                    },
                    child: Text(
                      Lang(
                          " Change / Edit Address ", "تغيير / تحرير العنوان  "),
                      style: ts_Regular(sy(s), TheamSecondary),
                    ),
                  ),
                  SizedBox(
                    height: sy(20),
                  ),
                  Text(
                    Lang("Payment Options ", " خيارات الدفع"),
                    style: ts_Bold(sy(n), fc_2),
                  ),
                  SizedBox(
                    height: sy(10),
                  ),
                  Container(
                    width: Width(context),
                    decoration: decoration_round(
                        (int.parse(expire) > int.parse(CustomeDate.expdate()))
                            ? Colors.green
                            : Colors.red.shade50,
                        sy(5),
                        sy(5),
                        sy(5),
                        sy(5)),
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (int.parse(expire) > int.parse(CustomeDate.expdate()))
                              ? Lang("Product Active ", "المنتج نشط ")
                              : Lang(" Product Not Active", "المنتج غير نشط"),
                          style: ts_Bold(
                              sy(n),
                              (int.parse(expire) >
                                      int.parse(CustomeDate.expdate()))
                                  ? Colors.green
                                  : Colors.red),
                        ),
                        SizedBox(
                          height: sy(5),
                        ),
                        if (paid == '0')
                          Text(
                            Lang(
                                "You don't have any pack for this product. Buy any plan below ",
                                "ليس لديك أي حزمة لهذا المنتج. شراء أي خطة أدناه "),
                            style: ts_Regular(sy(n - 1), fc_2),
                          ),
                        if (paid == '1')
                          Text(
                            Lang("You already purchased plan for this product and it will valid up to ",
                                    " لقد اشتريت بالفعل خطة لهذا المنتج وستكون صالحة حتى") +
                                ' ' +
                                expire,
                            style: ts_Regular(sy(n), fc_2),
                          ),
                        SizedBox(
                          height: sy(5),
                        ),
                        if (paid == '1')
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                changePack = !changePack;
                              });
                            },
                            child: Text(
                              Lang("Change Pack ", "تغيير الحزمة "),
                              style: ts_Regular(sy(s), Colors.blue),
                            ),
                          )
                      ],
                    ),
                  ),
                  if ((int.parse(expire) <= int.parse(CustomeDate.expdate())) ||
                      changePack == true)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: sy(10),
                        ),
                        Text(
                          Lang("Choose your plan ", "اختر خطتك "),
                          style: ts_Bold(sy(n), fc_2),
                        ),
                        SizedBox(
                          height: sy(5),
                        ),
                        for (int i = 0; i < Const.packageList.length; i++)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (Const.packageList[i]['price'].toString() ==
                                  '0') {
                                apiTest('Free');
                                paid = '1';
                                expire = CustomeDate.expdate(
                                    addDays: int.parse(Const.packageList[i]['days'].toString())
                                );
                              } else {

                                // executeRegularPayment(
                                //     Const.packageList[i]['price'],
                                //     Const.packageList[i]['days']);

                                var amount = double.tryParse(

                                    Const.packageList[i]['price']
                                        .toString()) ?? 0.0;

                                // TapPaymentHelper.instance.setupSDKSession(
                                //   amount: amount,
                                // );
                                /*   Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TapPaymentScreen(
                                      amount: amount,
                                      onSuccess: (value) {

                                         setState(() {
                                          // print("invoiceId: " + invoiceId);
                                          // print("Response: " +
                                          //     result.response!
                                          //         .toJson()
                                          //         .toString());
                                          _response = value
                                              .toString()
                                              .toString();
                                          // _booking('PAID', invoiceId.toString());
                                          paid = '1';
                                          expire = CustomeDate.expdate(
                                            addDays: int.parse(
                                              Const.packageList[i]['days'],
                                            ),
                                          );
                                        });
                                      },
                                      onFailed: (value) {setState(() {
                                          // print("invoiceId: " + invoiceId);
                                          // print("Response: " +
                                          //     result.error!
                                          //         .toJson()
                                          //         .toString());
                                          _response = value.message!;
                                          //   paid='1';
                                          //  expire=CustomeDate.expdate(addDays: int.parse(days));
                                          Pop.errorTop(
                                              context,
                                              Lang("Payment Failed ",
                                                  "عملية الدفع فشلت "),
                                              Icons.warning);
                                        });},
                                    ),
                                  ),
                                );*/
                                /*  mfHelper.initialPayment(
                                  amount: amount,
                                );
                                mfHelper.showPaymentMethodsSheet(
                                  amount: amount,
                                  context: context,
                                  onPaymentResponse: (String invoiceId,
                                          MFResult<MFPaymentStatusResponse>
                                              result) =>
                                      {
                                    if (result.isSuccess())
                                      {
                                        setState(() {
                                          print("invoiceId: " + invoiceId);
                                          print("Response: " +
                                              result.response!
                                                  .toJson()
                                                  .toString());
                                          _response = result.response!
                                              .toJson()
                                              .toString()
                                              .toString();
                                          // _booking('PAID', invoiceId.toString());
                                          paid = '1';
                                          expire = CustomeDate.expdate(
                                            addDays: int.parse(
                                              Const.packageList[i]['days'],
                                            ),
                                          );
                                        })
                                      }
                                    else
                                      {
                                        setState(() {
                                          print("invoiceId: " + invoiceId);
                                          print("Response: " +
                                              result.error!
                                                  .toJson()
                                                  .toString());
                                          _response = result.error!.message!;
                                          //   paid='1';
                                          //  expire=CustomeDate.expdate(addDays: int.parse(days));
                                          Pop.errorTop(
                                              context,
                                              Lang("Payment Failed ",
                                                  "عملية الدفع فشلت "),
                                              Icons.warning);
                                        });
                                      }
                                  },
                                );*/

                                TapPaymentHelper.instance.setupSDKSession(
                                  amount: amount,
                                  settings: Provider.of<AppSetting>(context,
                                      listen: false),
                                  onSuccess: (invoiceId) {
                                    setState(() {
                                      print("invoiceId: " + invoiceId);
                                      setState(() {
                                        // _booking('PAID', invoiceId.toString());
                                        paid = '1';
                                        expire = CustomeDate.expdate(
                                          addDays: int.parse(
                                            Const.packageList[i]['days'],
                                          ),
                                        );
                                      });
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
                                          Lang("Payment Failed ",
                                              "عملية الدفع فشلت "),
                                          Icons.warning);
                                    });
                                  },
                                );
                                // mfHelper.showPaymentMethodsSheet(
                                //   amount: amount,
                                //   context: context,
                                //   onPaymentResponse: (String invoiceId,
                                //           MFResult<MFPaymentStatusResponse>
                                //               result) =>
                                //       {
                                //     if (result.isSuccess())
                                //       {
                                //         setState(() {
                                //           print("invoiceId: " + invoiceId);
                                //           print("Response: " +
                                //               result.response!
                                //                   .toJson()
                                //                   .toString());
                                //           _response = result.response!
                                //               .toJson()
                                //               .toString()
                                //               .toString();
                                //           // _booking('PAID', invoiceId.toString());
                                //           paid = '1';
                                //           expire = CustomeDate.expdate(
                                //             addDays: int.parse(
                                //               Const.packageList[i]['days'],
                                //             ),
                                //           );
                                //         })
                                //       }
                                //     else
                                //       {
                                //         setState(() {
                                //           print("invoiceId: " + invoiceId);
                                //           print("Response: " +
                                //               result.error!
                                //                   .toJson()
                                //                   .toString());
                                //           _response = result.error!.message!;
                                //           //   paid='1';
                                //           //  expire=CustomeDate.expdate(addDays: int.parse(days));
                                //           Pop.errorTop(
                                //               context,
                                //               Lang("Payment Failed ",
                                //                   "عملية الدفع فشلت "),
                                //               Icons.warning);
                                //         })
                                //       }
                                //   },
                                // );
                              }
                            },
                            child: Container(
                                decoration: decoration_round(
                                    fc_bg2, sy(5), sy(5), sy(5), sy(5)),
                                padding: EdgeInsets.fromLTRB(
                                    sy(5), sy(10), sy(5), sy(10)),
                                margin: EdgeInsets.fromLTRB(
                                    sy(0), sy(5), sy(0), sy(3)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/images/logoonly.png',
                                      width: sy(35),
                                      height: sy(35),
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(
                                      width: sy(5),
                                    ),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TranslationWidget(
                                          message: Const.packageList[i]['title']
                                              .toString()
                                              .toUpperCase(),
                                          style: ts_Bold(sy(n), fc_1),
                                        ),
                                        SizedBox(
                                          height: sy(3),
                                        ),
                                        TranslationWidget(
                                          message: Const.packageList[i]
                                                  ['detail']
                                              .toString(),
                                          style: ts_Regular(sy(n), fc_1),
                                        ),
                                        SizedBox(
                                          height: sy(8),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              Const.packageList[i]['days']
                                                      .toString() +
                                                  ' ' +
                                                  Lang('Days', 'أيام'),
                                              style: ts_Bold(sy(n), fc_1),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                                child: Container(
                                              decoration: decoration_round(
                                                  TheamPrimary,
                                                  sy(5),
                                                  sy(5),
                                                  sy(5),
                                                  sy(5)),
                                              padding: EdgeInsets.fromLTRB(
                                                  sy(5), sy(4), sy(5), sy(4)),
                                              child: Text(
                                                (Const.packageList[i]['price']
                                                            .toString() ==
                                                        '0')
                                                    ? Lang('Free', 'مجاني')
                                                    : PriceUtils.convert(Const
                                                        .packageList[i]['price']
                                                        .toString()),
                                                style: ts_Regular(
                                                    sy(s), Colors.white),
                                              ),
                                            ))
                                          ],
                                        )
                                      ],
                                    ))
                                  ],
                                )),
                          )
                      ],
                    ),
                  SizedBox(
                    height: sy(100),
                    width: Width(context),
                  )
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  titleCard(String lable, {String help = ''}) {
    return Container(
        padding: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(5)),
        child: Row(
          children: [
            Text(
              lable,
              style: ts_Regular(sy(s), fc_3),
            ),
            SizedBox(
              width: sy(2),
            ),
            if (help != '')
              Tooltip(
                message: help,
                preferBelow: false,
                textStyle: ts_Regular(sy(s), fc_3),
                child: Icon(
                  Icons.help,
                  color: fc_4,
                  size: sy(n),
                ),
              )
          ],
        ));
  }

  underLine() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(0), sy(3), sy(0), sy(2)),
      height: 1,
      color: Colors.grey[500],
    );
  }

  fieldCard(int i) {
    List getOptions = [];
    if (fieldList[i]['f_options'] != '' &&
        fieldList[i]['f_options'].toString() != 'null') {
      getOptions = fieldList[i]['f_options'].toString().split(',');
    }

    return Container(
      margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(10)),
      width: Width(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCard(
            fieldList[i]['f_title$cur_Lang'],
          ),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(28),
            padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomeImageView(
                  image:
                      Urls.imageLocation + fieldList[i]['f_image'].toString(),
                  width: sy(17),
                  height: sy(17),
                  blurBackground: false,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: sy(8),
                ),
                Expanded(
                  child: (getOptions.length == 0)
                      ? TextField(
                          controller: ETlist[i],
                          textAlign: TextAlign.left,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: fieldList[i]['f_title$cur_Lang'],
                            hintStyle: ts_Regular(sy(n), fc_4),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          style: ts_Regular(sy(n), fc_2),
                          textInputAction: TextInputAction.next,
                          autofocus: false,
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int j = 0; j < getOptions.length; j++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      ETlist[i].text = getOptions[j].toString();
                                      apiTest(ETlist[i].text);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        sy(8), sy(5), sy(8), sy(5)),
                                    margin: EdgeInsets.fromLTRB(
                                        sy(5), sy(0), sy(5), sy(0)),
                                    decoration: decoration_round(
                                        (ETlist[i].text ==
                                                getOptions[j].toString())
                                            ? TheamPrimary
                                            : Colors.grey.shade300,
                                        sy(5),
                                        sy(5),
                                        sy(5),
                                        sy(5)),
                                    child: TranslationWidget(
                                      message: getOptions[j].toString(),
                                      style: ts_Regular(
                                          sy(s),
                                          (ETlist[i].text ==
                                                  getOptions[j].toString())
                                              ? fc_bg
                                              : fc_1),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Set<Marker> _createMarker(double mapLat, double mapLng) {
    return <Marker>[
      Marker(
          markerId: MarkerId("Point"),
          position: LatLng(mapLat, mapLng),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Point")),
    ].toSet();
  }

  backPressed() {
    ToastUtils.Error(_scaffoldKey,
        Lang('Use top navigation option', 'استخدم خيار التنقل العلوي'));
  }

  _popAddSize(BuildContext mcontext) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(0))),
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (mcontext, setState) {
              return Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Wrap(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(sy(5)),
                        alignment: Alignment.center,
                        child: Text(Lang('Add Variants', "أضف المتغيرات"),
                            style: ts_Regular(sy(10), Colors.black),
                            textAlign: TextAlign.center)),
                    Divider(),
                    titleCard(Lang(" Variant Name ", " اسم المتغير ")),
                    Container(
                      decoration: decoration_border(fc_textfield_bg,
                          fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                      height: sy(28),
                      padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: ETsname,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          isDense: true,
                          hintText: ' ',
                          hintStyle: ts_Regular(sy(n), fc_4),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_2),
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                      ),
                    ),
                    SizedBox(
                      height: sy(10),
                      width: MediaQuery.of(context).size.width,
                    ),
                    titleCard(Lang("Price  ", "سعر  ")),
                    Container(
                      decoration: decoration_border(fc_textfield_bg,
                          fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                      height: sy(28),
                      padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: ETssell,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          isDense: true,
                          hintText: ' ',
                          suffix: Text(
                            Const.CURRENCY,
                            style: ts_Regular(sy(s), fc_4),
                          ),
                          hintStyle: ts_Regular(sy(n), fc_4),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_2),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9\.-]")),
                          //..   1234..
                          FilteringTextInputFormatter.deny(
                            RegExp(r'\.\.+'),
                            replacementString: '.',
                          ),
                          // .23
                          FilteringTextInputFormatter.deny(
                            RegExp(r'^\.'),
                            replacementString: '0.',
                          ),
                          //.23423.
                          FilteringTextInputFormatter.deny(
                            RegExp(r'\.\d+\.'),
                          ),
                          // 12341234-
                          FilteringTextInputFormatter.deny(RegExp(r'\d+-')),
                          // .-
                          FilteringTextInputFormatter.deny(
                            RegExp(r'\.-'),
                            replacementString: '.',
                          ),
                          // -.34
                          FilteringTextInputFormatter.deny(RegExp(r'-\.+')),
                          // 0232
                          FilteringTextInputFormatter.deny(RegExp(r'^0\d+'))
                        ],
                        autofocus: false,
                        onChanged: (val) {
                          setState(() {
                            ssell = double.parse(val.toString());
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: sy(10),
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: GestureDetector(
                        onTap: () {
                          if (ETsname.text.toString() == '' ||
                              ETssell.text.toString() == '') {
                            ToastUtils.Error(
                                _scaffoldKey,
                                Lang('Please fill all details',
                                    "الرجاء ملء كافة التفاصيل"));
                          } else {
                            if (double.parse(ETssell.text.toString()) == 0) {
                              ToastUtils.Error(
                                  _scaffoldKey,
                                  Lang('Please check the price',
                                      "الرجاء التحقق من السعر"));
                            } else {
                              Navigator.of(context).pop(true);
                              addSize();
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(mcontext).size.width,
                          margin: EdgeInsets.all(sy(5)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(sy(5)),
                              color: Colors.green[500]),
                          child: Text(
                            Lang('Add Variant', "أضف المتغير"),
                            style: ts_Regular(sy(10), Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  _popsubCategory(BuildContext mcontext) {
    FocusScope.of(context).unfocus();
    List tempArray = [];
    for (int i = 0; i < Const.subcategoryList.length; i++) {
      if (Const.subcategoryList[i]['c_id'] == categoryID) {
        tempArray.add((Const.subcategoryList[i]));
      }
    }
    print(tempArray.toString());
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(sy(10)),
                topRight: Radius.circular(sy(10)),
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(0))),
        context: mcontext,
        builder: (mcontext) {
          return StatefulBuilder(
            builder: (mcontext, setStatee) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: sy(35),
                    child: ListTile(
                      title: Text(
                        Lang("Category", "فئة"),
                        textAlign: TextAlign.center,
                        style: ts_Regular(18, Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    top: sy(35),
                    left: 0,
                    right: 0,
                    bottom: sy(5),
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(mcontext).size.width,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: <Widget>[
                            for (int i = 0; i < tempArray.length; i++)
                              GestureDetector(
                                child: Container(
                                  width: Width(context) * 0.25,
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                          sy(0), sy(0), sy(0), sy(0)),
                                      margin: EdgeInsets.fromLTRB(
                                          sy(3), sy(3), sy(3), sy(3)),
                                      decoration: decoration_round(
                                          (subCategoryID ==
                                                  tempArray[i]['sc_id']
                                                      .toString())
                                              ? TheamPrimary
                                              : Colors.grey.shade200,
                                          sy(5),
                                          sy(5),
                                          sy(5),
                                          sy(5)),
                                      child: Column(
                                        children: [
                                          CustomeImageView(
                                            image: Urls.imageLocation +
                                                tempArray[i]['sc_image'],
                                            width: Width(context) * 0.25,
                                            height: Width(context) * 0.2,
                                            radius: sy(1),
                                            blurBackground: false,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(
                                            width: sy(8),
                                          ),
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                sy(3), sy(4), sy(3), sy(3)),
                                            child: Text(
                                              tempArray[i]['sc_title$cur_Lang'],
                                              style: ts_Regular(
                                                  sy(s),
                                                  (subCategoryID ==
                                                          tempArray[i]['sc_id']
                                                              .toString())
                                                      ? Colors.white
                                                      : fc_2),
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                                onTap: () {
                                  setState(() {
                                    subCategoryName =
                                        tempArray[i]['sc_title$cur_Lang'];
                                    subCategoryID =
                                        tempArray[i]['sc_id'].toString();
                                    Navigator.of(context).pop(true);
                                    FocusScope.of(context).unfocus();
                                  });
                                },
                              ),
                            SizedBox(
                              height: 20,
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

  colorSelection(BuildContext mcontext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Lang('Select a color', "اختر لونا")),
          content: SingleChildScrollView(
            child: MaterialPicker(
              pickerColor: currentColor,
              onColorChanged: changeColor,
              enableLabel: true,
            ),
          ),
        );
      },
    );
  }

  changeColor(Color color) {
    setState(() {
      currentColor = color;
      // addVarColor();
      Navigator.of(context).pop(true);
      print(currentColor);
      String hex = '${currentColor.value.toRadixString(16)}';
      String getCol = hex.substring(2);
      print(getCol);
      addVarColor(getCol);
    });
  }

  sizeCard(
      int i, String vid, String stitle, String smrp, String ssell, String qty) {
    return Container(
      // color: (i%2==0)?Colors.white:Colors.grey[50],
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(sy(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stitle,
            style: ts_Regular(sy(n), fc_2),
          ),
          SizedBox(
            height: sy(5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PriceUtils.convert(ssell),
                style: ts_Regular(sy(s), fc_3),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  _popEditSize(context, stitle, smrp, ssell, vid, qty);
                },
                child: Text(
                  Lang('EDIT', 'تعديل'),
                  style: ts_Regular(sy(9), Colors.blue[500]),
                ),
              ),
              SizedBox(
                width: sy(10),
              ),
              GestureDetector(
                onTap: () {
                  deleteVar(vid, 'size');
                },
                child: Text(
                  Lang('DELETE', 'حذف'),
                  style: ts_Regular(sy(9), Colors.red[500]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _popEditSize(BuildContext mcontext, String title, String mrp, String sell,
      String id, String qty) {
    ETsname.text = title;
    ETssell.text = sell;
    ETsqty.text = qty;

    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(0))),
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (mcontext, setState) {
              return Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      title: Text(Lang('Edit Size', "تعديل الحجم"),
                          textAlign: TextAlign.center),
                    ),
                    Divider(),
                    titleCard(Lang(" Variant Name ", " اسم المتغير ")),
                    Container(
                      decoration: decoration_border(fc_textfield_bg,
                          fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                      height: sy(28),
                      padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: ETsname,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          isDense: true,
                          hintText: ' ',
                          hintStyle: ts_Regular(sy(n), fc_4),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_2),
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                      ),
                    ),
                    SizedBox(
                      height: sy(20),
                      width: MediaQuery.of(context).size.width,
                    ),
                    titleCard(Lang(" Price ", "سعر  ")),
                    Container(
                      decoration: decoration_border(fc_textfield_bg,
                          fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                      height: sy(28),
                      padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: ETssell,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          isDense: true,
                          hintText: ' ',
                          suffix: Text(
                            Const.CURRENCY,
                            style: ts_Regular(sy(s), fc_4),
                          ),
                          hintStyle: ts_Regular(sy(n), fc_4),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_2),
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                        onChanged: (val) {
                          setState(() {
                            ssell = double.parse(val.toString());
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: sy(10),
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: GestureDetector(
                        onTap: () {
                          if (ETsname.text.toString() == '' ||
                              ETssell.text.toString() == '') {
                            ToastUtils.Error(
                                _scaffoldKey,
                                Lang('Please fill all details',
                                    "الرجاء ملء كافة التفاصيل"));
                          } else {
                            if (double.parse(ETssell.text.toString()) == 0) {
                              ToastUtils.Error(
                                  _scaffoldKey,
                                  Lang('Please check the price',
                                      "الرجاء التحقق من السعر"));
                            } else {
                              Navigator.of(context).pop(true);
                              updateSize(
                                  ETsname.text.toString(),
                                  ETssell.text.toString(),
                                  ETssell.text.toString(),
                                  ETsqty.text.toString(),
                                  id);
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(mcontext).size.width,
                          margin: EdgeInsets.all(sy(5)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(sy(5)),
                              color: Colors.green[500]),
                          child: Text(
                            Lang('Update', 'تحديث'),
                            style: ts_Regular(sy(10), Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  colorCard(int i, String vid, String scolor) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(sy(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: sy(20),
            height: sy(20),
            margin: EdgeInsets.fromLTRB(sy(0), 0, sy(8), 0),
            color: Color(int.parse("0xFF" + scolor)),
          ),
          Text(
            '#' + scolor,
            style: ts_Regular(sy(9), Colors.grey[700]),
          ),
          Expanded(
            child: SizedBox(
              height: sy(2),
            ),
          ),
          ElevatedButton(
            style: elevatedButton(Colors.grey.shade100, sy(5)),
            onPressed: () {
              deleteVar(vid, 'color');
            },
            child: Text(
              Lang('DELETE', 'حذف'),
              style: ts_Regular(sy(9), Colors.red[500]),
            ),
          ),
        ],
      ),
    );
  }

  _popUnit(BuildContext mcontext) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
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
                    height: 50,
                    child: ListTile(
                      title: Text(
                        Lang("Choose Product Unit", "اختر وحدة المنتج"),
                        textAlign: TextAlign.center,
                        style: ts_Regular(18, Colors.black),
                      ),
                      subtitle: Container(
                        height: 0.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(mcontext).size.width,
                        child: Wrap(
                          direction: Axis.horizontal,
                          runSpacing: 5,
                          spacing: 5,
                          children: <Widget>[
                            for (int i = 0; i < Const.unitArray.length; i++)
                              GestureDetector(
                                child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 3, 5, 3),
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    //   alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(sy(5)),
                                        border: Border.all(
                                            color: (quantityUnitInt ==
                                                    Const.unitArray[i]['id'])
                                                ? Colors.blue.shade800
                                                : Colors.grey.shade300,
                                            width: 1),
                                        color: (quantityUnitInt ==
                                                Const.unitArray[i]['id'])
                                            ? Colors.blue[50]
                                            : Colors.grey[50]),
                                    child: Text(
                                        Const.unitArray[i]['lable$cur_Lang'],
                                        style: ts_Regular(
                                            15,
                                            (quantityUnitInt ==
                                                    Const.unitArray[i]['id'])
                                                ? Colors.blue[800]
                                                : Colors.grey[800]))),
                                onTap: () {
                                  _setUnit(
                                      Const.unitArray[i]['id'],
                                      Const.unitArray[i]['lable'],
                                      Const.unitArray[i]['lable_arab']);
                                },
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

  _setUnit(String getId, String en, String ar) {
    setState(() {
      quantityUnitInt = getId;
      quantityUnit = en.toString();
      quantityUnitArab = ar.toString();
      Navigator.of(context).pop(true);
    });
  }

  _showPop() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text(Lang("Camera", "الكاميرا")),
                    onTap: () => {
                          getImageFile(ImageSource.camera),
                          Navigator.pop(context),
                        }),
                new ListTile(
                  leading: new Icon(Icons.image),
                  title: new Text(Lang("Gallery", "معرض الصور")),
                  onTap: () => {
                    getImageFile(ImageSource.gallery),
                    Navigator.pop(context),
                  },
                ),
              ],
            ),
          );
        });
  }

  ImageShow() {
    if (_image == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Image.asset(
          'assets/images/addimg.png',
          width: 110.0,
          height: 110.0,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(55.0),
        child: Image.file(
          finalImage,
          width: 110.0,
          height: 110.0,
          fit: BoxFit.fill,
        ),
      );
    }
  }

  getImageFile(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source, imageQuality: 80);

    final img = ImageCropper();
    CroppedFile? croppedFile = await img.cropImage(
      sourcePath: image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
      ],
      compressQuality: 60,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: Const.AppName,
            toolbarColor: TheamPrimary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: Const.AppName,
        ),
      ],
      maxWidth: 1024,
      maxHeight: 700,
    );
    setState(() {
      _image = croppedFile;
      imagepath = croppedFile;
      finalImage = File(_image!.path);
    });
    _UpdateImageMultipart(finalImage);
  }

  showSingleOrMultiPop(String variable) {
    FocusScope.of(context).unfocus();
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
            child: Wrap(
              direction: Axis.vertical,
              runSpacing: 5,
              spacing: 5,
              children: <Widget>[
                SizedBox(
                  height: sy(10),
                ),
                Text(
                  Lang("Choose yes or No  ", " اختر نعم أو لا "),
                  textAlign: TextAlign.center,
                  style: ts_Regular(18, Colors.black),
                ),
                SizedBox(
                  height: sy(10),
                ),
                for (int i = 0; i < Const.saleType.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                        width: Width(context),
                        margin: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                        padding:
                            EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                        //   alignment: Alignment.center,

                        child: Text(Const.saleType[i]['label$cur_Lang'],
                            style: ts_Regular(sy(n), Colors.grey[800]))),
                    onTap: () {
                      setState(() {
                        if (variable == 'purchase') {
                          singlePurchase = Const.saleType[i]['id'];
                        }
                        if (variable == 'quantity') {
                          multiQuantity = Const.saleType[i]['id'];
                        }
                        if (variable == 'used') {
                          usedProduct = Const.saleType[i]['id'];
                        }
                        Navigator.of(context).pop();
                      });
                    },
                  ),
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
            ETaddress.text = mapAddress;

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
