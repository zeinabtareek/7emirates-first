import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/screen/user/sub_category_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/image_viewer.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String UserId = '';

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
      UserId = prefs.getString(Const.UID) ?? '';
      // name = prefs.getString(Const.NAME) ?? '';
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
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                bottomNavigationBar: BottomNavigationWidget(
                    ishome: false, mcontext: context, order: 2),
                // key: _scaffoldKey,
                body: Container(
                  color: Colors.white,
                  height: Height(context),
                  width: Width(context),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: sy(0),
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: titlebar(),
                      ),
                      Positioned(
                        top: sy(100),
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _screenBody(),
                      ),
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
      decoration: decoration_round(fc_bg, sy(0), sy(0), sy(0), sy(0)),
      child: SingleChildScrollView(
          //    physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              categoryWidget(),
            ],
          )),
    );
  }

  titlebar() {
    return Container(
      width: Width(context),
      //height: sy(180),
      child: Stack(
        children: [
          Positioned(
              top: sy(5),
              left: sy(5),
              right: sy(5),
              child: Container(
                child: Row(
                  // textDirection:  Const.AppLanguage == 0 ? TextDirection.ltr : TextDirection.rtl,
                  children: [
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

                    Spacer(),
                    //
                    // Text(
                    //   Const.AppName,
                    //   style: ts_Regular(sy(n), fc_bg),
                    // ),
                  ],
                ),
              )),
          Positioned(top: sy(30), left: sy(5), right: sy(5), child: nameBar()),
        ],
      ),
    );
  }

  nameBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(15), sy(10), sy(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // height: sy(45),
            // alignment: Alignment.topLeft,
            child: Text(
              Lang("What would you", "ما الذي  "),
              style: ts_Bold(sy(xl), fc_1),
            ),
          ),
          SizedBox(
            height: sy(5),
          ),
          Container(
            // height: sy(45),
            //    alignment: Alignment.topLeft,
            child: Text(
              Lang(" like to list today ? ", "ترغب في قائمة اليوم؟  "),
              style: ts_Bold(sy(xl), fc_1),
            ),
          ),
          SizedBox(
            height: sy(10),
          ),
        ],
      ),
    );
  }

  categoryWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      // padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(5)),
      child: AnimationLimiter(
        child: Wrap(
          direction: Axis.horizontal,
          //   spacing: sy(2),
          runSpacing: sy(0),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width / 2,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              for (var i = 0; i < Const.categoryList.length; i++)
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        apiTest(Const.categoryList[i]["c_id"]);
                        Navigator.push(
                            context,
                            OpenScreen(
                                widget: SubCategoryScreen(
                              cid: Const.categoryList[i]["c_id"],
                            )));
                      },
                      child: Container(
                          height: Width(context) * 0.5,
                          width: Width(context) * 0.5,
                          // color: Colors.blue,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: sy(0),
                                right: 0,
                                top: 0,
                                left: 0,
                                child: CustomeImageView(
                                  image: Urls.imageLocation +
                                      Const.categoryList[i]["c_image"]
                                          .toString(),
                                  placeholder: Urls.DummyImageBanner,
                                  fit: BoxFit.contain,
                                  height: Width(context) * 0.4,
                                  width: Width(context) * 0.4,
                                ),
                              ),
                              Positioned(
                                  left: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        sy(15), sy(3), sy(20), sy(3)),
                                    decoration: decoration_round(TheamPrimary,
                                        sy(0), sy(5), sy(0), sy(0)),
                                    child: Text(
                                      Const.categoryList[i]["c_name$cur_Lang"],
                                      style: ts_Regular(sy(n), fc_bg),
                                    ),
                                  ))
                            ],
                          )),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
