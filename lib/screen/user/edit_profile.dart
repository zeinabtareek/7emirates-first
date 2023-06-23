import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:mailer/mailer.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:sevenemirates/components/country.dart';
import 'package:sevenemirates/components/helper.dart';
import 'package:sevenemirates/components/progress_button_jump.dart';
import 'package:sevenemirates/maps/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/image_viewer.dart';
import '../../components/progress_button.dart';
import '../../components/relative_scale.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';

class EditProfile extends StatefulWidget {
  String screen = '';
  EditProfile({Key? key, required this.screen}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  bool showProgress = false;
  Map data = Map();
  List userDetail = [];
  String UserId = '', phone = '', email = '', profile = '', name = '';

  CroppedFile? _image;
  var imagepath;
  late File finalImage;

  TextEditingController ETname = TextEditingController();
  TextEditingController ETemail = TextEditingController();
  TextEditingController ETphone = TextEditingController();
  TextEditingController ETaddress = TextEditingController();
  TextEditingController ETbio = TextEditingController();

  TextEditingController ETbankAc = TextEditingController();
  TextEditingController ETbankName = TextEditingController();
  TextEditingController ETbankCode = TextEditingController();

  String countryFlag = '',
      countryCodeint = '',
      stateId = '',
      stateName = '',
      stateNameArab = '',
      bio = '',
      emailver = '0';
  String mapLat = '', mapLng = '', mapCity = '', mapAddress = '';

  String getOTP = '';
  String myOTP = randomNumeric(5);
  bool showOTP = false;
  List selectedTag = [];
  String selectedTagString = '';
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
      UserId = prefs.getString(Const.UID) ?? '0';
      UserId = Provider.of<AppSetting>(context, listen: false).uid;
      phone = Provider.of<AppSetting>(context, listen: false).phone;
      email = Provider.of<AppSetting>(context, listen: false).email;
      profile = Provider.of<AppSetting>(context, listen: false).profile;
      name = Provider.of<AppSetting>(context, listen: false).name;

      countryCodeint =
          Provider.of<AppSetting>(context, listen: false).countryId;
      stateId = Provider.of<AppSetting>(context, listen: false).cityId;
      stateName = Provider.of<AppSetting>(context, listen: false).city;
      stateNameArab = Provider.of<AppSetting>(context, listen: false).city;
      emailver = Provider.of<AppSetting>(context, listen: false).emailVerify;

      ETemail.text = Provider.of<AppSetting>(context, listen: false).email;
      ETname.text = Provider.of<AppSetting>(context, listen: false).name;
      ETphone.text = Provider.of<AppSetting>(context, listen: false).phone;
      ETbio.text = Provider.of<AppSetting>(context, listen: false).bio;

      ETaddress.text =
          Provider.of<AppSetting>(context, listen: false).mapAddress;
      mapLat = Provider.of<AppSetting>(context, listen: false).maplat;
      mapLng = Provider.of<AppSetting>(context, listen: false).maplon;
      mapCity = Provider.of<AppSetting>(context, listen: false).mapCity;
      mapAddress = Provider.of<AppSetting>(context, listen: false).mapAddress;
      ETaddress.text =
          Provider.of<AppSetting>(context, listen: false).mapAddress;

      ETbankAc.text = Provider.of<AppSetting>(context, listen: false).bankAC;
      ETbankName.text =
          Provider.of<AppSetting>(context, listen: false).bankName;
      ETbankCode.text =
          Provider.of<AppSetting>(context, listen: false).bankCode;
    });
  }

  updateUser() async {
    if (ETname.text == '' || ETemail.text == '' || stateName == "") {
      Pop.errorTop(
          context,
          Lang("Please fill all details", "الرجاء ملء جميع التفاصيل"),
          Icons.warning);
    } else {
      setState(() {
        showProgress = true;
      });

      String headers = Const.POSTHEADER;

      var body = {
        "key": Const.APPKEY,
        "uid": UserId,
        "name": ETname.text,
        "email": ETemail.text,
        "emailverify": emailver,
        "cityid": stateId.toString(),
        "city": stateName.toString(),
        "cityarab": stateNameArab.toString(),
        "mapaddress": mapAddress.toString().replaceAll(",", " "),
        "maplat": mapLat.toString(),
        "maplng": mapLng.toString(),
        "mapcity": mapCity.toString(),
        "about": ETbio.text.toString(),
        "acno": ETbankAc.text,
        "bankname": ETbankName.text,
        "bankcode": ETbankCode.text,
      };
      apiTest(body.toString());
      final response = await http.post(Uri.parse(Urls.UpdateProfile),
          headers: {HttpHeaders.acceptHeader: headers}, body: body);
      apiTest(response.request.toString());
      apiTest(body.toString());
      data = json.decode(response.body);
      log('$data', name: 'UpdateData');

      apiTest(data.toString());
      setState(() {
        showProgress = false;
        showOTP = false;
        if (data['email'] == true) {
          SharedStoreUtils.setValue(Const.NAME, ETname.text);
          SharedStoreUtils.setValue(Const.EMAIL, ETemail.text);
          SharedStoreUtils.setValue(Const.CITY_NAME, stateName);
          SharedStoreUtils.setValue(Const.CITY_NAME_ARAB, stateName);
          SharedStoreUtils.setValue(Const.CITY, stateId);

          SharedStoreUtils.setValue(Const.MAP, mapLat + ',' + mapLng);
          SharedStoreUtils.setValue(Const.MAPADDRESS, mapAddress);
          SharedStoreUtils.setValue(Const.MAPLAT, mapLat);
          SharedStoreUtils.setValue(Const.MAPLNG, mapLng);
          SharedStoreUtils.setValue(Const.MAPCITY, mapCity);
          SharedStoreUtils.setValue(Const.BANKAC, ETbankAc.text);
          SharedStoreUtils.setValue(Const.BANKNAME, ETbankName.text);
          SharedStoreUtils.setValue(Const.BANKAC, ETbankCode.text);
          SharedStoreUtils.setValue(Const.BIO, ETbio.text);

          Provider.of<AppSetting>(context, listen: false).name = ETname.text;
          Provider.of<AppSetting>(context, listen: false).email = ETemail.text;
          Provider.of<AppSetting>(context, listen: false).emailVerify =
              emailver;
          Provider.of<AppSetting>(context, listen: false).city = stateName;
          Provider.of<AppSetting>(context, listen: false).cityId = stateId;
          Provider.of<AppSetting>(context, listen: false).map =
              mapLat + ',' + mapLng;
          Provider.of<AppSetting>(context, listen: false).mapAddress =
              mapAddress;
          Provider.of<AppSetting>(context, listen: false).maplat = mapLat;
          Provider.of<AppSetting>(context, listen: false).maplon = mapLng;
          Provider.of<AppSetting>(context, listen: false).mapCity = mapCity;
          Provider.of<AppSetting>(context, listen: false).bankAC =
              ETbankAc.text;
          Provider.of<AppSetting>(context, listen: false).bankName =
              ETbankName.text;
          Provider.of<AppSetting>(context, listen: false).bankCode =
              ETbankCode.text;
          Provider.of<AppSetting>(context, listen: false).bio = ETbio.text;

          Pop.successTop(
              context,
              Lang("Updated. Please restart app to apply changes",
                  "محدث. يرجى إعادة تشغيل التطبيق لتطبيق التغييرات"),
              Icons.check);
        } else {
          Pop.errorTop(
              context,
              Lang(
                  "Email already exists  ", " البريد الالكتروني موجود بالفعل "),
              Icons.check);
        }
      });
    }
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
    //       "<h1>Trends Research & Advisory</h1>\n<p>${myOTP} is your OTP for Login</p>";
    var isSent = await SendCodeHelper.instance.sendEmailApi(
      email: ETemail.text,
    );
    if (!isSent) {
      setState(() {
        showProgress = false;
      });
    }

    try {
      // final sendReport = await send(equivalentMessage, smtpServer);
      setState(() {
        showOTP = true;
      });
    } on MailerException catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      showProgress = false;
    });
  }

  void uploadImage1(File finalimg) async {
    setState(() {
      showProgress = true;
    });
    // open a byteStream
    var stream = http.ByteStream(DelegatingStream.typed(finalimg.openRead()));
    // get file length
    var length = await finalimg.length();
    var request = http.MultipartRequest("POST", Uri.parse(Urls.UpdateImage));
    request.fields["key"] = Const.APPKEY;
    request.fields["uid"] = UserId;
    var multipartFile = http.MultipartFile('image', stream, length,
        filename: path.basename(finalimg.path));
    request.files.add(multipartFile);

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        data = json.decode(value);
        if (data["success"] == true) {
          setState(() {
            showProgress = false;
            SharedStoreUtils.setValue(
                Const.PROFILE, data["filename"].toString());
            Provider.of<AppSetting>(context, listen: false).profile =
                data["filename"].toString();

            profile = data["filename"].toString();
            debugPrint(data["filename"]);
          });
        }
        print(value);
      });
    }).catchError((e) {
      print(e);
    });
    {}
  }

  getImageFile(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.getImage(source: source, imageQuality: 80);
    final img = ImageCropper();
    //Cropping the image
    CroppedFile? croppedFile = await img.cropImage(
      sourcePath: image!.path,
      aspectRatioPresets: [CropAspectRatioPreset.original],
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
      maxWidth: 1500,
      maxHeight: 1000,
    );

    setState(() {
      _image = croppedFile;
      imagepath = croppedFile;
      finalImage = File(_image!.path);

      uploadImage1(finalImage);
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
              body: Container(
                decoration: BoxDecoration(
                  color: fc_bg,
                ),
                height: Height(context),
                width: Width(context),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _screenBody(),
                    ),

                    // MyProgressBar(showProgress),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  _screenBody() {
    return Container(
      child: Column(
        children: [
          titlebar(),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: Width(context),
              color: fc_bg,
              //  padding: EdgeInsets.fromLTRB(sy(15), sy(0), sy(15), sy(0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.screen == 'basic') profileDetail(),
                  if (widget.screen == 'bank') bankDetail(),
                  SizedBox(
                    height: sy(15),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (mapAddress == '') {
                          _openMap();
                        } else {
                          updateUser();
                        }
                      },
                      child: Container(
                        width: Width(context) * 0.6,
                        height: sy(30),
                        decoration: BoxDecoration(
                            color: TheamPrimary,
                            /* gradient: LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  stops: [0.1, 0.5],
                                                  colors: [
                                                    TheamPrimary,
                                                    TheamPrimary.withOpacity(0.4),
                                                    // Colors.yellow[600],
                                                    //  Colors.yellow[400],
                                                  ],
                                                ),*/
                            borderRadius: BorderRadius.circular(sy(5))),
                        child: ProgressButton(
                          btpadding: sy(5),
                          bttext: Lang(" Save Changes ", "حفظ التغييرات  "),
                          btwidth: Width(context),
                          showProgress: showProgress,
                          btheight: sy(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: sy(15),
                  ),
                ],
              ),
            ),
          )),
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
              Navigator.of(context).pop(true);
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
                  "7 Emirate",
                  style: ts_Bold(sy(xl), fc_1),
                ),
                SizedBox(
                  height: sy(5),
                ),
                Text(
                  (widget.screen == 'basic')
                      ? Lang("Profile Update  ", " تحديث الملف الشخصي ")
                      : Lang(" Bank Details ", " التفاصيل المصرفية "),
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

  profilePicWidget() {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(0), sy(15), sy(0), sy(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (UserId != "0")
            Material(
              elevation: 2,
              color: fc_bg,
              borderRadius: BorderRadius.circular(sy(50)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(sy(5)),
                child: GestureDetector(
                  onTap: () {
                    _showPop();
                  },
                  child: Container(
                    width: sy(75),
                    height: sy(80),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: (profile == '')
                                ? Image.asset(
                                    'assets/images/blank.png',
                                    width: sy(60),
                                    height: sy(60),
                                    fit: BoxFit.cover,
                                  )
                                : CustomeImageView(
                                    image: Urls.imageLocation + profile,
                                    width: sy(60),
                                    height: sy(60),
                                    fit: BoxFit.cover,
                                  )),
                        Positioned(
                            bottom: sy(0),
                            left: 0,
                            right: 0,
                            child: Container(
                              color: TheamButton.withOpacity(0.9),
                              padding: EdgeInsets.fromLTRB(0, sy(2), 0, sy(2)),
                              child: Text(
                                Lang(" Edit ", "تعديل  "),
                                style: ts_Regular(sy(xs), Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  profileDetail() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), sy(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profilePicWidget(),
          lableText(Lang(" First Name ", " الاسم الاول ")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(28),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(3), sy(0)),
            alignment: Alignment.center,
            child: TextField(
              controller: ETname,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                isDense: true,
                hintText: Lang(" Your Name ", " اسمك "),
                hintStyle: ts_Regular(sy(n), fc_4),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              style: ts_Regular(sy(n), fc_1),
              textInputAction: TextInputAction.next,
              autofocus: false,
            ),
          ),

          lableText(Lang(" Email Address ", " عنوان البريد الالكترونى ")),
          Container(
            height: sy(25),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: decoration_border(fc_textfield_bg,
                        fc_textfield_bg, sy(1), sy(5), sy(5), sy(5), sy(5)),
                    height: sy(28),
                    padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(3), sy(0)),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: ETemail,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        isDense: true,
                        //hintText: Lang(" Your Name ", " اسمك "),
                        hintStyle: ts_Regular(sy(n), fc_4),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                      style: ts_Regular(sy(n), fc_1),
                      textInputAction: TextInputAction.next,
                      autofocus: false,
                    ),
                  ),
                ),
                SizedBox(
                  width: sy(8),
                ),
                if (emailver == '1') verified(),
                if (emailver == '0')
                  ProgressButtonJump(
                      showProgress: showProgress,
                      bttext: Lang("Verify  ", " تأكيد "),
                      btwidth: sy(45),
                      btheight: sy(20),
                      btround: sy(3),
                      bttextsize: sy(s - 2),
                      onTap: () {
                        _sendEMail();
                        setState(() {
                          showOTP = true;
                        });
                      }),
              ],
            ),
          ),
          if (showOTP == true) otpWidget(),

          //Mobile
          lableText(Lang(" Mobile Number ", " رقم الهاتف المحمول ")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(28),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(5), sy(0)),
            child: Row(
              children: [
                Text(
                  countryCodeint,
                  style: ts_Regular(sy(n), fc_2),
                ),
                SizedBox(
                  width: sy(3),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: sy(l),
                  color: fc_2,
                ),
                SizedBox(
                  width: sy(3),
                ),
                Expanded(
                    child: TextField(
                  controller: ETphone,
                  keyboardType: TextInputType.phone,
                  enabled: false,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
                      border: InputBorder.none,
                      isDense: true),
                  style: ts_Regular(sy(n), fc_2),
                )),
              ],
            ),
          ),

          //State
          lableText(Lang("State  ", "حالة  ")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(5), sy(0)),
            height: sy(28),
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                _popCity();
              },
              child: Text(
                Lang(stateName, stateNameArab),
                style: ts_Regular(sy(n), fc_2),
              ),
            ),
          ),

          lableText(Lang(" About ", " حول ")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(60),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(3), sy(0)),
            alignment: Alignment.center,
            child: TextField(
              controller: ETbio,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.left,
              maxLines: 25,
              decoration: InputDecoration(
                isDense: true,
                // hintText: 'Your Name',
                hintStyle: ts_Regular(sy(n), fc_4),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              style: ts_Regular(sy(n), fc_1),
              textInputAction: TextInputAction.newline,
              autofocus: false,
            ),
          ),

          addressBlock(),
        ],
      ),
    );
  }

  bankDetail() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), sy(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          lableText(Lang("Bank Name  ", "اسم البنك  ")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(28),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(3), sy(0)),
            alignment: Alignment.center,
            child: TextField(
              controller: ETbankName,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                isDense: true,
                hintStyle: ts_Regular(sy(n), fc_4),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              style: ts_Regular(sy(n), fc_1),
              textInputAction: TextInputAction.next,
              autofocus: false,
            ),
          ),
          lableText(Lang(" Bank Account No ", "رقم الحساب البنكي")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(28),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(3), sy(0)),
            alignment: Alignment.center,
            child: TextField(
              controller: ETbankAc,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                isDense: true,
                hintStyle: ts_Regular(sy(n), fc_4),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              style: ts_Regular(sy(n), fc_1),
              textInputAction: TextInputAction.next,
              autofocus: false,
            ),
          ),
          lableText(Lang(" Bank Code ", "رمز البنك  ")),
          Container(
            decoration: decoration_border(fc_textfield_bg, fc_textfield_bg,
                sy(1), sy(5), sy(5), sy(5), sy(5)),
            height: sy(28),
            padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(3), sy(0)),
            alignment: Alignment.center,
            child: TextField(
              controller: ETbankCode,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                isDense: true,
                hintStyle: ts_Regular(sy(n), fc_4),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              style: ts_Regular(sy(n), fc_1),
              textInputAction: TextInputAction.next,
              autofocus: false,
            ),
          ),
        ],
      ),
    );
  }

  lableText(String lable) {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(5)),
      child: Text(
        lable,
        style: ts_Regular(sy(s), fc_3),
      ),
    );
  }

  verified() {
    return Container(
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: sy(s),
            color: Colors.green,
          ),
          SizedBox(
            width: sy(2),
          ),
          Text(
            Lang(" Verified ", " تم التحقق "),
            style: ts_Regular(sy(s - 2), Colors.green),
          ),
        ],
      ),
    );
  }

  otpWidget() {
    return Container(
      decoration: decoration_round(fc_bg2, sy(20), sy(20), sy(20), sy(20)),
      // height: sy(200),
      padding: EdgeInsets.fromLTRB(sy(10), sy(15), sy(10), sy(50)),
      margin: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(10)),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text(
            Lang("Enter Your OTP", "OTP الخاص بك"),
            textAlign: TextAlign.left,
            style: ts_Bold(sy(l), fc_1),
          ),
          Divider(),
          Text(
            Lang("OTP sent to your email address.  ",
                " تم إرسال OTP إلى عنوان بريدك الإلكتروني. "),
            textAlign: TextAlign.left,
            style: ts_Regular(sy(n), fc_2),
          ),
          SizedBox(
            height: sy(20),
          ),
          Container(
            height: Width(context) * 0.15,
            child: OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: Width(context) * 0.125,
              style: ts_Regular(sy(l), fc_1),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.box,
              keyboardType: TextInputType.number,
              otpFieldStyle: OtpFieldStyle(
                  focusBorderColor: fc_bg!,
                  enabledBorderColor: fc_bg!,
                  disabledBorderColor: fc_bg!,
                  backgroundColor: fc_bg!,
                  borderColor: fc_bg!),
              onCompleted: (pin) async {
                var otp = await SharedStoreUtils.getValue(Const.OTP);
                setState(() {
                  log('${SharedStoreUtils.getValue(Const.OTP)}', name: 'otp');
                  getOTP = pin.toString();
                  if (myOTP == getOTP || getOTP == otp) {
                    emailver = '1';
                    updateUser();
                  } else {
                    Pop.errorTop(
                        context,
                        Lang(" Wrong OTP. Enter correct one ",
                            "OTP خاطئ. أدخل الصحيح  "),
                        Icons.warning);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  _popCity() {
    TextEditingController ETsearch = TextEditingController();
    List cityList = [];

    for (int i = 0; i < World.States.length; i++) {
      if (World.States[i]['phonecode'].toString() == countryCodeint) {
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
                                                      ts_Regular(sy(n), fc_1),
                                                ),
                                                Divider(
                                                  color: fc_textfield_bg,
                                                ),
                                              ],
                                            ),
                                            width: Width(context),
                                            padding: EdgeInsets.fromLTRB(
                                                sy(10), sy(5), sy(8), sy(5)),
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
                                decoration: decoration_border(fc_bg, fc_4,
                                    sy(1), sy(5), sy(5), sy(5), sy(5)),
                                height: sy(70),
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
                                                    Lang(" Search ", "بحث  "),
                                                hintStyle:
                                                    ts_Regular(sy(n), fc_4),
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                border: InputBorder.none,
                                                isDense: false),
                                            style: ts_Regular(sy(l), fc_2),
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

  addressBlock() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(sy(0), sy(20), sy(0), sy(0)),
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
                      Lang(" Your Address ", "عنوانك  "),
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
                            Lang("Change Address  ", "تغيير العنوان  "),
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
                          // infoWindow: InfoWindow(title: "Point"),
                        ),
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
                "Please Note. Address generated based on your map location. You can edit the address  ",
                " يرجى الملاحظة. تم إنشاء العنوان بناءً على موقع الخريطة. يمكنك تعديل العنوان "),
            style: ts_Regular(sy(s), Colors.grey.shade500),
          ),
          SizedBox(
            height: sy(5),
          )
        ],
      ),
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

  _showPop() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            width: Width(context),
            color: fc_bg,
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(
                    Lang("User image", "صورة المستخدم"),
                    style: ts_Regular(sy(l), fc_1),
                  ),
                ),
                Container(
                  height: 0.5,
                  color: fc_2,
                ),
                ListTile(
                    leading: Icon(
                      Icons.camera_alt,
                      color: fc_1,
                      size: sy(xl),
                    ),
                    title: Text(
                      Lang("Camera", "الكاميرا"),
                      style: ts_Regular(sy(n), fc_2),
                    ),
                    onTap: () => {
                          getImageFile(ImageSource.camera),
                          Navigator.pop(context),
                        }),
                ListTile(
                  leading: Icon(
                    Icons.image,
                    color: fc_1,
                    size: sy(xl),
                  ),
                  title: Text(
                    Lang("Gallery", "معرض الصور"),
                    style: ts_Regular(sy(n), fc_2),
                  ),
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

  Future _openMap() async {
    var location = loc.Location();
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
            .push(MaterialPageRoute(builder: (context) => MapScreen( )));
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
