import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutScreen extends StatefulWidget {
  AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() {
    return _AboutScreenState();
  }
}

class _AboutScreenState extends State<AboutScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String? UserId;
  bool showProgress = false;
  Map data = Map();
  List userDetail = [];
  int pageCount = 1;
  ScrollController _scrollController = ScrollController();

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
      // UserId = prefs.getString(Const.UID) ?? '';
      UserId = Provider
          .of<AppSetting>(context, listen: false)
          .uid;

    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initRelativeScaler(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: Provider
          .of<AppSetting>(context)
          .appTheam,
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
            top: false,
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
            
                // key: _scaffoldKey,
                //   resizeToAvoidBottomPadding: false,
                body: Container(
                  decoration: BoxDecoration(
                    color: TheamPrimary,
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
            
                      Positioned(
                        top: sy(25),
                        left: sy(5),
                        child: IconButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_rounded,size: sy(xl),color: Colors.white,),
                        ),
                      ),
                      // MyProgressBar(showProgress),
            
                    ],
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }

  _screenBody() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
        width: Width(context),
        height: Height(context),
        padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[


            Container(
              child: Image.asset('assets/images/logoonly.png',width: Width(context)*0.3 ),
            ),

            SizedBox(height: sy(10),),
            Text(Const.AppName,style: ts_Bold(sy(n), Colors.grey[300]),textAlign: TextAlign.center,),
            Text(Const.AppDescription,style: ts_Regular(sy(s), Colors.grey[300]),textAlign: TextAlign.center,),
            SizedBox(height: sy(25),),


            //Contact
            Text(Lang("CONTACT  ", " التواصل "),style: ts_Bold(sy(l), Colors.white),),
            SizedBox(height: sy(5),),
            Text(Lang("4th Floor\nAli & Sons Real Estate Company Building\nZone 48 C55\nAirport Road - AbuDhabi Rawdhat Area\nAbu Dhabi, UAE\n(+971) 02 6440464   ", " الطابق الرابع \n مبنى شركة علي وأولاده العقارية \n المنطقة 48 C55 \n طريق المطار - أبو ظبي منطقة الروضة \n أبو ظبي ، الإمارات العربية المتحدة \n (+971) 02 6440464 "),style: ts_Regular(sy(s),  Colors.grey[300]),textAlign: TextAlign.center,),
            SizedBox(height: sy(15),),

            Row(
              children: [

                Expanded(child: GestureDetector(
                  onTap: (){
                    UrlOpenUtils.call(_scaffoldKey, Const.WHATSAPPNUMBER);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(sy(5), sy(8), sy(5), sy(8)),
                    margin: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(10)),
                    decoration: decoration_round(TheamPrimary, sy(0), sy(0), sy(0), sy(0)),
                    child: Text(Lang(" Call us ", " اتصل بنا "),style: ts_Regular(sy(s), Colors.white),),
                  ),
                )),
                Expanded(child: GestureDetector(
                  onTap: (){
                    UrlOpenUtils.email(_scaffoldKey);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(sy(5), sy(8), sy(5), sy(8)),
                    margin: EdgeInsets.fromLTRB(sy(5), sy(10), sy(5), sy(10)),
                    decoration: decoration_round(TheamPrimary, sy(0), sy(0), sy(0), sy(0)),
                    child: Text(Lang(" Email us ", " راسلنا عبر البريد الإلكتروني ") ,style: ts_Regular(sy(s), Colors.white),),
                  ),
                )),
                Expanded(child: GestureDetector(
                  onTap: (){
                    UrlOpenUtils.openurl(_scaffoldKey, 'https://7emiratesapp.ae/');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(sy(5), sy(8), sy(5), sy(8)),
                    margin: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(10)),
                    decoration: decoration_round(TheamPrimary, sy(0), sy(0), sy(0), sy(0)),
                    child: Text(Lang(" Visit Site ", " تفضل بزيارة الموقع "),style: ts_Regular(sy(s), Colors.white),),
                  ),
                )),

              ],
            ),
            SizedBox(height: sy(10),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                GestureDetector(
                  onTap: (){
                    UrlOpenUtils.openurl(_scaffoldKey, 'https://7emiratesapp.ae/privacy.php');

                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(sy(5), sy(8), sy(5), sy(8)),
                    margin: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(10)),

                    child: Text(Lang(" Privacy Policy ", " سياسة الخصوصية "),style: ts_Regular_underline(sy(s), Colors.grey[200]),),
                  ),
                ),
                SizedBox(width: sy(5),),
                GestureDetector(
                  onTap: (){
                    
                    UrlOpenUtils.openurl(_scaffoldKey, 'https://7emiratesapp.ae/terms.php');

                   },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(sy(5), sy(8), sy(5), sy(8)),
                    margin: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(10)),

                    child: Text(Lang("Terms & Condition  ", " الشروط والأحكام "),style: ts_Regular_underline(sy(s), Colors.grey[200]),),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

}