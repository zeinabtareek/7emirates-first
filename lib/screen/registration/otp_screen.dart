import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/country.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/progress_button.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/router/none_open_screen.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/router/right_open_screen.dart';
import 'package:sevenemirates/screen/registration/phone_number.dart';
import 'package:sevenemirates/screen/user/dashboard.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/helper.dart';
import '../../maps/map_screen.dart';

class OtpScreen extends StatefulWidget {
  final String getPhone;
  final String getEmail;
  final getCountry;
  final getCountryArab;
  final getCountryCode;
  final starting;
  final String countryId;
  final String? verificationId;
  OtpScreen(
      {this.getPhone = '',
      this.getEmail = '',
      this.getCountry,
      this.getCountryCode,
      this.getCountryArab,
      this.starting = "0",
      this.verificationId,
      Key? key,
      required this.countryId})
      : super(key: key);

  @override
  _OtpScreenState createState() {
    return _OtpScreenState();
  }
}

class _OtpScreenState extends State<OtpScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  Map data = Map();
  List userDetail = [];
  String UserId = '',
      getOtp = '',
      oldOtp = '',
      getPhone = '',
      getFlag = '',
      stateName = '',
      stateNameArab = '',
      stateId = '';
  bool showRegistration = false;
  TextEditingController ETname = TextEditingController();
  TextEditingController ETcity = TextEditingController();
  TextEditingController ETphone = TextEditingController();
  TextEditingController ETemail = TextEditingController();
  Timer? _timer;
  int _start = 60;

  //Logins
  bool googleLoading = false;
  bool fbLoading = false;
  Map fbUser = Map();
  bool enableFields = true;
  bool socialSuccess = false;
  bool _keyboardVisible = false;

  String mapAddress = '';
  String mapLat = '';
  String mapLng = '';
  String mapCity = '';

  void startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getSharedStore().then((value) {});
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  Future<void> getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserId = prefs.getString(Const.UID) ?? '';
      oldOtp = prefs.getString(Const.OTP) ?? '';
      getFlag = prefs.getString(Const.COUNTRY_FLAG) ?? '';
      getPhone = widget.getPhone;
    });
  }

  _sendOTP() async {
    startTimer();
    // String myNumber = widget.getCountryCode + widget.getPhone;
    // String myMsg;
    // myMsg =
    //     "*${oldOtp}* is your OTP for ${Const.AppName} Application Login. Thanks for using ${Const.AppName}";

    // String whatsappUrl =
    //     "https://whatsapp.myappstores.com/api/sendText?token=" +
    //         Const.WHATSAPP_TOKEN +
    //         "&phone=$myNumber&message=$myMsg";
    // final response = await http.get(Uri.parse(whatsappUrl.toString()),
    //     headers: {HttpHeaders.acceptHeader: Const.POSTHEADER});

    // data = json.decode(response.body);
    // setState(() {});
    if (widget.getEmail.isNotEmpty) {
      var isSent = await SendCodeHelper.instance.sendEmailApi(
        email: widget.getEmail,
      );
      if (!isSent) {
        return;
      }
      Navigator.pushReplacement(
          context,
          NoneOpenScreen(
              widget: OtpScreen(
            countryId: widget.countryId,
            getPhone: widget.getPhone,
            getEmail: widget.getEmail,
            getCountry: widget.getCountry,
            getCountryArab: widget.getCountryArab,
            getCountryCode: widget.getCountryCode,
            starting: widget.starting,
          )));
    } else if (widget.getPhone.isNotEmpty) {
      SendCodeHelper.instance.sendPhoneCode(
        phoneNumber: '+${widget.getCountryCode}${widget.getPhone}',
        onCodeSend: (verificationId) {
          Navigator.pushReplacement(
              context,
              NoneOpenScreen(
                  widget: OtpScreen(
                verificationId: verificationId,
                countryId: widget.countryId,
                getPhone: widget.getPhone,
                getEmail: widget.getEmail,
                getCountry: widget.getCountry,
                getCountryArab: widget.getCountryArab,
                getCountryCode: widget.getCountryCode,
                starting: widget.starting,
              )));
        },
      );
    }
  }

  _checkOTP() async {
    try {
      if (widget.getPhone.isNotEmpty) {
        var credential = await FirebaseAuth.instance.signInWithCredential(
          await PhoneAuthProvider.credential(
            verificationId: widget.verificationId ?? '',
            smsCode: getOtp,
          ),
        );
        log('cred $credential');
      } else {
        if (!(oldOtp == getOtp || getOtp == Const.OTP)) {
          Pop.errorPop(context, Lang('Attention', 'انتباه'),
              Lang("Wrong OTP", "OTP غير صحيح"), Icons.error_outlined);
          return;
        }
      }

      setState(() {
        showProgress = true;
      });
      var body = {
        "key": "228070",
        "code": widget.getCountryCode.toString(),
        "phone": getPhone.toString(),
        "email": widget.getEmail.toString(),
      };
      log('Body =>$body');
      final response = await http.post(Uri.parse(Urls.GetUser),
          headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
      apiTest(response.request.toString());
      apiTest(body.toString());
      data = json.decode(response.body);
      log('${response.body}', name: 'response_data');
      setState(() {
        showProgress = false;
      });

      setState(() {
        if (data["success"] == true) {
          log('userData= ${response.body}');
          userDetail = data["user"];
          String uid = userDetail[0]["u_id"].toString();
          String mobile = userDetail[0]["phone"].toString();

          SharedStoreUtils.setValue(Const.UID, uid);
          SharedStoreUtils.setValue(Const.PHONE, mobile);
          SharedStoreUtils.setValue(Const.SKIP_SIGNUP_VALUE, '0');

          Provider.of<AppSetting>(context, listen: false).uid =
              userDetail[0]["u_id"];
          log('${userDetail[0]["u_id"]}', name: 'user_id');
          Provider.of<AppSetting>(context, listen: false).name =
              userDetail[0]["name"] ?? '';
          Provider.of<AppSetting>(context, listen: false).email =
              userDetail[0]["email"] ?? '';
          Provider.of<AppSetting>(context, listen: false).skipSignup = '0';

          if (userDetail[0]["name"].toString() == "null") {
            setState(() {
              _openMap();
              showRegistration = true;
            });
          } else {
            if (widget.starting == "0") {
              Navigator.of(context).pop();
              apiTest('closing');
            } else {
              openScreen();
            }
          }
        } else {
          Pop.errorTop(
              context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
        }
      });

      //(oldOtp == getOtp || getOtp == Const.OTP) return;
      // if (credential.credential != null) {
      // } else {}
    } on FirebaseAuthException catch (error) {
      log('error =>${error}');
      Pop.errorPop(context, Lang('Attention', 'انتباه'),
          Lang("Wrong OTP", "OTP غير صحيح"), Icons.error_outlined);
    }
  }

  _updateUser() async {
    print(widget.getPhone.toString());
    print(widget.getPhone.toString().toString());
    print(widget.getPhone.toString());
    setState(() {
      showProgress = true;
    });
    var body = {
      "key": Const.APPKEY,
      "name": ETname.text.toString(),
      "phone": widget.getPhone.toString(),
      "country": widget.getCountry,
      "country_ar": widget.getCountryArab,
      "countryid": widget.getCountryCode,
      "city": stateName,
      "cityid": stateId,
      "city_ar": stateNameArab,
      "lat": mapLat.toString(),
      "lng": mapLng.toString(),
      "mapcity": mapCity.toString(),
      "mapaddress": mapAddress.toString().replaceAll("'", ""),
      "email": ETemail.text.toString(),
    };
    final response = await http.post(Uri.parse(Urls.UpdateUser),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
    apiTest(response.request.toString());
    apiTest(body.toString());
    data = json.decode(response.body);
    setState(() {
      showProgress = false;
    });

    setState(() {
      if (data["success"] == true) {
        if (data["email"] == true) {
          String phone = widget.getPhone.toString();
          SharedStoreUtils.setValue(Const.PHONE, phone);
          SharedStoreUtils.setValue(Const.NAME, ETname.text.toString());
          SharedStoreUtils.setValue(Const.EMAIL, ETemail.text.toString());
          SharedStoreUtils.setValue(Const.CITY_NAME, stateName);
          SharedStoreUtils.setValue(Const.CITY_NAME_ARAB, stateNameArab);
          SharedStoreUtils.setValue(Const.SKIP_SIGNUP_VALUE, '0');

          Provider.of<AppSetting>(context, listen: false).name =
              ETname.text.toString();
          Provider.of<AppSetting>(context, listen: false).email =
              ETemail.text.toString();
          Provider.of<AppSetting>(context, listen: false).city = stateName;
          Provider.of<AppSetting>(context, listen: false).country =
              widget.getCountry;
          Provider.of<AppSetting>(context, listen: false).countryId =
              widget.getCountryCode;

          if (widget.starting == "0") {
            Navigator.of(context).canPop();
          } else {
            openScreen();
          }
        } else {
          enableFields = true;
          Pop.errorTop(
              context,
              Lang("Email already exists", "البريد الالكتروني موجود بالفعل"),
              Icons.person);
        }
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.person);
      }
    });
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
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                //   resizeToAvoidBottomPadding: false,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      if (showRegistration == false)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: sy(0),
                          child: otpWidget(),
                        ),
                      Positioned(
                        top: sy(5),
                        left: sy(2),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                RightOpenScreen(
                                    widget: PhoneNumberScreen(starting: "1")));
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: fc_1,
                            size: sy(xl),
                          ),
                        ),
                      ),
                      if (showRegistration)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 0,
                          child: registerWidget(),
                        ),

                      if (showRegistration == true && _keyboardVisible == false)
                        Positioned(
                          bottom: sy(10),
                          left: sy(10),
                          child: ElevatedButton(
                              style: elevatedButton(TheamPrimary, sy(30)),
                              onPressed: () {
                                //

                                if (ETname.text != '' && ETemail.text != '') {
                                  if (mapLat == '') {
                                    _openMap();
                                  } else {
                                    _updateUser();
                                  }
                                } else {
                                  Pop.errorTop(
                                      context,
                                      Lang("Fill email & name ",
                                          "املأ البريد الإلكتروني والاسم "),
                                      Icons.warning);
                                }
                              },
                              child: ProgressButton(
                                bttext: Lang(" Register Now", "سجل الان "),
                                btwidth: Width(context) * 0.4,
                                showProgress: showProgress,
                                btheight: sy(35),
                              )),
                        ),

                      // MyProgressBar(showProgress),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  otpWidget() {
    return Container(
      decoration: decoration_round(TheamBG, sy(0), sy(0), 0, 0),
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: sy(50),
                      ),
                      Text(
                        Lang(
                            " We have sent you an OTP ", " لقد أرسلنا لك OTP "),
                        style: ts_Bold(sy(l), fc_2),
                      ),
                      SizedBox(
                        height: sy(5),
                      ),
                      if (widget.getPhone != '')
                        Text(
                          '${Lang("Please enter OTP which is sent to your number", "الرجاء إدخال OTP الذي يتم إرساله إلى رقمك")} ${widget.getCountryCode} ${widget.getPhone}',
                          style: ts_Regular(sy(n), fc_3),
                        ),
                      if (widget.getEmail != '')
                        Text(
                          '${Lang("Please enter OTP which is sent to your Email", "الرجاء إدخال OTP الذي يتم إرساله إلى بريدك الإلكتروني")} ${widget.getEmail}',
                          style: ts_Regular(sy(n), fc_3),
                        ),

                      ///
                      SizedBox(
                        height: sy(20),
                      ),
                      Container(
                        height: Width(context) * 0.15,
                        child: OTPTextField(
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: Width(context) * 0.125,
                          style: ts_Regular(sy(l), fc_3),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.box,
                          keyboardType: TextInputType.number,
                          otpFieldStyle: OtpFieldStyle(
                              focusBorderColor: fc_bg!,
                              enabledBorderColor: fc_bg!,
                              disabledBorderColor: fc_bg!,
                              backgroundColor: fc_bg!,
                              borderColor: fc_bg!),
                          onCompleted: (pin) {
                            setState(() {
                              getOtp = pin.toString();
                            });
                            _checkOTP();
                          },
                        ),
                      ),

                      SizedBox(
                        height: sy(15),
                      ),

                      if (_start != 0)
                        Row(
                          children: [
                            Text(
                              Lang(
                                  " Resend OTP in  ", "إعادة إرسال OTP خلال  "),
                              style: ts_Regular(sy(n), fc_4),
                            ),
                            Text(
                              '$_start s',
                              style: ts_Regular(sy(n), fc_3),
                            ),
                          ],
                        ),
                      if (_start == 0)
                        GestureDetector(
                          onTap: () {
                            _sendOTP();
                          },
                          child: Text(
                            Lang(" Resend OTP ", "إعادة إرسال OTP  "),
                            style: ts_Regular(sy(n), Colors.blue),
                          ),
                        ),
                      SizedBox(
                        height: sy(15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Lang(" Having trouble? Write to us at  ",
                                " هل تواجه مشكلة؟ اكتب لنا على "),
                            style: ts_Regular(sy(s), fc_4),
                          ),
                          SizedBox(
                            width: sy(3),
                          ),
                          GestureDetector(
                            child: Text(
                              '${Const.SHAREEMAIL}',
                              style: ts_Regular_underline(sy(s), fc_3),
                            ),
                            onTap: () {
                              setState(() {
                                UrlOpenUtils.email(_scaffoldKey);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          Positioned(
            bottom: sy(10),
            left: sy(15),
            right: sy(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: sy(5),
                ),
                Divider(
                  color: fc_4,
                ),
                SizedBox(
                  height: sy(5),
                ),
                ElevatedButton(
                    style: elevatedButtonBorder(TheamPrimary, sy(30)),
                    onPressed: () {
                      if (getOtp.length == 6 && getOtp != '') {
                        _checkOTP();
                      } else {
                        Pop.errorTop(
                            context,
                            Lang(" Enter valid OTP ", " أدخل OTP صالح "),
                            Icons.error);
                      }
                    },
                    child: ProgressButton(
                      showProgress: showProgress,
                      bttext: Lang(" Verify OTP ", " تحقق من OTP "),
                      bttxtcolor: TheamPrimary,
                      btwidth: Width(context) * 0.35,
                      btheight: sy(35),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  registerWidget() {
    return Container(
      color: TheamBG,
      width: Width(context),
      height: Height(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width,
          // height:Height(context)-200,
          padding: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: sy(20),
              ),
              Image.asset(
                'assets/images/logoonly.png',
                height: sy(40),
              ),
              SizedBox(
                height: sy(10),
              ),
              Text(
                Lang(" Personal details ", "البيانات الشخصية  "),
                style: ts_Bold(sy(l), fc_2),
              ),
              SizedBox(
                height: sy(3),
              ),
              Text(
                Lang(" To finish signup, enter your personal details ",
                    " لإنهاء التسجيل ، أدخل البيانات الشخصية الخاصة بك "),
                style: ts_Regular(sy(n), fc_3),
              ),

              ///
              SizedBox(
                height: sy(20),
              ),
              Container(
                decoration: decoration_border(
                    fc_bg, fc_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                height: sy(30),
                padding: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: sy(5),
                        ),
                        Image.asset(
                          'assets/images/flag/' + getFlag,
                          width: sy(30),
                          height: sy(22),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(
                          width: sy(3),
                        ),
                        Text(
                          widget.getCountryCode,
                          style: ts_Regular(sy(n), fc_1),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          width: sy(1),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: sy(xl),
                          color: fc_2,
                        )
                      ],
                    ),
                    SizedBox(
                      width: sy(5),
                    ),
                    Expanded(
                      child: TextField(
                        enabled: false,
                        controller: ETphone..text = widget.getPhone,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          hintText: 'xxxxx-xxxx',
                          hintStyle: ts_Regular(sy(l), fc_1),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_1),
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
                        child: Text(
                          Lang(" Edit ", " تعديل "),
                          style: ts_Regular(sy(s), Colors.blue),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            OpenScreen(
                                widget: PhoneNumberScreen(starting: "1")));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: sy(15),
              ),

              Container(
                decoration: decoration_border(
                    fc_bg, fc_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                height: sy(28),
                padding: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    // SizedBox(width: sy(5),),
                    // Icon(Icons.person,size: sy(xl),color: fc_3,),
                    SizedBox(
                      width: sy(8),
                    ),
                    Expanded(
                      child: TextField(
                        controller: ETname,
                        keyboardType: TextInputType.name,
                        enabled: enableFields,
                        textCapitalization: TextCapitalization.sentences,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          isDense: true,
                          // counter: Offstage(),
                          hintText: Lang(" Your Name ", " اسمك "),
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
                  ],
                ),
              ),
              SizedBox(
                height: sy(15),
              ),

              Container(
                decoration: decoration_border(
                    fc_bg, fc_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                height: sy(28),
                padding: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                child: Row(
                  children: [
                    // SizedBox(width: sy(5),),
                    // Icon(Icons.email_sharp,size: sy(xl),color: fc_4,),
                    SizedBox(
                      width: sy(8),
                    ),
                    Expanded(
                      child: TextField(
                        controller: ETemail,
                        enabled: enableFields,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          isDense: true,
                          hintText: Lang(
                              " Email Address ", " عنوان البريد الالكترونى "),
                          hintStyle: ts_Regular(sy(n), fc_4),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_2),
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: sy(15),
              ),

              Container(
                decoration: decoration_border(
                    fc_bg, fc_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                height: sy(28),
                padding: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
                alignment: Alignment.center,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    print('dddd');

                    _popCity();
                  },
                  child: Row(
                    children: [
                      // SizedBox(width: sy(5),),
                      // Icon(Icons.person,size: sy(xl),color: fc_3,),
                      SizedBox(
                        width: sy(8),
                      ),
                      Expanded(
                        child: Text(
                          (stateName == '')
                              ? Lang(" Select State ", " اختر ولايه ")
                              : Lang(stateName, stateNameArab),
                          style: ts_Regular(
                              sy(n), (stateName == '') ? fc_4 : fc_2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: sy(15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _popCity() {
    TextEditingController ETsearch = TextEditingController();
    List cityList = [];
    for (int i = 0; i < World.States.length; i++) {
      if (World.States[i]['country_id'].toString() == widget.getCountryCode) {
        cityList.add(World.States[i]);
      }
    }

    List filterCity = cityList;
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
                                          i < filterCity.length;
                                          i++)
                                        GestureDetector(
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Lang(filterCity[i]['name'],
                                                      filterCity[i]['name']),
                                                  style:
                                                      ts_Regular(sy(n), fc_2),
                                                ),
                                                Divider(
                                                  color: fc_textfield_bg,
                                                ),
                                              ],
                                            ),
                                            width: Width(context),
                                            padding: EdgeInsets.fromLTRB(
                                                sy(15), sy(5), sy(10), sy(5)),
                                          ),
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            _setCity(
                                                filterCity[i]['name'],
                                                filterCity[i]['name'],
                                                filterCity[i]['id']);
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
                                decoration: decoration_border(
                                    fc_textfield_bg,
                                    fc_textfield_bg,
                                    sy(1),
                                    sy(5),
                                    sy(5),
                                    sy(5),
                                    sy(5)),
                                height: sy(70),
                                //  padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(5)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          height: sy(35),
                                          decoration: decoration_border(
                                              fc_textfield_bg,
                                              fc_textfield_bg,
                                              sy(1),
                                              sy(5),
                                              sy(5),
                                              sy(5),
                                              sy(5)),
                                          padding: EdgeInsets.fromLTRB(
                                              sy(8), sy(0), sy(5), sy(0)),
                                          alignment: Alignment.centerLeft,
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
                                            style: ts_Regular(sy(n), fc_2),
                                            textInputAction:
                                                TextInputAction.done,
                                            autofocus: false,
                                            onChanged: (val) {
                                              setState(() {
                                                List tempArr = [];
                                                for (int i = 0;
                                                    i < cityList.length;
                                                    i++) {
                                                  if (cityList[i]['name']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(
                                                          val.toLowerCase())) {
                                                    tempArr.add(cityList[i]);
                                                  }
                                                }
                                                filterCity = tempArr;
                                              });
                                            },
                                          )),
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
                                    ),
                                    SizedBox(
                                      width: sy(5),
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

  _setCity(String eng, String ara, String id) {
    setState(() {
      stateName = eng;
      stateNameArab = ara;
      stateId = id;
      SharedStoreUtils.setValue(Const.CITY_NAME, eng);
      SharedStoreUtils.setValue(Const.CITY_NAME_ARAB, ara);
      Navigator.of(context).pop(true);
    });
  }

  void openScreen() {
    Navigator.pushReplacement(context, OpenScreen(widget: Dashboard()));
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
