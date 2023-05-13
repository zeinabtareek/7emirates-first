import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/widget_help.dart';
import 'package:sevenemirates/screen/user/product_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/image_viewer.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';

class SubCategoryScreen extends StatefulWidget {
  String cid='';
   SubCategoryScreen({Key? key,this.cid=''}) : super(key: key);

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> with RelativeScale {
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
        child: Scaffold(
          bottomNavigationBar: BottomNavigationWidget(ishome: false,mcontext: context,order: 2),
          key: _scaffoldKey,
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
                  top: sy(110),
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _screenBody(),
                ),
              ],
            ),
          ),
        ),

      )),
    );
  }

  _screenBody() {
    return Container(
      width: Width(context),
      decoration: decoration_round(fc_bg_mild, sy(0), sy(0), sy(0), sy(0)),
      child: SingleChildScrollView(
          //    physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              subCategoryWidget(),
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
              child: Row(
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

                ],
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
          //  alignment: Alignment.topLeft,
            child: Text(
                        Lang("What would you like in  ", " ماذا تريد في "),
              style: ts_Bold(sy(xl), fc_1),
            ),
          ),
          SizedBox(
            height: sy(5),
          ),
          Container(
            // height: sy(45),
          //  alignment: Alignment.topLeft,
            child: Text(
              WidgetHelp.getNameFromId(widget.cid, Const.categoryList, 'c_id', 'c_name$cur_Lang'),
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

  subCategoryWidget() {
    return Container(
      color: fc_bg_mild,
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

              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        OpenScreen(
                            widget: ProductListScreen(
                              sid: '',
                              cid: widget.cid,
                            )));

                  },
                  child: Container(
                      margin: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(5)),
                      color: fc_bg,
                      child:Material(
                        borderRadius: BorderRadius.circular(sy(5)),
                        elevation: 0,
                        color: fc_bg,
                        child: Row(
                          children: [

                            Container(
                              child:  CustomeImageView(
                                image: Urls.imageLocation +
                                    WidgetHelp.getNameFromId(widget.cid, Const.categoryList, 'c_id', 'c_image')
                                        .toString(),
                                placeholder: Urls.DummyImageBanner,
                                fit: BoxFit.cover,
                                height: Width(context) * 0.12,
                                width: Width(context) * 0.12,
                                radius: sy(5),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                              child:  Text(
                                          Lang(" All in ", " الكل فى ")+' '+
                                WidgetHelp.getNameFromId(widget.cid, Const.categoryList, 'c_id', 'c_name$cur_Lang'),
                                style: ts_Regular(sy(n), fc_2),
                              ),
                            )
                          ],
                        ),
                      )
                  )
              ),

              for (var i = 0; i < Const.subcategoryList.length; i++)
                if(widget.cid=='' || widget.cid==Const.subcategoryList[i]['c_id'])
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        OpenScreen(
                            widget: ProductListScreen(
                              sid: Const.subcategoryList[i]["sc_id"],
                              cid: widget.cid,
                            )));

                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(5)),
                    color: fc_bg,
                    child:Material(
                      borderRadius: BorderRadius.circular(sy(5)),
                      elevation: 0,
                      color: fc_bg,
                      child: Row(
                        children: [
                          Container(
                            child:  CustomeImageView(
                              image: Urls.imageLocation +
                                  Const.subcategoryList[i]["sc_image"]
                                      .toString(),
                              placeholder: Urls.DummyImageBanner,
                              fit: BoxFit.cover,
                              height: Width(context) * 0.12,
                              width: Width(context) * 0.12,
                              radius: sy(5),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                              child:  Text(
                              Const.subcategoryList[i]["sc_title$cur_Lang"].toString(),
                              style: ts_Regular(sy(n), fc_2),
                            ),
                          )
                        ],
                      ),
                    )
                  )
                ),



            ],
          ),
        ),
      ),
    );
  }

}
