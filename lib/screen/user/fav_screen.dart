import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../layout/product_card_community.dart';
import '../../layout/product_card_main.dart';
import 'product_view_screen.dart';

class FavScreen extends StatefulWidget {
  FavScreen({Key? key}) : super(key: key);

  @override
  _FavScreenState createState() {
    return _FavScreenState();
  }
}

class _FavScreenState extends State<FavScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String? UserId;
  bool showProgress = false;
  Map data = Map();
  List favList = [];
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
      _getServer();

    });
  }

  _getServer() async {
    setState(() {
      showProgress = true;
    });
    apiTest(UserId.toString());
    final response = await http.post(Uri.parse(Urls.FavouriteList), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": UserId.toString(),
    });

    data = json.decode(response.body);
    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        favList=data['favouritelist'];
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
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
            child: Scaffold(
              key: _scaffoldKey,
              //   resizeToAvoidBottomPadding: false,
              bottomNavigationBar: BottomNavigationWidget(ishome: false,mcontext: context,order: 0,),
              body: Container(
                decoration: BoxDecoration(
                  color: favList.length == 0 ? fc_bg : fc_bg2,
                ),
                height: Height(context),
                width: Width(context),
                child: _screenBody(),
              ),
            ),
          )
      ),
    );
  }

  titlebar() {
    return Container(
      width: Width(context),
      //height: sy(180),
      color: fc_bg,
      child: Column(
        children: [
          SizedBox(height: sy(3),),
          Row(
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
          ),
          SizedBox(height: sy(3),),
          Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   // height: sy(45),
                //   alignment: Alignment.topLeft,
                //   child: Text(
                //       Lang("You can find  ", " يمكنك إيجاد "),
                //     style: ts_Bold(sy(xl), fc_1),
                //   ),
                // ),
                // SizedBox(
                //   height: sy(5),
                // ),
                Container(
                  // height: sy(45),
                  alignment: Alignment.topLeft,
                  child: Text(
                   Lang("  favourites ", "   المفضلة "),
                    style: ts_Bold(sy(xl), fc_1),
                  ),
                ),
                SizedBox(
                  height: sy(15),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }


  _screenBody() {
    return Container(
      width: Width(context),
      height: Height(context),
      color: fc_bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          titlebar(),
          Expanded(child:Container(
            width: Width(context),
            child:  SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Container(
                // color: Colors.white,
                width: Width(context),
                child: Column(
                  children: [

                    if(favList.length == 0 && showProgress == false)emptyWidget(),
                    if(favList.length != 0 && showProgress == false)favWidget(),
                    if(showProgress == true)LoadingPlacement(
                      width: Width(context), height: Height(context) * 0.7,),


                  ],
                ),
              ),
            ),
          ))

        ],
      ),
    );
  }


  favWidget() {
    return Container(
      color: fc_bg_mild,
      width: Width(context),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              child: FadeInAnimation(child: widget),
            ),
            children: [

              for (int i = 0; i < favList.length; i++)
                Container(
                  margin: EdgeInsets.fromLTRB(sy(7), sy(2), sy(7), sy(3)),
                  child:  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          OpenScreen(
                              widget: ProductViewScreen(
                                pid:favList[i]["p_id"],
                                pname:favList[i]["p_title"],
                                pimage:favList[i]["p_image"],
                              )));
                    },
                    style: elevatedButtonTrans(),
                    child: (favList[i]['c_id']!=Const.COMMUNITY_ID && favList[i]['c_id']!=Const.JOBS_ID)? ProductCardMain(i: i, getProducts: favList): ProductCardCommunityMain(i: i, getProducts: favList,mcontext: context,),

                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }



  emptyWidget() {
    return Container(
      width: Width(context),
      child: Column(
        children: [
          SizedBox(height: sy(20),),
          // Image.asset('assets/images/chatico.png',
          //   width: Width(context) * 0.2,
          // ),
          Image.asset('assets/images/no_fav.png',
          // Image.asset('assets/images/emptyimg.png',
            width: Width(context) * 0.7,
          ),
          SizedBox(height: sy(10),),
          Text(Lang("No favourite listing found  ", "لم يتم العثور على قائمة مفضلة  "), style: ts_Regular(sy(n), fc_3),),
          SizedBox(height: sy(20),),
        ],
      ),
    );
  }

}