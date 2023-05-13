import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as htmlPackage;
import 'package:sevenemirates/components/url_open.dart';

// import 'package:flutter_html/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:async/async.dart';

import '../../components/custom_date.dart';
import '../../components/flashbar.dart';
import '../../components/image_viewer.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';
import 'package:html/dom.dart' as dom;

class ChatScreen extends StatefulWidget {
  String opId, opName, opImage;
  String pname, pid, pimage;
  ChatScreen({
    Key? key,
    required this.opId,
    required this.opName,
    required this.opImage,
    this.pname = '',
    this.pid = '',
    this.pimage = '',
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with RelativeScale, TickerProviderStateMixin {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  String UserId = '';
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  String UserName = '', UserImage = '';
  bool showProgress = false;
  Map data = Map();
  File? _image;
  CroppedFile? cropFile;
  var imagepath;
  List chat = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController ETmessgae = TextEditingController();
  String sender = '', receiver = '';
  late Timer _timer;
  bool blocked = false;
  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _getServer();
      },
    );
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserId = Provider.of<AppSetting>(context, listen: false).uid;
      UserName = Provider.of<AppSetting>(context, listen: false).name;
      UserImage = Provider.of<AppSetting>(context, listen: false).profile;
      //   isDoctor = Provider.of<AppSetting>(context, listen: false).isDoctor;

      sender = UserId;
      receiver = widget.opId;
    });
    startTimer();
    _getServer();
    if (widget.pimage != '') {
      _addMessage();
    }

    // startAnimation();
  }

  _getServer() async {
    if (mounted) {
      setState(() {
        //  showProgress = true;
      });
    }
    final response = await http.post(Uri.parse(Urls.Chat), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "send_id": UserId,
      "res_id": widget.opId,
    });
    data = json.decode(response.body);
    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        chat = data["chat"];
        if (chat.length > 1) {
          if (chat[0]['block'].toString() == '0') {
            blocked = false;
          } else {
            blocked = true;
          }
        }
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 0),
              curve: Curves.ease);
        }
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  block() async {
    setState(() {
      showProgress = true;
    });
    final response = await http.post(Uri.parse(Urls.BlockChat), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "send_id": UserId,
      "res_id": widget.opId,
    });
    data = json.decode(response.body);
    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        if (data["action"] == 'block') {
          Pop.successTop(context, Lang(" Blocked ", " تم الحظر "), Icons.check);
        } else {
          Pop.successTop(
              context, Lang("Unblocked  ", " تم إلغاء الحظر "), Icons.check);
        }
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _addMessage() async {
    setState(() {
      showProgress = true;
    });

    var request = http.MultipartRequest("POST", Uri.parse(Urls.AddChatMessage));
    request.fields["key"] = Const.APPKEY;
    request.fields["send_id"] = UserId;
    request.fields["res_id"] = widget.opId;
    request.fields["message"] = ETmessgae.text.toString();

    request.fields["pid"] = widget.pid.toString();
    request.fields["pname"] = widget.pname.toString();
    request.fields["pimage"] = widget.pimage.toString();

    if (_image != null) {
      var stream = http.ByteStream(DelegatingStream.typed(_image!.openRead()));
      var length = await _image!.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: path.basename(_image!.path));
      request.files.add(multipartFile);
    }

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        data = json.decode(value);
        if (data["success"] == true) {
          setState(() {
            ETmessgae.clear();
            // finalImage = null;
            imagepath = '';
            showProgress = false;
            widget.pimage = '';
            widget.pid = '';
            widget.pname = '';
            _getServer();
          });
        } else {
          Pop.errorTop(context, Lang("Something wrong", "حدث خطأ ما"),
              Icons.warning);
        }
        print(value);
      });
    }).catchError((e) {
      print(e);
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
            top: false,
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                //   resizeToAvoidBottomPadding: false,
                appBar: AppBar(
                  backgroundColor: TheamPrimary,
                  titleSpacing: 0,
                  elevation: 1,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          _timer.cancel();
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: sy(xl),
                          color: Colors.grey.shade200,
                        ),
                      ),
                      SizedBox(
                        width: sy(5),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(sy(50)),
                        child: CustomeImageView(
                          image: Urls.imageLocation + widget.opImage,
                          width: sy(20),
                          height: sy(20),
                          fit: BoxFit.cover,
                          blurBackground: false,
                        ),
                      ),
                      SizedBox(
                        width: sy(8),
                      ),
                      Text(
                        widget.opName,
                        style: ts_Regular(sy(n), Colors.white),
                      ),
                      Spacer(),
                      if (chat.length != 0 && chat[0]['block'] == '0')
                        GestureDetector(
                          onTap: () {
                            block();
                          },
                          child: Text(
                            Lang(" Block user ", " حظر المستخدم "),
                            style: ts_Regular(sy(s), Colors.grey.shade200),
                          ),
                        ),
                      if (chat.length != 0 && chat[0]['block'] == UserId)
                        GestureDetector(
                          onTap: () {
                            block();
                          },
                          child: Text(
                            Lang(" Unlock user ", " إلغاء حظر المستخدم "),
                            style: ts_Regular(sy(s), Colors.grey.shade200),
                          ),
                        ),
                      SizedBox(
                        width: sy(5),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  decoration: BoxDecoration(
                      color: fc_bg_mild,
                      image: DecorationImage(
                        image: AssetImage('assets/images/chatbg.png'),
                        fit: BoxFit.cover,
                      )),
                  height: Height(context),
                  width: Width(context),
                  child: Stack(
                    children: <Widget>[
                      if (showProgress == false)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: sy(45),
                          child: _screenBody(),
                        ),
                      if (showProgress == false && blocked == false)
                        Positioned(
                          left: sy(5),
                          right: sy(5),
                          bottom: sy(0),
                          child: bottomButtons(),
                        ),
                      if (showProgress == false && chat.length < 3)
                        Positioned(
                            left: sy(5),
                            right: sy(5),
                            top: sy(0),
                            child: GestureDetector(
                              onTap: () {
                                UrlOpenUtils.openurl(_scaffoldKey,
                                    'https://7emiratesapp.ae/terms.php');
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    sy(5), sy(5), sy(5), sy(5)),
                                padding: EdgeInsets.fromLTRB(
                                    sy(5), sy(5), sy(5), sy(5)),
                                decoration: decoration_round(Colors.white70,
                                    sy(10), sy(10), sy(10), sy(10)),
                                child: Text(
                                  Lang(
                                      "Using this chat screen only by accepting our terms and conditions during registration ",
                                      "استخدام شاشة الدردشة هذه فقط من خلال قبول الشروط والأحكام الخاصة بنا أثناء التسجيل "),
                                  style: ts_Regular(sy(s), fc_2),
                                ),
                              ),
                            )),
                      if (blocked == true)
                        Positioned(
                          left: sy(5),
                          right: sy(5),
                          bottom: sy(5),
                          child: Container(
                            margin:
                                EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                            padding:
                                EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                            decoration: decoration_round(
                                Colors.white70, sy(10), sy(10), sy(10), sy(10)),
                            child: Text(
                              Lang(
                                  "User blocked. You can't continue chat with this user. You need to unblock the user ",
                                  " المستخدم المحظور. لا يمكنك متابعة الدردشة مع هذا المستخدم. تحتاج إلى إلغاء حظر المستخدم"),
                              style: ts_Regular(sy(s), fc_2),
                            ),
                          ),
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

  _screenBody() {
    return Container(
      width: Width(context),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: chat.length,
        reverse: true,
        itemBuilder: (context, i) {
          return chatCard(i);
        },
      ),
    );
  }

  bottomButtons() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(5), sy(10), sy(5), sy(5)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              //padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
              //  height: sy(35),
              decoration: decoration_border(
                  fc_bg, fc_bg_mild, 1, sy(20), sy(20), sy(20), sy(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(5), sy(0)),
                      width: Width(context) * 0.50,
                      child: TextField(
                        // enabled: false,
                        controller: ETmessgae,
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          // counter: Offstage(),
                          hintText:
                              Lang(" Type message here", "اكتب الرسالة هنا "),
                          hintStyle: ts_Regular(sy(n), fc_5),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        style: ts_Regular(sy(n), fc_2),
                        textInputAction: TextInputAction.newline,
                        // maxLines: null,
                        autofocus: false,
                      ),
                    ),
                  ),
                  if (_image == null)
                    IconButton(
                      onPressed: () {
                        getImageFile(ImageSource.camera);
                        //  Navigator.pop(context);
                      },
                      icon: Icon(
                        FontAwesomeIcons.camera,
                        size: sy(l),
                        color: fc_3,
                      ),
                    ),
                  if (_image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(sy(10)),
                      child: Image.file(
                        _image!,
                        width: sy(30),
                        height: sy(30),
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: sy(5),
          ),
          FloatingActionButton(
            onPressed: () {
              if (ETmessgae.text == '') {
                Pop.errorTop(
                    context,
                    Lang(" Please type something ", "الرجاء كتابة شيء ما  "),
                    Icons.warning);
              } else {
                _addMessage();
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 18,
            ),
            backgroundColor: TheamPrimary,
            elevation: 0,
          ),
        ],
      ),
    );
  }

  getImageFile(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source, imageQuality: 80);

    final img = ImageCropper();
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
      cropFile = croppedFile;
      imagepath = croppedFile!.path;
      _image = File(croppedFile.path);
    });
  }

  chatCard(int i) {
    if (chat[i]['send_id'] == UserId) {
      return chatCardSelf(i);
    } else {
      return chatCardOther(i);
    }
  }

  chatCardSelf(int i) {
    return Container(
        width: Width(context),
        alignment: Alignment.topRight,
        margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
        child: Container(
          width: Width(context) * 0.6,
          padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
          decoration:
              decoration_round(Color(0xFFE7FFDB), sy(10), sy(5), sy(10), sy(0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chat[i]['c_image'] != '')
                Container(
                    padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(sy(10)),
                      child: CustomeImageView(
                        image:
                            Urls.imageLocation + chat[i]['c_image'].toString(),
                        width: Width(context),
                        height: Width(context) * 0.5,
                        fit: BoxFit.cover,
                        blurBackground: false,
                      ),
                    )),
              Text(
                chat[i]['message'],
                style: ts_Regular(sy(n), fc_3),
              ),
              SizedBox(
                height: sy(8),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CustomeDate.dateTime(chat[i]['c_dated'].toString()),
                    style: ts_Regular(sy(s - 1), fc_3),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  chatCardOther(int i) {
    return Container(
        width: Width(context),
        alignment: Alignment.topLeft,
        margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
        child: Container(
          width: Width(context) * 0.6,
          padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(5)),
          decoration:
              decoration_round(Colors.white, sy(5), sy(15), sy(0), sy(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chat[i]['c_image'] != '')
                Container(
                    padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(sy(10)),
                      child: CustomeImageView(
                        image:
                            Urls.imageLocation + chat[i]['c_image'].toString(),
                        width: Width(context),
                        height: Width(context) * 0.5,
                        fit: BoxFit.cover,
                        blurBackground: false,
                      ),
                    )),
              Text(
                chat[i]['message'],
                style: ts_Regular(sy(n), fc_3),
              ),
              SizedBox(
                height: sy(8),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CustomeDate.dateTime(chat[i]['c_dated'].toString()),
                    style: ts_Regular(sy(s - 1), fc_3),
                  ),
                ],
              )
            ],
          ),
        ));
  }
/*
  _popTerms() {
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
    FontSize fnsize = FontSize.percent(100);
    var style = {
      "margin-left": Style(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
      "h1": Style(
        color: fc_2,
        fontSize: fnsize,
      ),
      "h2": Style(color: fc_2, fontSize: fnsize),
      "h3": Style(color: fc_2, fontSize: fnsize),
      "h4": Style(color: fc_2, fontSize: fnsize),
      "h5": Style(color: fc_2, fontSize: fnsize),
      "h6": Style(color: fc_2, fontSize: fnsize),
      "h7": Style(color: fc_2, fontSize: fnsize),
      "h8": Style(color: fc_2, fontSize: fnsize),
      "p": Style(color: fc_3, fontSize: fnsize),
      "body": Style(color: fc_3, fontSize: fnsize),
      "span": Style(color: fc_3, fontSize: fnsize),
      "a": Style(color: Colors.blue, fontSize: fnsize),
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
                                        child: Html(
                                            shrinkWrap: true,
                                            data: htmlData,
                                            onLinkTap: (String? url,
                                                RenderContext mcontext,
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
