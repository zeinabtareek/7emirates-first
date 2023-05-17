import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/widget_help.dart';
import 'package:sevenemirates/router/right_open_screen.dart';
import 'package:sevenemirates/screen/user/chat_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory extends StatefulWidget {
  ChatHistory({Key? key}) : super(key: key);

  @override
  _ChatHistoryState createState() {
    return _ChatHistoryState();
  }
}

class _ChatHistoryState extends State<ChatHistory> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String? UserId;
  bool showProgress = false;
  Map data = Map();
  List chatList = [];
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
      UserId = Provider.of<AppSetting>(context, listen: false).uid;
      _getServer(pageCount);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount = pageCount + 1;
          });
          _getServer(pageCount);
        }
      });
    });
  }

  _getServer(int pagenumber) async {
    setState(() {
      showProgress = true;
    });
    apiTest(UserId.toString());
    final response = await http.post(Uri.parse(Urls.ChatHistory), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": UserId.toString(),
      "page": pagenumber.toString(),
    });

    data = json.decode(response.body);
    log('data $data');
    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        chatList = data['chat'];
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
                // key: _scaffoldKey,
                //   resizeToAvoidBottomPadding: false,
                bottomNavigationBar: BottomNavigationWidget(
                  ishome: false,
                  mcontext: context,
                  order: 3,
                ),
                body: Container(
                  decoration: BoxDecoration(
                    color: chatList.length == 0 ? fc_bg : fc_bg2,
                  ),
                  height: Height(context),
                  width: Width(context),
                  child: _screenBody(),
                ),
              ),
            ),
          )),
    );
  }

  titlebar() {
    return Container(
      width: Width(context),
      //height: sy(180),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: sy(3),
          ),
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
          SizedBox(
            height: sy(3),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // height: sy(45),
                  alignment: Alignment.topLeft,
                  child: Text(
                    Lang(" What would you ", "ماذا تريد أن تناقش"),
                    style: ts_Bold(sy(xl), fc_1),
                  ),
                ),
                SizedBox(
                  height: sy(5),
                ),
                Container(
                  // height: sy(45),
                  alignment: Alignment.topLeft,
                  child: Text(
                    Lang(" like to discuss ? ", ""),
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
      // color: fc_bg_mild,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titlebar(),
          Expanded(
              child: Container(
            width: Width(context),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Container(
                width: Width(context),
                child: Column(
                  children: [
                    if (chatList.length == 0 && showProgress == false)
                      emptyWidget(),
                    if (chatList.length != 0 && showProgress == false)
                      chatWidget(),
                    if (showProgress == true)
                      LoadingPlacement(
                        width: Width(context),
                        height: Height(context) * 0.7,
                      ),
                  ],
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }

  chatWidget() {
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
              horizontalOffset: MediaQuery.of(context).size.width * 0.8,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              for (int i = 0; i < chatList.length; i++) chatCard(i),
            ],
          ),
        ),
      ),
    );
  }

  chatCard(int i) {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(4)),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              RightOpenScreen(
                  widget: ChatScreen(
                opId: chatList[i]['ouid'].toString(),
                opName: chatList[i]['name'].toString(),
                opImage: chatList[i]['profilepic'].toString(),
              )));
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          elevation: 1,
          padding: EdgeInsets.fromLTRB(sy(4), sy(5), sy(4), sy(5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sy(0)),
          ),
        ),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WidgetHelp.profilePic(chatList[i]['profilepic'],
                  chatList[i]['name'], sy(35), sy(35), sy(40)),
              SizedBox(
                width: sy(8),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatList[i]['name'],
                    style: ts_Regular(sy(n), fc_2),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: sy(5),
                  ),
                  Text(
                    CustomeDate.dateTime(chatList[i]['c_dated']),
                    style: ts_Regular(sy(s), fc_4),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ))
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
          SizedBox(
            height: sy(20),
          ),
          // Image.asset('assets/images/chatico.png',
          //   width: Width(context) * 0.2,
          // ),
          Image.asset(
            'assets/images/no_chat.png',
            // 'assets/images/emptyimg.png',
            width: Width(context) * 0.7,
          ),
          SizedBox(
            height: sy(10),
          ),
          Text(
            Lang("No chat history found  ",
                "لم يتم العثور على سجل الدردشة  "),
            style: ts_Regular(sy(n), fc_3),
          ),
          SizedBox(
            height: sy(20),
          ),
        ],
      ),
    );
  }
}
