import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:sevenemirates/components/country.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/helper.dart';
import 'package:sevenemirates/components/progress_button.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/router/left_open_screen.dart';
import 'package:sevenemirates/screen/registration/otp_screen.dart';
import 'package:sevenemirates/screen/user/dashboard.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../router/open_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  String starting;
  PhoneNumberScreen({Key? key, this.starting = "0"}) : super(key: key);
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  Map? data = Map();
  List productList = [];
  String? UserId;
  ScrollController _scrollController = ScrollController();
  TextEditingController ETphone = TextEditingController();
  TextEditingController ETemail = TextEditingController();
  bool vphone = false;
  String myOTP = randomNumeric(5);
  String countryName = World.Countries[228]['name'];
  String countryNameArab = World.Countries[228]['name'];
  String countryCodeint = World.Countries[228]['phoneCode'].toString();
  String countryId = World.Countries[228]['id'].toString();
  String countryFlag =
      World.Countries[228]['sortname'].toString().toLowerCase() + '.png';
  // String cscreen='';
  String errorMsg = '';

  late PageController pageController;

  bool _keyboardVisible = false;

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserId = prefs.getString(Const.UID) ?? '';
    });
  }

/*
  _sendOTPOld() async {
    String mynum = ETphone.text;
    String myMsg;
    // myMsg= "*${Const.AppName}*\n\nWelcome to ${Const.AppName}. Your OTP is : *$myOTP*\n\nThanks for using ${Const.AppName}.";
    myMsg =
        "$myOTP is your OTP for ${Const.AppName} Application Login. Thanks for using ${Const.AppName}";

    // String whatsappUrl="https://whatsapp.myappstores.com/api/sendText?token="+Const.WHATSAPP_TOKEN+"&phone=$countryCodeint$mynum&message=$myMsg";
    // String whatsappUrl = "https://smpplive.com/api/send_sms/single_sms?to=$contry_code$mynum&${Const.SMSGATEWAY}&content=$myMsg";
    String whatsappUrl =
        "https://app.rivet.solutions/api/v2/SendSMS?ApiKey=${Const.SMSGATEWAY}&Message=$myMsg&MobileNumbers=$contry_code$mynum";

    final response = await http.get(Uri.parse(whatsappUrl.toString()),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER});

    data = json.decode(response.body);
    setState(() {});

    SharedStoreUtils.setValue(Const.OTP, myOTP);
    Navigator.pushReplacement(
        context,
        LeftOpenScreen(
            widget: OtpScreen(
          getPhone: ETphone.text.toString(),
          getEmail: ETemail.text.toString(),
          getCountry: countryName,
          getCountryArab: countryNameArab,
          getCountryCode: countryCodeint,
          starting: widget.starting,
        )));
  }
*/
  _sendOTP() async {
    String myNum =
        ETphone.text.startsWith('0') ? ETphone.text.substring(1) : ETphone.text;
    String myMsg;
    // myMsg= "*${Const.AppName}*\n\nWelcome to ${Const.AppName}. Your OTP is : *$myOTP*\n\nThanks for using ${Const.AppName}.";
    myMsg = Lang(
        "$myOTP is your OTP for ${Const.AppName} Application Login. Thanks for using ${Const.AppName}",
        "$myOTP هو OTP الخاص بك لتسجيل الدخول إلى تطبيق ${Const.AppName}. شكرا لاستخدام ${Const.AppName}");

    // String whatsappUrl="https://whatsapp.myappstores.com/api/sendText?token="+Const.WHATSAPP_TOKEN+"&phone=$countryCodeint$mynum&message=$myMsg";
    // String whatsappUrl="https://smpplive.com/api/send_sms/single_sms?to=$contry_code$mynum&${Const.SMSGATEWAY}&content=$myMsg";

    String whatsappUrl =
        "https://app.rivet.solutions/api/v2/SendSMS?ApiKey=${Const.SMSGATEWAY}&Message=$myMsg&MobileNumbers=$contry_code$myNum";
    await SendCodeHelper.instance.sendPhoneCode(
      onCodeSend: (verificationId) {
        Navigator.push(
            context,
            LeftOpenScreen(
                widget: OtpScreen(
              verificationId: verificationId,
              countryId: countryId,
              getPhone: myNum,
              getEmail: ETemail.text.toString(),
              getCountry: countryName,
              getCountryArab: countryNameArab,
              getCountryCode: countryCodeint,
              starting: widget.starting,
            )));
      },
      phoneNumber: '+$countryCodeint$myNum',
    );
    log('dklkl');
    apiTest(Uri.parse(whatsappUrl).toString());

    // final response = await http.get(Uri.parse(whatsappUrl.toString()),
    //     headers: {HttpHeaders.acceptHeader: Const.POSTHEADER});

    // data = json.decode(response.body);
    // setState(() {});
    // log('your data is ${data}');
    // Fluttertoast.showToast(
    //   msg: myOTP,
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.CENTER,
    // );
    SharedStoreUtils.setValue(Const.OTP, myOTP);
    SharedStoreUtils.setValue(Const.COUNTRY_CODE, countryCodeint);
    SharedStoreUtils.setValue(Const.COUNTRY_NAME, countryName);
    SharedStoreUtils.setValue(Const.COUNTRY_NAME_ARAB, countryNameArab);
    SharedStoreUtils.setValue(Const.COUNTRY_FLAG, countryFlag);
    Provider.of<AppSetting>(context, listen: false).country = countryName;
    Provider.of<AppSetting>(context, listen: false).countryId = countryCodeint;
    // TODO : add replacement push

    // Navigator.push(
    //     context,
    //     LeftOpenScreen(
    //         widget: OtpScreen(
    //       countryId: countryId,
    //       getPhone: ETphone.text.toString(),
    //       getEmail: ETemail.text.toString(),
    //       getCountry: countryName,
    //       getCountryArab: countryNameArab,
    //       getCountryCode: countryCodeint,
    //       starting: widget.starting,
    //     )));
  }

  _checkEmail() async {
    setState(() {
      showProgress = true;
    });
    var getUserEmail = Urls.GetUserEmail;
    var body2 = {
      "key": Const.APPKEY,
      "email": ETemail.text.toString(),
    };
    log('$getUserEmail $body2');
    final response = await http.post(Uri.parse(getUserEmail),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body2);

    data = json.decode(response.body);
    setState(() {
      showProgress = false;
    });
    log('data $data');
    setState(() {
      if (data!["success"] == true) {
        if (data!["old"] == true) {
          errorMsg = '';
          //   Pop.successTop(context, 'Send OTP', Icons.email_outlined);
          _sendEMail();
        } else {
          errorMsg = Lang(" Email not registered with us ",
              " البريد الإلكتروني غير مسجل معنا ");
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              errorMsg = '';
            });
          });
        }
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _sendEMail() async {
    setState(() {
      showProgress = true;
    });

    // final smtpServer = gmail(Const.OTPEMAIL, Const.OTPEMAIL_PASSWORD);
    // final equivalentMessage = Message()
    //   ..from = Address(Const.OTPEMAIL, 'Trends Research & Advisory')
    //   ..recipients.add(Address(ETemail.text.toString()))
    //   ..subject = '${myOTP} is your OTP'
    //   ..text = 'Trends Research & Advisory\n${myOTP} is your OTP for Login'
    //   ..html =
    //       "<h1>Trends Research</h1>\n<p>${myOTP} is your OTP for Login</p>";

    try {
      // final sendReport = await send(equivalentMessage, smtpServer);
      var isSent = await SendCodeHelper.instance.sendEmailApi(
        email: ETemail.text,
      );
      if (!isSent) {
        return;
      }
      Navigator.pushReplacement(
          context,
          LeftOpenScreen(
              widget: OtpScreen(
            countryId: countryId,
            getPhone: ETphone.text.toString(),
            getEmail: ETemail.text.toString(),
            getCountry: countryName,
            getCountryArab: countryNameArab,
            getCountryCode: countryCodeint,
            starting: widget.starting,
          )));
    } on MailerException catch (e) {}

    setState(() {
      showProgress = false;
    });
  }

  showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 250,
            child: Column(
              children: <Widget>[
                Image.asset(
                  Urls.DummyLogo,
                  width: 150,
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(Lang(
                    "Request Successfully loaded", "تم تحميل الطلب بنجاح")),
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.green[700]),
                  ),
                  child: Text(
                    Lang("Ok", "حسنا"),
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: (widget.starting == '0') ? 1 : 0,
      keepPage: true,
    );
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initRelativeScaler(context);
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
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
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                // key: _scaffoldKey,
                //   resizeToAvoidBottomPadding: false,
                body: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  width: Width(context),
                  height: Height(context),
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: [
                      welcomeWidget(),
                      phoneWidget(),
                      emailWidget(),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  welcomeWidget() {
    return Container(
      height: Height(context),
      width: Width(context),
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          Positioned(
            top: sy(0),
            bottom: sy(0),
            left: 0,
            right: 0,
            child: Container(
              width: Width(context),
              height: Height(context),
              child: Image.asset(
                'assets/images/bg.jpg',
                width: Width(context),
                height: Height(context),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: Width(context),
              height: Height(context),
              padding: EdgeInsets.fromLTRB(sy(20), sy(30), sy(20), sy(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: Width(context) * 0.3,
                    height: Height(context) * 0.2,
                    fit: BoxFit.contain,
                  ),
                  Spacer(),
                  Text(
                    Lang(" POST AD\nSELL ANYTIME ",
                        " انشر الإعلان \n قم بالبيع في أي وقت "),
                    style: TextStyle(
                        color: fc_1,
                        fontSize: sy(xxl),
                        fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: sy(8),
                  ),
                  Text(
                    'Nam libus magnimi, quam\nquas voluptas acearios alia omni',
                    style: ts_Regular(sy(n), fc_1),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: sy(15),
                  ),
                  ElevatedButton(
                      style: elevatedButton(TheamPrimary, sy(5)),
                      onPressed: () {
                        setState(() {
                          pageController.animateToPage(1,
                              duration: Duration(milliseconds: 700),
                              curve: Curves.linear);
                        });
                      },
                      child: Container(
                        width: Width(context) * 0.6,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.fromLTRB(sy(10), sy(10), sy(0), sy(10)),
                        //  decoration: decoration_round(TheamPrimary, sy(20), sy(20), sy(20), sy(20)),
                        child: Text(
                          Lang(" Let's Go ", " لنذهب "),
                          style: ts_Regular(sy(n), fc_bg),
                        ),
                      )),
                  SizedBox(
                    height: sy(15),
                  ),
                ],
              ),
            ),
          ),
          if (widget.starting == "0")
            Positioned(
              top: sy(15),
              right: sy(5),
              child: Container(
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: sy(xl),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  phoneWidget() {
    return Container(
      decoration: BoxDecoration(color: Color(0xFFEDEDED)),
      width: MediaQuery.of(context).size.width,
      height: Height(context),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), sy(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: sy(50),
                  ),
                  Text(
                    Lang("Enter your\nphone number  ", " أدخل رقم هاتفك \n "),
                    style: ts_Bold(sy(l), fc_2),
                  ),
                  SizedBox(
                    height: sy(8),
                  ),
                  Text(
                    Lang(
                        " To login, you have to enter your phone number \nto get OTP ",
                        " لتسجيل الدخول ، يجب عليك إدخال رقم هاتفك \n للحصول على OTP "),
                    style: ts_Regular(sy(s), fc_5),
                  ),
                  SizedBox(
                    height: sy(20),
                  ),
                  Container(
                    decoration: decoration_border(
                        TheamBG, TheamBG, sy(1), sy(5), sy(5), sy(5), sy(5)),
                    padding: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Container(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/flag/' + countryFlag,
                                  width: sy(22),
                                  height: sy(22),
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  width: sy(4),
                                ),
                                Text(
                                  countryCodeint,
                                  style: ts_Bold(sy(n), fc_4),
                                  textAlign: TextAlign.left,
                                ),
                                // SizedBox(
                                //   width: sy(1),
                                // ),
                                // Icon(
                                //   Icons.arrow_drop_down,
                                //   size: sy(xl),
                                //   color: fc_2,
                                // )
                              ],
                            ),
                          ),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _popCountry();
                            //  _popCountry();
                          },
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        Expanded(
                          child: TextField(
                            controller: ETphone,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                                // counter: Offstage(),
                                hintText: '000000000',
                                hintStyle: ts_Regular_spaced(sy(l), fc_5, 5),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                isDense: false),
                            style: ts_Regular_spaced(sy(l), fc_2, 5),
                            textInputAction: TextInputAction.done,
                            onChanged: (vsl) {
                              setState(() {});
                            },
                            autofocus: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: sy(15),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        SharedStoreUtils.setValue(Const.SKIP_SIGNUP_VALUE, '1');
                        Provider.of<AppSetting>(context, listen: false)
                            .skipSignup = '1';
                        Provider.of<AppSetting>(context, listen: false).uid =
                            '0';
                        Navigator.pushReplacement(
                            context, OpenScreen(widget: Dashboard()));
                      });
                    },
                    child: Text(
                      Lang(" Skip Login ", " تخطي تسجيل الدخول "),
                      style: ts_Regular(sy(s), fc_5),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    height: sy(10),
                  ),
                  GestureDetector(
                    onTap: () {
                      UrlOpenUtils.openurl(
                          _scaffoldKey, 'https://7emiratesapp.ae/terms.php');

                      // _popTerms();
                    },
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        Text(
                          Lang(
                              "By entering phone number, you should accept our   ",
                              " عن طريق إدخال رقم الهاتف ، يجب عليك قبول "),
                          style: ts_Regular(sy(s), fc_3),
                        ),
                        SizedBox(
                          width: sy(3),
                        ),
                        Text(
                          Lang(" Terms and Conditions ", " الشروط والأحكام "),
                          style: ts_Bold(sy(s), fc_3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: sy(15),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: elevatedButtonBorder(TheamPrimary, sy(30)),
                        onPressed: () {
                          if (ETphone.text.length >= 9) {
                            _openOTPScreen();
                          } else {
                            Pop.errorTop(
                                context,
                                Lang(" Please Enter Phone number ",
                                    " الرجاء إدخال رقم الهاتف "),
                                Icons.warning);
                          }
                        },
                        child: ProgressButton(
                          showProgress: showProgress,
                          bttxtcolor: ETphone.text.length >= 9
                              ? TheamPrimary
                              : TheamPrimary.withOpacity(0.5),
                          bttext: Lang(" Send OTP ", "أرسل OTP  "),
                          btwidth: sy(70),
                          btheight: sy(35),
                        ),
                      ),
                      Spacer(),
                      if (_keyboardVisible == false)
                        GestureDetector(
                          child: Container(
                              // width: Width(context)*0.6,
                              padding: EdgeInsets.fromLTRB(
                                  sy(5), sy(8), sy(5), sy(8)),
                              //     decoration: decoration_round(fc_3, sy(5), sy(5), sy(5), sy(5)),
                              //alignment: Alignment.center,
                              child: Text(
                                Lang(" LOGIN WITH EMAIL ",
                                    " تسجيل الدخول بالبريد الإلكتروني "),
                                style: ts_Regular(sy(s), fc_3),
                              )),
                          onTap: () {
                            setState(() {
                              // cscreen='email';
                              pageController.animateToPage(2,
                                  duration: Duration(milliseconds: 700),
                                  curve: Curves.linear);
                            });
                          },
                        ),
                    ],
                  ),
                  SizedBox(
                    height: sy(20),
                  ),
                ],
              ),
            ),
          ),
          if (widget.starting == "0")
            Positioned(
              top: sy(20),
              right: sy(5),
              child: Container(
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: sy(xl),
                    color: fc_1,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            )
        ],
      ),
    );
  }

  emailWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Height(context),
      decoration: BoxDecoration(color: Color(0xFFEDEDED)),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), sy(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: sy(50),
                  ),
                  Text(
                    Lang(
                        " Your Registered Email ", " بريدك الإلكتروني المسجل "),
                    style: ts_Bold(sy(l), fc_2),
                  ),
                  SizedBox(
                    height: sy(5),
                  ),
                  Text(
                    Lang("please enter registered email address  ",
                        " الرجاء إدخال عنوان البريد الإلكتروني المسجل "),
                    style: ts_Regular(sy(s), fc_3),
                  ),
                  SizedBox(
                    height: sy(15),
                  ),
                  Container(
                      height: sy(30),
                      decoration: decoration_border(
                          TheamBG, TheamBG, sy(1), sy(5), sy(5), sy(5), sy(5)),
                      padding: EdgeInsets.fromLTRB(sy(0), sy(0), sy(3), sy(0)),
                      child: TextField(
                        controller: ETemail,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            // counter: Offstage(),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              size: sy(l),
                              color: fc_2,
                            ),
                            hintText: Lang(
                                " Email address ", "عنوان البريد الالكترونى  "),
                            hintStyle: ts_Regular(sy(l), fc_4),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none,
                            isDense: false),
                        style: ts_Regular(sy(l), fc_2),
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                      )),
                  Spacer(),
                  Row(
                    children: [
                      ElevatedButton(
                        style: elevatedButtonBorder(TheamPrimary, sy(30)),
                        onPressed: () {
                          if (ETemail.text != '') {
                            _checkEmail();
                          } else {
                            Pop.errorTop(
                                context,
                                Lang(" Enter valid email address ",
                                    " أدخل عنوان بريد إلكتروني صالح "),
                                Icons.warning);
                          }
                        },
                        child: ProgressButton(
                          showProgress: showProgress,
                          bttxtcolor: TheamPrimary,
                          bttext: Lang("Send OTP  ", "إرسال OTP  "),
                          btwidth: sy(70),
                          btheight: sy(35),
                        ),
                      ),
                      Spacer(),
                      if (_keyboardVisible == false)
                        GestureDetector(
                          child: Container(
                              // width: Width(context)*0.6,
                              padding: EdgeInsets.fromLTRB(
                                  sy(0), sy(8), sy(12), sy(8)),
                              //     decoration: decoration_round(fc_3, sy(5), sy(5), sy(5), sy(5)),
                              //alignment: Alignment.center,
                              child: Text(
                                Lang("LOGIN WITH PHONE  ",
                                    "تسجيل الدخول عبر الهاتف  "),
                                style: ts_Regular(sy(s), fc_3),
                              )),
                          onTap: () {
                            setState(() {
                              pageController.animateToPage(1,
                                  duration: Duration(milliseconds: 700),
                                  curve: Curves.linear);
                            });
                          },
                        ),
                      SizedBox(
                        height: sy(5),
                      ),
                      if (errorMsg != '')
                        Text(
                          errorMsg,
                          style: ts_Regular(sy(s), Colors.red),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: sy(20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _openOTPScreen() {
    if (ETphone.text != '') {
      _sendOTP();
    } else {
      Pop.successTop(
          context,
          Lang('Enter phone number \nPhone number field should not empty',
              'أدخل رقم الهاتف \nيجب ألا يكون حقل رقم الهاتف فارغًا'),
          Icons.phone);
    }
  }

  _popCountry() {
    TextEditingController ETsearch = TextEditingController();
    List countryList = World.Countries;
    List filterCountryList = countryList;
    String keyy = 'def';
    // log('list $filterCountryList');

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: Width(context), maxHeight: Width(context)),
          child: Material(
            color: fc_bg,
            child: SafeArea(
              child: Container(
                height: Height(context),
                width: Width(context),
                color: fc_bg,
                child: Container(
                  child: SafeArea(
                    child: StatefulBuilder(
                      builder: (mcontext, setState) {
                        return Stack(
                          children: [
                            Positioned(
                              top: sy(45),
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: SingleChildScrollView(
                                child: Container(
                                  width: Width(context),
                                  child: Wrap(
                                    children: <Widget>[
                                      for (int i = 0;
                                          i < filterCountryList.length;
                                          i++)
                                        GestureDetector(
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          sy(0)),
                                                  child: Image.asset(
                                                    "assets/images/flag/" +
                                                        filterCountryList[i]
                                                                ['sortname']
                                                            .toString()
                                                            .toLowerCase() +
                                                        '.png',
                                                    width: sy(25),
                                                    height: sy(20),
                                                    errorBuilder: (context,
                                                            exception,
                                                            stackTrack) =>
                                                        Icon(
                                                      Icons.flag,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: sy(8),
                                                ),
                                                Container(
                                                  width: sy(25),
                                                  child: Text(
                                                    filterCountryList[i]
                                                            ['phoneCode']
                                                        .toString(),
                                                    style: ts_Bold(sy(s), fc_2),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: sy(8),
                                                ),
                                                Expanded(
                                                    child: Text(
                                                  Lang(
                                                      filterCountryList[i]
                                                          ['name'],
                                                      filterCountryList[i]
                                                          ['name']),
                                                  style:
                                                      ts_Regular(sy(n), fc_2),
                                                ))
                                              ],
                                            ),
                                            width: Width(context),
                                            padding: EdgeInsets.fromLTRB(
                                                sy(10), sy(5), sy(8), sy(5)),
                                          ),
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            _setCountry(
                                              code: filterCountryList[i]
                                                      ['phoneCode']
                                                  .toString(),
                                              eng: filterCountryList[i]['name'],
                                              ara: filterCountryList[i]['name'],
                                              img: filterCountryList[i]
                                                          ['sortname']
                                                      .toString()
                                                      .toLowerCase() +
                                                  '.png',
                                              countryId: filterCountryList[i]
                                                      ['id']
                                                  .toString(),
                                            );
                                          },
                                        ),
                                      SizedBox(
                                        height: sy(30),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: sy(10),
                              left: sy(10),
                              right: sy(10),
                              height: sy(30),
                              child: Container(
                                decoration: decoration_border(fc_bg, fc_4,
                                    sy(1), sy(5), sy(5), sy(5), sy(5)),
                                height: sy(35),
                                padding: EdgeInsets.fromLTRB(
                                    sy(10), sy(5), sy(5), sy(5)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: sy(30),
                                        //decoration: decoration_border(fc_bg,fc_4, sy(1), sy(5), sy(5), sy(5), sy(5)),
                                        padding: EdgeInsets.fromLTRB(
                                            sy(0), sy(0), sy(3), sy(0)),
                                        child: TextField(
                                          controller: ETsearch,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textAlign: TextAlign.left,
                                          decoration: InputDecoration(
                                              // counter: Offstage(),
                                              hintText:
                                                  Lang("Search  ", "بحث  "),
                                              hintStyle:
                                                  ts_Regular(sy(n), fc_4),
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              border: InputBorder.none,
                                              isDense: false),
                                          style: ts_Regular(sy(l), fc_2),
                                          textInputAction: TextInputAction.done,
                                          autofocus: false,
                                          onChanged: (val) {
                                            setState(() {
                                              List tempArr = [];
                                              for (int i = 0;
                                                  i < countryList.length;
                                                  i++) {
                                                if (countryList[i]['name']
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(
                                                        val.toLowerCase())) {
                                                  tempArr.add(countryList[i]);
                                                }
                                              }
                                              filterCountryList = tempArr;

                                              // filterCity = cityList.where((u) => (u.name.toLowerCase().contains(val.toLowerCase()) ||
                                              //     u.phonecode.toLowerCase().contains(val.toLowerCase())))
                                              //     .toList();

                                              keyy = val;
                                            });
                                          },
                                        ),
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        size: sy(xl),
                                        color: fc_2,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, true ? -1 : 1), end: Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
    );
  }

  _setCountry({
    required String code,
    required String eng,
    required String ara,
    required String img,
    required String countryId,
  }) {
    setState(() {
      countryName = eng;
      this.countryId = countryId;
      countryCodeint = code;
      countryNameArab = ara;
      countryFlag = img;
      contry_code = code;
      SharedStoreUtils.setValue(Const.COUNTRY_CODE, code);
      SharedStoreUtils.setValue(Const.COUNTRY_NAME, countryName);
      SharedStoreUtils.setValue(Const.COUNTRY_NAME_ARAB, countryNameArab);
      SharedStoreUtils.setValue(Const.COUNTRY_FLAG, countryFlag);
      Provider.of<AppSetting>(context, listen: false).country = countryName;
      Provider.of<AppSetting>(context, listen: false).countryId = code;
      log('text is ${ETphone.text}');
      Navigator.of(context).pop(true);
    });
  }

  /*_popTerms() {
    var htmlData = """
    
    <h1>End-User License Agreement (&quot;Agreement&quot;)</h1>
<p>Last updated: March 28, 2022</p>
<p>Please read this End-User License Agreement carefully before clicking the &quot;I Agree&quot; button, downloading or using 7Emirates.</p>
<h1>Interpretation and Definitions</h1>
<h2>Interpretation</h2>
<p>The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.</p>
<h2>Definitions</h2>
<p>For the purposes of this End-User License Agreement:</p>
<ul>
<li>
<p><strong>Agreement</strong> means this End-User License Agreement that forms the entire agreement between You and the Company regarding the use of the Application.</p>
</li>
<li>
<p><strong>Application</strong> means the software program provided by the Company downloaded by You to a Device, named 7Emirates</p>
</li>
<li>
<p><strong>Company</strong> (referred to as either &quot;the Company&quot;, &quot;We&quot;, &quot;Us&quot; or &quot;Our&quot; in this Agreement) refers to 7Emirates.</p>
</li>
<li>
<p><strong>Content</strong> refers to content such as text, images, or other information that can be posted, uploaded, linked to or otherwise made available by You, regardless of the form of that content.</p>
</li>
<li>
<p><strong>Country</strong> refers to:  United Arab Emirates</p>
</li>
<li>
<p><strong>Device</strong> means any device that can access the Application such as a computer, a cellphone or a digital tablet.</p>
</li>
<li>
<p><strong>Third-Party Services</strong> means any services or content (including data, information, applications and other products services) provided by a third-party that may be displayed, included or made available by the Application.</p>
</li>
<li>
<p><strong>You</strong> means the individual accessing or using the Application or the company, or other legal entity on behalf of which such individual is accessing or using the Application, as applicable.</p>
</li>
</ul>
<h1>Acknowledgment</h1>
<p>By clicking the &quot;I Agree&quot; button, downloading or using the Application, You are agreeing to be bound by the terms and conditions of this Agreement. If You do not agree to the terms of this Agreement, do not click on the &quot;I Agree&quot; button, do not download or do not use the Application.</p>
<p>This Agreement is a legal document between You and the Company and it governs your use of the Application made available to You by the Company.</p>
<p>The Application is licensed, not sold, to You by the Company for use strictly in accordance with the terms of this Agreement.</p>
<h1>License</h1>
<h2>Scope of License</h2>
<p>The Company grants You a revocable, non-exclusive, non-transferable, limited license to download, install and use the Application strictly in accordance with the terms of this Agreement.</p>
<p>The license that is granted to You by the Company is solely for your personal, non-commercial purposes strictly in accordance with the terms of this Agreement.</p>
<h1>Third-Party Services</h1>
<p>The Application may display, include or make available third-party content (including data, information, applications and other products services) or provide links to third-party websites or services.</p>
<p>You acknowledge and agree that the Company shall not be responsible for any Third-party Services, including their accuracy, completeness, timeliness, validity, copyright compliance, legality, decency, quality or any other aspect thereof. The Company does not assume and shall not have any liability or responsibility to You or any other person or entity for any Third-party Services.</p>
<p>You must comply with applicable Third parties' Terms of agreement when using the Application. Third-party Services and links thereto are provided solely as a convenience to You and You access and use them entirely at your own risk and subject to such third parties' Terms and conditions.</p>
<h1>Term and Termination</h1>
<p>This Agreement shall remain in effect until terminated by You or the Company.
The Company may, in its sole discretion, at any time and for any or no reason, suspend or terminate this Agreement with or without prior notice.</p>
<p>This Agreement will terminate immediately, without prior notice from the Company, in the event that you fail to comply with any provision of this Agreement. You may also terminate this Agreement by deleting the Application and all copies thereof from your Device or from your computer.</p>
<p>Upon termination of this Agreement, You shall cease all use of the Application and delete all copies of the Application from your Device.</p>
<p>Termination of this Agreement will not limit any of the Company's rights or remedies at law or in equity in case of breach by You (during the term of this Agreement) of any of your obligations under the present Agreement.</p>
<h1>Indemnification</h1>
<p>You agree to indemnify and hold the Company and its parents, subsidiaries, affiliates, officers, employees, agents, partners and licensors (if any) harmless from any claim or demand, including reasonable attorneys' fees, due to or arising out of your: (a) use of the Application; (b) violation of this Agreement or any law or regulation; or (c) violation of any right of a third party.</p>
<h1>No Warranties</h1>
<p>The Application is provided to You &quot;AS IS&quot; and &quot;AS AVAILABLE&quot; and with all faults and defects without warranty of any kind. To the maximum extent permitted under applicable law, the Company, on its own behalf and on behalf of its affiliates and its and their respective licensors and service providers, expressly disclaims all warranties, whether express, implied, statutory or otherwise, with respect to the Application, including all implied warranties of merchantability, fitness for a particular purpose, title and non-infringement, and warranties that may arise out of course of dealing, course of performance, usage or trade practice. Without limitation to the foregoing, the Company provides no warranty or undertaking, and makes no representation of any kind that the Application will meet your requirements, achieve any intended results, be compatible or work with any other software, applications, systems or services, operate without interruption, meet any performance or reliability standards or be error free or that any errors or defects can or will be corrected.</p>
<p>Without limiting the foregoing, neither the Company nor any of the company's provider makes any representation or warranty of any kind, express or implied: (i) as to the operation or availability of the Application, or the information, content, and materials or products included thereon; (ii) that the Application will be uninterrupted or error-free; (iii) as to the accuracy, reliability, or currency of any information or content provided through the Application; or (iv) that the Application, its servers, the content, or e-mails sent from or on behalf of the Company are free of viruses, scripts, trojan horses, worms, malware, timebombs or other harmful components.</p>
<p>Some jurisdictions do not allow the exclusion of certain types of warranties or limitations on applicable statutory rights of a consumer, so some or all of the above exclusions and limitations may not apply to You. But in such a case the exclusions and limitations set forth in this section shall be applied to the greatest extent enforceable under applicable law. To the extent any warranty exists under law that cannot be disclaimed, the Company shall be solely responsible for such warranty.</p>
<h1>Limitation of Liability</h1>
<p>Notwithstanding any damages that You might incur, the entire liability of the Company and any of its suppliers under any provision of this Agreement and your exclusive remedy for all of the foregoing shall be limited to the amount actually paid by You for the Application or through the Application or 100 USD if You haven't purchased anything through the Application.</p>
<p>To the maximum extent permitted by applicable law, in no event shall the Company or its suppliers be liable for any special, incidental, indirect, or consequential damages whatsoever (including, but not limited to, damages for loss of profits, loss of data or other information, for business interruption, for personal injury, loss of privacy arising out of or in any way related to the use of or inability to use the Application, third-party software and/or third-party hardware used with the Application, or otherwise in connection with any provision of this Agreement), even if the Company or any supplier has been advised of the possibility of such damages and even if the remedy fails of its essential purpose.</p>
<p>Some states/jurisdictions do not allow the exclusion or limitation of incidental or consequential damages, so the above limitation or exclusion may not apply to You.</p>
<h1>Severability and Waiver</h1>
<h2>Severability</h2>
<p>If any provision of this Agreement is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.</p>
<h2>Waiver</h2>
<p>Except as provided herein, the failure to exercise a right or to require performance of an obligation under this Agreement shall not effect a party's ability to exercise such right or require such performance at any time thereafter nor shall the waiver of a breach constitute a waiver of any subsequent breach.</p>
<h1>Product Claims</h1>
<p>The Company does not make any warranties concerning the Application.</p>
<h1>United States Legal Compliance</h1>
<p>You represent and warrant that (i) You are not located in a country that is subject to the United States government embargo, or that has been designated by the United States government as a &quot;terrorist supporting&quot; country, and (ii) You are not listed on any United States government list of prohibited or restricted parties.</p>
<h1>Changes to this Agreement</h1>
<p>The Company reserves the right, at its sole discretion, to modify or replace this Agreement at any time. If a revision is material we will provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at the sole discretion of the Company.</p>
<p>By continuing to access or use the Application after any revisions become effective, You agree to be bound by the revised terms. If You do not agree to the new terms, You are no longer authorized to use the Application.</p>
<h1>Governing Law</h1>
<p>The laws of the Country, excluding its conflicts of law rules, shall govern this Agreement and your use of the Application. Your use of the Application may also be subject to other local, state, national, or international laws.</p>
<h1>Entire Agreement</h1>
<p>The Agreement constitutes the entire agreement between You and the Company regarding your use of the Application and supersedes all prior and contemporaneous written or oral agreements between You and the Company.</p>
<p>You may be subject to additional terms and conditions that apply when You use or purchase other Company's services, which the Company will provide to You at the time of such use or purchase.</p>
 <strong>Terms &amp; Conditions</strong> <p>
                  By downloading or using the app, these terms will
                  automatically apply to you – you should make sure therefore
                  that you read them carefully before using the app. You’re not
                  allowed to copy or modify the app, any part of the app, or
                  our trademarks in any way. You’re not allowed to attempt to
                  extract the source code of the app, and you also shouldn’t try
                  to translate the app into other languages or make derivative
                  versions. The app itself, and all the trademarks, copyright,
                  database rights, and other intellectual property rights related
                  to it, still belong to 7Emirates.
                </p> <p>
                  7Emirates is committed to ensuring that the app is
                  as useful and efficient as possible. For that reason, we
                  reserve the right to make changes to the app or to charge for
                  its services, at any time and for any reason. We will never
                  charge you for the app or its services without making it very
                  clear to you exactly what you’re paying for.
                </p> <p>
                  The 7Emirates app stores and processes personal data that
                  you have provided to us, to provide my
                  Service. It’s your responsibility to keep your phone and
                  access to the app secure. We therefore recommend that you do
                  not jailbreak or root your phone, which is the process of
                  removing software restrictions and limitations imposed by the
                  official operating system of your device. It could make your
                  phone vulnerable to malware/viruses/malicious programs,
                  compromise your phone’s security features and it could mean
                  that the 7Emirates app won’t work properly or at all.
                </p> <div><p>
                    The app does use third-party services that declare their
                    Terms and Conditions.
                  </p> <p>
                    Link to Terms and Conditions of third-party service
                    providers used by the app
                  </p> <ul> <!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></ul></div> <p>
                  You should be aware that there are certain things that
                  7Emirates will not take responsibility for. Certain
                  functions of the app will require the app to have an active
                  internet connection. The connection can be Wi-Fi or provided
                  by your mobile network provider, but 7Emirates
                  cannot take responsibility for the app not working at full
                  functionality if you don’t have access to Wi-Fi, and you don’t
                  have any of your data allowance left.
                </p> <p></p> <p>
                  If you’re using the app outside of an area with Wi-Fi, you
                  should remember that the terms of the agreement with your
                  mobile network provider will still apply. As a result, you may
                  be charged by your mobile provider for the cost of data for
                  the duration of the connection while accessing the app, or
                  other third-party charges. In using the app, you’re accepting
                  responsibility for any such charges, including roaming data
                  charges if you use the app outside of your home territory
                  (i.e. region or country) without turning off data roaming. If
                  you are not the bill payer for the device on which you’re
                  using the app, please be aware that we assume that you have
                  received permission from the bill payer for using the app.
                </p> <p>
                  Along the same lines, 7Emirates cannot always take
                  responsibility for the way you use the app i.e. You need to
                  make sure that your device stays charged – if it runs out of
                  battery and you can’t turn it on to avail the Service,
                  7Emirates cannot accept responsibility.
                </p> <p>
                  With respect to 7Emirates’s responsibility for your
                  use of the app, when you’re using the app, it’s important to
                  bear in mind that although we endeavor to ensure that it is
                  updated and correct at all times, we do rely on third parties
                  to provide information to us so that we can make it available
                  to you. 7Emirates accepts no liability for any
                  loss, direct or indirect, you experience as a result of
                  relying wholly on this functionality of the app.
                </p> <p>
                  At some point, we may wish to update the app. The app is
                  currently available on Android &amp; iOS – the requirements for the 
                  both systems(and for any additional systems we
                  decide to extend the availability of the app to) may change,
                  and you’ll need to download the updates if you want to keep
                  using the app. 7Emirates does not promise that it
                  will always update the app so that it is relevant to you
                  and/or works with the Android &amp; iOS version that you have
                  installed on your device. However, you promise to always
                  accept updates to the application when offered to you, We may
                  also wish to stop providing the app, and may terminate use of
                  it at any time without giving notice of termination to you.
                  Unless we tell you otherwise, upon any termination, (a) the
                  rights and licenses granted to you in these terms will end;
                  (b) you must stop using the app, and (if needed) delete it
                  from your device.
                </p> <p><strong>Changes to This Terms and Conditions</strong></p> <p>
                  I may update our Terms and Conditions
                  from time to time. Thus, you are advised to review this page
                  periodically for any changes. I will
                  notify you of any changes by posting the new Terms and
                  Conditions on this page.
                </p> <p>
                  These terms and conditions are effective as of 2022-03-22
                </p> <p><strong>Contact Us</strong></p> <p>
                  If you have any questions or suggestions about my
                  Terms and Conditions, do not hesitate to contact me
                  at ae.7emirates@gmail.com.
                </p>
<h1>Contact Us</h1>
<p>If you have any questions about this Agreement, You can contact Us:</p>
<ul>
<li>By email: ae.7emiratesapp@gmail.com</li>
</ul>""";
    var finalHtmlData = htmlData.replaceAll('margin-left', "");
    finalHtmlData = finalHtmlData.replaceAll('margin-right', "");
    finalHtmlData = finalHtmlData.replaceAll('margin-top', "");
    finalHtmlData = finalHtmlData.replaceAll('margin-bottom', "");
    finalHtmlData = finalHtmlData.replaceAll('margin', "");
    htmlPackage.FontSize fnsize = htmlPackage.numberToFontSize(100.toString());
    var style = {
      "margin-left":
          htmlPackage.Style(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
      "h1": htmlPackage.Style(
        color: fc_2,
        fontSize: fnsize,
      ),
      "h2": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "h3": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "h4": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "h5": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "h6": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "h7": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "h8": htmlPackage.Style(color: fc_2, fontSize: fnsize),
      "p": htmlPackage.Style(color: fc_3, fontSize: fnsize),
      "body": htmlPackage.Style(color: fc_3, fontSize: fnsize),
      "span": htmlPackage.Style(color: fc_3, fontSize: fnsize),
      "a": htmlPackage.Style(color: Colors.blue, fontSize: fnsize),
    };

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: Width(context), maxHeight: Width(context)),
          child: Material(
            child: SafeArea(
              child: Container(
                height: Width(context),
                width: Width(context),
                color: fc_bg,
                child: Container(
                  child: SafeArea(
                    child: StatefulBuilder(
                      builder: (mcontext, setState) {
                        return Stack(
                          children: [
                            Positioned(
                              top: sy(35),
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      sy(10), sy(10), sy(10), sy(10)),
                                  width: Width(context),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.fromLTRB(
                                            sy(5), sy(5), sy(5), sy(10)),
                                        child: htmlPackage.Html(
                                            shrinkWrap: true,
                                            data: htmlData,
                                            onLinkTap: (String? url,
                                                htmlPackage.RenderContext
                                                    mcontext,
                                                Map<String, String> attributes,
                                                dom.Element? element) {
                                              //UrlOpenUtils.openurl(_scaffoldKey, url.toString());
                                              print(url);
                                            },
                                            style: style),
                                      ),
                                      Text(
                                        Const.Website,
                                        style: ts_Regular(sy(s), fc_2),
                                      ),
                                      SizedBox(
                                        height: sy(15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: sy(35),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    sy(10), sy(5), sy(10), sy(5)),
                                child: Row(
                                  children: [
                                    Text(
                                      Lang("Terms and Conditions  ",
                                          " الشروط والأحكام "),
                                      textAlign: TextAlign.left,
                                      style: ts_Bold(sy(l), fc_1),
                                    ),
                                    Expanded(
                                        child: SizedBox(
                                      width: 5,
                                    )),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        size: sy(xl),
                                        color: fc_1,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, true ? -1 : 1), end: Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
    );
  }
*/
}
