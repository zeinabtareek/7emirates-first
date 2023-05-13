import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/screen/user/store_booking_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/relative_scale.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/currency_convert.dart';
import '../../utils/style_sheet.dart';
import '../../utils/translation_widget.dart';
import '../../utils/urls.dart';

class StoreBookingScreen extends StatefulWidget {
  @override
  _StoreBookingScreenState createState() => _StoreBookingScreenState();
}

class _StoreBookingScreenState extends State<StoreBookingScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  Map data = Map();
  List ordersList = [];
  String phone = '',
      uId = '',
      ProfilePic = '',
      Name = '';
  // ScrollController _scrollController = new ScrollController();
  int pageCount = 1;

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
      phone = prefs.getString(Const.PHONE) ?? '';
      uId = prefs.getString(Const.UID) ?? '';
      Name = prefs.getString(Const.NAME) ?? '';
      ProfilePic = prefs.getString(Const.PROFILE) ?? '';
    });

    _myProducts();

  }

  _myProducts() async {
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.StoreBooking),
        headers: {
          HttpHeaders.acceptHeader: Const.POSTHEADER
        },
        body: {
          "key": Const.APPKEY,
          "uid": uId,
        });
    data = json.decode(response.body);


    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        ordersList=data['orders'];
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
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
              bottomNavigationBar: BottomNavigationWidget(mcontext: context,ishome: false,order: 0,),
              body: Stack(
                children: <Widget>[
                  _screenBody(),
                ],
              )),
        ),
      )
    );
  }

  _screenBody() {
    return Container(
      width: Width(context),
      height: Height(context),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          titlebar(),
          Expanded(child:Container(
            width: Width(context),
            color: fc_bg_mild,
            child:  SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Container(
                width: Width(context),
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if(showProgress==true)LoadingPlacement(width: Width(context), height:  Width(context)),
                    if (ordersList.length == 0 && showProgress!=true) emptyCart(),
                    if (ordersList.length != 0) productListing(),
                    SizedBox(
                      height: sy(80),
                      width: 50,
                    )
                  ],
                ),
              ),
            ),
          ))

        ],
      ),
    );
  }

  titlebar() {
    return Container(
      width: Width(context),
      color: fc_bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sy(3),),
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
          SizedBox(height: sy(3),),
          Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                       Lang(" Your Orders ", " طلباتك "),
                  style: ts_Bold(sy(xl), fc_1),
                ),
                SizedBox(
                  height: sy(5),
                ),
                Text(
                       Lang(" Lets view your orders ", "لنرى طلباتك  "),
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

  productListing() {
    return AnimationLimiter(
      child: SingleChildScrollView(
        child: Wrap(
          verticalDirection: VerticalDirection.down,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              for (var i = 0; i < ordersList.length; i++)
                Container(
                margin: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(3)),
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.pushReplacement(context, OpenScreen(widget: StoreBookingViewScreen(oid: ordersList[i]['o_id'],)));
                    },
                    style: elevatedButtonTrans() ,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              CustomeImageView(image: Urls.imageLocation+ordersList[i]['p_image'].toString(),
                                width: Width(context)*0.3,
                                height: Width(context)*0.25,
                                radius: sy(5),
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: sy(5),),
                              Expanded(child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(CustomeDate.datedaymonth(ordersList[i]['o_dated'].toString()),style: ts_Regular(sy(s), fc_4),maxLines: 2,),

                                      Spacer(),
                                      Text('#7EB0'+ordersList[i]['o_id'].toString(),style: ts_Bold(sy(s), fc_5),maxLines: 2,),

                                    ],
                                  ),
                                  SizedBox(height: sy(3),),
                                  TranslationWidget(
                                    message :
                                    ordersList[i]['p_title'].toString(),style: ts_Bold(sy(n), fc_3),maxLines: 2,),
                                  SizedBox(height: sy(4),),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                                          decoration: decoration_round(Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                                          child: Text(
                                            ordersList[i]["c_name$cur_Lang"].toString().toUpperCase(),
                                            style: ts_Regular(sy(s-1), fc_4),
                                            maxLines: 1,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(sy(1), 0, sy(1), 0),
                                          child: Icon(Icons.arrow_right,size: sy(n),color: fc_5,),
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                                          decoration: decoration_round(Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                                          child: Text(
                                            ordersList[i]["sc_title$cur_Lang"].toString().toUpperCase(),
                                            style: ts_Regular(sy(s-1), fc_4),
                                            maxLines: 1,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  SizedBox(height: sy(10),),

                                  Row(
                                    children: [
                                      Text(PriceUtils.convert(ordersList[i]['total_price'].toString()),style: ts_Bold(sy(n), fc_3),maxLines: 2,),

                                      Spacer(),
                                      cardOrderStatus(ordersList[i]['method']),
                                      SizedBox(width: sy(5),),
                                      cardOrderStatus(ordersList[i]['o_status'])

                                    ],
                                  )
                                ],
                              ))

                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ),
            ],
          ),
        ),
      ),
    );
  }


  cardOrderStatus(String status){
    Color Darkclr=Colors.green;
    String lable=Lang( "Accepted "  , "تمت الموافقة " );
    if(status=='A'){
      Darkclr=Colors.green;
      lable=Lang( "Accepted "  , "تمت الموافقة " );
    }
    if(status=='P'){
      Darkclr=Colors.blue;
      lable=Lang( "Pending "  , "قيد الانتظار " );
    }
    if(status=='R'){
      Darkclr=Colors.red;
      lable=Lang( "Declined "  , "تم الرفض " );
    }
    if(status=='S'){
      Darkclr=Colors.purple;
      lable=Lang( "Declined "  , "تم الرفض " );
    }
    if(status=='D'){
      Darkclr=Colors.grey;
      lable=Lang( "Declined "  , "تم الرفض " );
    }



    if(status=='D'){
      Darkclr=Colors.grey;
      lable=Lang( "Declined "  , "تم الرفض " );
    }
    if(status=='COD'){
      Darkclr=Colors.teal;
      lable=Lang( "COD "  , "سمك القد " );
    }
    if(status=='PAID'){
      Darkclr=Colors.green;
      lable=Lang( "PAID "  , "تم الدفع " );
    }
    return Container(
      decoration: decoration_round(Darkclr.withOpacity(0.3), sy(3), sy(3), sy(3), sy(3)),
      padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
      child: Text(lable,style: ts_Regular(sy(s-1), Darkclr),),

    );
  }



  emptyCart() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: sy(30),
          ),
          Image.asset(
            'assets/images/emptyimg.png',
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
          ),
          SizedBox(
            height: sy(10),
          ),
          Text(
            Lang(" No orders found ", "لم يتم العثور على أية طلبات  "),
            style: ts_Regular(sy(n), fc_2),
          ),
        ],
      ),
    );
  }

}
