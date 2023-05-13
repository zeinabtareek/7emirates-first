import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/layout/product_card_community.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/user/product_view_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../layout/product_card_main.dart';


class SearchScreen extends StatefulWidget {

  SearchScreen({Key? key,   }) : super(key: key);

  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String? UserId;
  bool showProgress = false;
  Map data = Map();
  int pageCount = 1;
  // ScrollController _scrollController = ScrollController();
  TextEditingController ETname = TextEditingController();


  bool vname = false;
  List productList = [];
  List doctorList = [];

  bool hasText=false;
  String tab="all";
  int fromSearch=0;


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
      UserId = Provider.of<AppSetting>(context, listen: false).uid;


    });

  }


  getProduct(String val) async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.searchList),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
        body: {"key": Const.APPKEY,
          "word": val.toString(),
        });
    data = json.decode(response.body);


    setState(() {
      showProgress = false;
      if (data["success"] == true) {

        productList.clear();

        productList = data["products"];

        tab='all';

      } else {
        Pop.errorTop(context,  Lang( "Something wrong" , "حدث خطأ ما" ), Icons.warning);

      }
    });
//    debugPrint("category --" + productList.toString());
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
              body: Container(
                decoration: BoxDecoration(
                  color: productList.length == 0 ? fc_bg : fc_bg,
                ),
                height: Height(context),
                width: Width(context),
                child: Stack(
                  children: <Widget>[

                    Positioned(
                      top: sy(75),
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _screenBody(),
                    ),

                    Positioned(
                      child: titleMenu(),
                      top: sy(5),
                      left: 0,
                      right: 0,
                    ),
                    Positioned(
                      child: tabButtons(),
                      top: sy(45),
                      left: 0,
                      right: 0,
                    ),
                    // MyProgressBar(showProgress),

                  ],
                ),
              ),
            ),
          )
      ),
    );
  }

  tabButtons(){
    return Container(
        width: Width(context),
        // height: sy(25),
        padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(0)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [

              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                  setState(() {
                    tab="all";
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(sy(20), sy(2), sy(20), sy(5)),
                  //  margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(3), sy(0)),
                  decoration: BoxDecoration(
                      border: Border( bottom: BorderSide(
                        color: TheamButton,
                        width: (tab=="all")?sy(2):sy(1), // This would be the width of the underline
                      ))
                  ),
                  child: Text(Lang(" All ", " الجميع "),style: ts_Regular(sy(n),  (tab=="all")?fc_1:fc_3),),
                ),
              ),
              for(int i=0;i<Const.categoryList.length;i++)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      tab=Const.categoryList[i]['c_id'];
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(sy(20), sy(2), sy(20), sy(5)),
                    //  margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(3), sy(0)),
                    decoration: BoxDecoration(
                        border: Border( bottom: BorderSide(
                          color: TheamButton,
                          width: (tab==Const.categoryList[i]['c_id'])?sy(2):sy(0), // This would be the width of the underline
                        ))
                    ),
                    child: Text(Const.categoryList[i]['c_name$cur_Lang'],style: ts_Regular(sy(n),  (tab==Const.categoryList[i]['c_id'])?fc_1:fc_3),),
                  ),
                ),


            ],
          ),
        )
    );
  }

  _screenBody() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
        width: Width(context),
        color: fc_bg_mild,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[


            categoryWidget(),


            if(productList.length == 0 && showProgress == false&& ETname.text.length==0)introWidget(),
            if(showProgress == true)LoadingPlacement(
              width: Width(context), height: Height(context) * 0.7,),


          ],
        ),
      ),
    );
  }

  titleMenu() {
    return Container(

      margin: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
      height: sy(35),
      decoration: BoxDecoration(
        color: fc_bg,
        borderRadius: BorderRadius.circular(sy(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: sy(28),
                height: sy(28),
                decoration: decoration_round(TheamPrimary, sy(20), sy(20), sy(20), sy(20)),
                child:  IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: sy(l),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                  },
                ),
              ),
              Expanded(
                child: Container(

                  padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(5), sy(0),),
                  height: sy(35),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (fromSearch==0)?TextField(
                    controller: ETname,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.name,
                    maxLines: 1,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: Lang("Type here to find something  ", "اكتب هنا للعثور على شيء ما  "),
                        hintStyle: ts_Regular(sy(n), fc_3),
                        focusedBorder: null),

                    onChanged: (val){
                      setState(() {
                        if(val.length%2==0){
                          productList.clear();
                          getProduct(val);
                        }
                        hasText=true;
                      });

                    },
                    style: ts_Regular(sy(n), fc_1),
                  ):Container(child: Text(Lang(" Search Results ", " نتائج البحث "),style: ts_Regular(sy(n), fc_1),),alignment: Alignment.centerLeft,),
                ),),


            ],
          ),
        ),
      ),

    );
  }

  categoryWidget(){
    List tempArray=[];
    if(tab=='all'){
      tempArray=productList;
    }else{
      for(int j=0;j<productList.length;j++)
        if(productList[j]['c_id']==tab){
          tempArray.add(productList[j]);
        }
    }
    return Container(
      width: Width(context),
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: sy(3),
        children: [

          if(tempArray.length==0 && ETname.text.length!=0)emptyWidget(),
          for(int i=0;i<tempArray.length;i++)
            Container(
              margin: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
              child:  ElevatedButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      OpenScreen(
                          widget: ProductViewScreen(
                            pid:tempArray[i]["p_id"],
                            pname:tempArray[i]["p_title"],
                            pimage:tempArray[i]["p_image"],
                          )));
                },
                style: elevatedButtonTrans(),
                child: (tempArray[i]['c_id']!=Const.COMMUNITY_ID && tempArray[i]['c_id']!=Const.JOBS_ID)? ProductCardMain(i: i, getProducts: tempArray): ProductCardCommunityMain(i: i, getProducts: tempArray,mcontext: context,),

              ),
            ),



        ],
      ),
    );
  }






  emptyWidget() {
    return Container(
      color: fc_bg,
      width: Width(context),
      child: Column(
        children: [
          SizedBox(height: sy(50),),
          Image.asset('assets/images/emptyimg.png',
            width: Width(context) * 0.5,
          ),
          SizedBox(height: sy(10),),
          Text(Lang(" No items found ", " لم يتم العثور على العناصر "), style: ts_Regular(sy(n), fc_3),),
          SizedBox(height: sy(20),),
        ],
      ),
    );
  }

  introWidget() {
    return Container(
      width: Width(context),
      color: fc_bg,
      padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: sy(30),),
          Text(Lang("Search what you need  ", "ابحث عما تريد  "), style: ts_Bold(sy(l), fc_1),),
          SizedBox(height: sy(10),),
          Text(Lang(" We will short a personalised products/service for you. so there is always something to find on your phone ", " سنقوم باختصار المنتجات / الخدمات الشخصية لك. لذلك هناك دائمًا ما تجده على هاتفك "), style: ts_Regular(sy(s), fc_2),),
          SizedBox(height: sy(15),),
          Center(
            child:  Image.asset('assets/images/shopping2.png',
              width: Width(context) * 0.8,
            ),
          ),
          SizedBox(height: sy(10),),
        ],
      ),
    );
  }
}