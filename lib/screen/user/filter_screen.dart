import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/user/product_list.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/currency_convert.dart';

class FilterScreen extends StatefulWidget {
  String cid = '';
  String sid = '';
  String lable = '';
  double minPrice = 0;
  double maxPrice = 100000;
  String usage = '';
  FilterScreen(
      {Key? key,
      this.cid = '',
      this.sid = '',
      this.minPrice = 0,
      this.maxPrice = 100000,
      this.lable = '',
      this.usage = ''})
      : super(key: key);

  @override
  _FilterScreenState createState() {
    return _FilterScreenState();
  }
}

class _FilterScreenState extends State<FilterScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String? UserId;
  bool showProgress = false;
  Map data = Map();
  ScrollController _scrollController = ScrollController();

  //cat
  String selectCategory = "";

  //Subcat
  String selectSubCategoryString = "";
  List selectSubCategory = [];

  //lable
  String selectLableString = "";
  List selectLable = [];

  String selectedUsedString = '';
  List selectUsed = [];

  //range
  var selectedRange;

  @override
  void initState() {
    super.initState();
    selectedRange = RangeValues(0, 100000);
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

      selectedRange = RangeValues(widget.minPrice, widget.maxPrice);

      selectCategory = widget.cid;

      selectSubCategoryString = widget.sid;
      selectSubCategory = (selectSubCategoryString != '')
          ? selectSubCategoryString.split(',')
          : [];

      selectLableString = widget.lable;
      selectLable =
          (selectLableString != '') ? selectLableString.split(',') : [];

      selectedUsedString = widget.usage;
      selectUsed =
          (selectedUsedString != '') ? selectedUsedString.split(',') : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initRelativeScaler(context);
    return WillPopScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: Provider.of<AppSetting>(context).appTheam,
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
                  appBar: AppBar(
                    backgroundColor: fc_bg,
                    titleSpacing: 0,
                    elevation: 1,
                    title: Text(
                      Lang("Filters ", "الفلترة "),
                      style: ts_Regular(sy(n), TheamPrimary),
                    ),
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_sharp,
                        size: sy(n),
                        color: TheamPrimary,
                      ),
                    ),
                    actions: [],
                  ),
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
                        Positioned(
                          child: bottomButton(),
                          bottom: sy(5),
                          left: sy(5),
                          right: sy(5),
                        ),
                        // MyProgressBar(showProgress),
                      ],
                    ),
                  ),
                ),
              )),
        ),
        onWillPop: () => _backBtn());
  }

  _backBtn() {
    Navigator.pushReplacement(
        context,
        OpenScreen(
            widget: ProductListScreen(
          cid: selectCategory,
          sid: selectSubCategoryString,
          minPrice: selectedRange.start,
          maxPrice: selectedRange.end,
          lable: selectLableString,
          usage: selectedUsedString,
        )));
  }

  _screenBody() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
        width: Width(context),
        color: fc_bg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              width: Width(context),
              margin: EdgeInsets.fromLTRB(0, sy(3), 0, 0),
              child: ExpandablePanel(
                header: Container(
                    alignment: Alignment.centerLeft,
                    height: sy(35),
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Row(
                      children: [
                        Text(
                          Lang("By Category  ", " حسب الفئة ").toString(),
                          style: ts_Regular(sy(n), Colors.black),
                        ),
                        // SizedBox(width: sy(5),),
                        // Container(decoration: decoration_round(TheamPrimary.withOpacity(0.2), sy(5), sy(5), sy(5), sy(5)),
                        //   padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(3)),
                        //   child:  Text(Const.categoryList.length.toString() ,style: ts_Bold(sy(s), TheamPrimary),),
                        //   )
                      ],
                    )),
                expanded: categoryBlock(),
                collapsed: SizedBox(
                  width: 0,
                ),
              ),
            ),
            divLine(),
            Container(
              color: Colors.white,
              width: Width(context),
              margin: EdgeInsets.fromLTRB(0, sy(3), 0, 0),
              child: ExpandablePanel(
                header: Container(
                    alignment: Alignment.centerLeft,
                    height: sy(35),
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Row(
                      children: [
                        Text(
                          Lang(" By Sub Category ", " حسب الفئة الفرعية ")
                              .toString(),
                          style: ts_Regular(sy(n), Colors.black),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        if (selectSubCategory.length != 0)
                          Container(
                            decoration: decoration_round(
                                TheamPrimary.withOpacity(0.2),
                                sy(5),
                                sy(5),
                                sy(5),
                                sy(5)),
                            padding:
                                EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(3)),
                            child: Text(
                              selectSubCategory.length.toString(),
                              style: ts_Bold(sy(s), TheamPrimary),
                            ),
                          )
                      ],
                    )),
                collapsed: subCategoryBlock(),
                expanded: SizedBox(
                  width: 0,
                ),
                // expanded: expanded
              ),
            ),
            divLine(),
            Container(
              color: Colors.white,
              width: Width(context),
              margin: EdgeInsets.fromLTRB(0, sy(3), 0, 0),
              child: ExpandablePanel(
                header: Container(
                    alignment: Alignment.centerLeft,
                    height: sy(35),
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Row(
                      children: [
                        Text(
                          Lang(" By Price ", " حسب السعر ").toString(),
                          style: ts_Regular(sy(n), Colors.black),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        if (selectedRange.start.toStringAsFixed(0) != '0' ||
                            selectedRange.end.toStringAsFixed(0) != '100000')
                          Container(
                            decoration: decoration_round(
                                TheamPrimary.withOpacity(0.2),
                                sy(5),
                                sy(5),
                                sy(5),
                                sy(5)),
                            padding:
                                EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(3)),
                            child: Text(
                              selectedRange.start.toStringAsFixed(0) +
                                  ' - ' +
                                  selectedRange.end.toStringAsFixed(0) +
                                  ' ' +
                                  Const.CURRENCY,
                              style: ts_Bold(sy(s), TheamPrimary),
                            ),
                          )
                      ],
                    )),
                expanded: priceBlock(),
                collapsed: SizedBox(
                  width: 0,
                ),
                // expanded: expanded
              ),
            ),
            divLine(),
            Container(
              color: Colors.white,
              width: Width(context),
              margin: EdgeInsets.fromLTRB(0, sy(3), 0, 0),
              child: ExpandablePanel(
                header: Container(
                    alignment: Alignment.centerLeft,
                    height: sy(35),
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Row(
                      children: [
                        Text(
                          Lang("By Offers  ", " حسب العروض ").toString(),
                          style: ts_Regular(sy(n), Colors.black),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        if (selectLable.length != 0)
                          Container(
                            decoration: decoration_round(
                                TheamPrimary.withOpacity(0.2),
                                sy(5),
                                sy(5),
                                sy(5),
                                sy(5)),
                            padding:
                                EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(3)),
                            child: Text(
                              selectLable.length.toString(),
                              style: ts_Bold(sy(s), TheamPrimary),
                            ),
                          )
                      ],
                    )),
                expanded: lableBlock(),
                collapsed: SizedBox(
                  width: 0,
                ),
                // expanded: expanded
              ),
            ),
            divLine(),
            Container(
              color: Colors.white,
              width: Width(context),
              margin: EdgeInsets.fromLTRB(0, sy(3), 0, 0),
              child: ExpandablePanel(
                header: Container(
                    alignment: Alignment.centerLeft,
                    height: sy(35),
                    padding:
                        EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(10)),
                    child: Row(
                      children: [
                        Text(
                          Lang(" By Usage ", "حسب الاستخدام  ").toString(),
                          style: ts_Regular(sy(n), Colors.black),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        if (selectUsed.length != 0)
                          Container(
                            decoration: decoration_round(
                                TheamPrimary.withOpacity(0.2),
                                sy(5),
                                sy(5),
                                sy(5),
                                sy(5)),
                            padding:
                                EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(3)),
                            child: Text(
                              selectUsed.length.toString(),
                              style: ts_Bold(sy(s), TheamPrimary),
                            ),
                          )
                      ],
                    )),
                expanded: usedBlock(),
                collapsed: SizedBox(
                  width: 0,
                ),
                // expanded: expanded
              ),
            ),
            divLine(),
          ],
        ),
      ),
    );
  }

  divLine() {
    return Container(
      width: Width(context),
      height: sy(1),
      color: Colors.grey.shade200,
    );
  }

  categoryBlock() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(0), sy(2), sy(0), sy(2)),
      color: Colors.grey[200],
      child: Wrap(
        runSpacing: sy(2),
        spacing: sy(0),
        children: [
          for (int i = 0; i < Const.categoryList.length; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  selectCategory = Const.categoryList[i]['c_id'];
                  selectSubCategory = [];
                  selectSubCategoryString = '';
                });
              },
              child: Container(
                color: Colors.grey[50],
                padding: EdgeInsets.fromLTRB(sy(10), sy(2), sy(10), sy(2)),
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.width*0.29,
                child: Row(
                  children: [
                    ClipRRect(
                      child: Container(
                        padding:
                            EdgeInsets.fromLTRB(sy(3), sy(3), sy(3), sy(3)),
                        child: CustomeImageView(
                          image: Urls.imageLocation +
                              Const.categoryList[i]["c_image"],
                          width: sy(20),
                          height: sy(20),
                          placeholder: Urls.DummyImageBanner,
                          alignment: Alignment.topCenter,
                          fit: BoxFit.cover,
                          blurBackground: false,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(sy(5)),
                    ),
                    Expanded(
                      child: Container(
                          margin:
                              EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                          child: Text(
                            Const.categoryList[i]["c_name$cur_Lang"],
                            style: ts_Regular(sy(n), fc_3),
                            maxLines: 1,
                          )),
                    ),
                    Container(
                      height: sy(15),
                      width: sy(15),
                      decoration: decoration_border(
                          Colors.white,
                          Colors.grey.shade400,
                          1,
                          sy(10),
                          sy(10),
                          sy(10),
                          sy(10)),
                      alignment: Alignment.center,
                      child: (selectCategory == Const.categoryList[i]['c_id'])
                          ? Icon(
                              Icons.circle,
                              size: sy(n - 2),
                              color: TheamPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  subCategoryBlock() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(0), sy(2), sy(0), sy(2)),
      color: Colors.grey[200],
      child: Wrap(
        runSpacing: sy(2),
        spacing: sy(0),
        children: [
          for (int i = 0; i < Const.subcategoryList.length; i++)
            if (selectCategory == Const.subcategoryList[i]["c_id"])
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectSubCategory
                        .contains(Const.subcategoryList[i]["sc_id"])) {
                      selectSubCategory.removeAt(selectSubCategory
                          .indexOf(Const.subcategoryList[i]["sc_id"]));
                    } else {
                      selectSubCategory.add(Const.subcategoryList[i]["sc_id"]);
                    }
                  });
                },
                child: Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.fromLTRB(sy(10), sy(2), sy(10), sy(2)),
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.width*0.29,
                  child: Row(
                    children: [
                      ClipRRect(
                        child: Container(
                          padding:
                              EdgeInsets.fromLTRB(sy(3), sy(3), sy(3), sy(3)),
                          child: CustomeImageView(
                            image: Urls.imageLocation +
                                Const.subcategoryList[i]["sc_image"],
                            width: sy(20),
                            height: sy(20),
                            placeholder: Urls.DummyImageBanner,
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover,
                            blurBackground: false,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(sy(5)),
                      ),
                      Expanded(
                        child: Container(
                            margin:
                                EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                            child: Text(
                              Const.subcategoryList[i]["sc_title$cur_Lang"],
                              style: ts_Regular(sy(n), fc_2),
                              maxLines: 1,
                            )),
                      ),
                      Container(
                        height: sy(15),
                        width: sy(15),
                        decoration: decoration_border(
                            Colors.white,
                            Colors.grey.shade400,
                            1,
                            sy(2),
                            sy(2),
                            sy(2),
                            sy(2)),
                        alignment: Alignment.center,
                        child: (selectSubCategory
                                .contains(Const.subcategoryList[i]["sc_id"]))
                            ? Icon(
                                Icons.check,
                                size: sy(n),
                                color: TheamPrimary,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  priceBlock() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  color: Colors.grey[100],
                  width: sy(80),
                  height: sy(35),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        PriceUtils.convert(
                            selectedRange.start.toStringAsFixed(0)),
                        style: ts_Bold(sy(s), fc_1),
                      ),
                      SizedBox(
                        height: sy(3),
                      ),
                      Text(
                        Lang('Minimum', 'الحد الأدنى'),
                        style: ts_Regular(sy(s), fc_3),
                      ),
                    ],
                  )),
              Container(
                  color: Colors.grey[100],
                  width: sy(80),
                  height: sy(35),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        PriceUtils.convert(
                            selectedRange.end.toStringAsFixed(0)),
                        style: ts_Bold(sy(s), fc_1),
                      ),
                      SizedBox(
                        height: sy(3),
                      ),
                      Text(
                        Lang('Maximum', 'الحد الأقصى'),
                        style: ts_Regular(sy(s), fc_3),
                      ),
                    ],
                  )),
            ],
          ),
          SizedBox(
            height: sy(15),
          ),
          SliderTheme(
              data: SliderThemeData(
                  trackHeight: 1,
                  activeTrackColor: TheamPrimary.withOpacity(0.5),
                  thumbColor: TheamPrimary),
              child: RangeSlider(
                  min: 0,
                  max: 100000,
                  divisions: 10000,
                  labels: RangeLabels(
                      '${selectedRange.start.toStringAsFixed(0)}',
                      '${selectedRange.end.toStringAsFixed(0)}'),
                  values: selectedRange,
                  onChanged: (val) {
                    setState(() {
                      selectedRange = val;
                    });
                  }))
        ],
      ),
    );
  }

  lableBlock() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
      child: Wrap(
        runSpacing: sy(2),
        spacing: sy(5),
        children: [
          for (int i = 0; i < Const.lableList.length; i++)
            GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectLable.contains(Const.lableList[i]["l_id"])) {
                      selectLable.removeAt(
                          selectLable.indexOf(Const.lableList[i]["l_id"]));
                    } else {
                      selectLable.add(Const.lableList[i]["l_id"]);
                    }
                  });
                },
                child: Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(10), sy(5)),
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.width*0.29,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                            margin:
                                EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                            child: Text(
                              Const.lableList[i]["l_name$cur_Lang"],
                              style: ts_Regular(sy(n), fc_3),
                              maxLines: 1,
                            )),
                      ),
                      Container(
                        height: sy(15),
                        width: sy(15),
                        decoration: decoration_border(
                            Colors.white,
                            Colors.grey.shade400,
                            1,
                            sy(2),
                            sy(2),
                            sy(2),
                            sy(2)),
                        alignment: Alignment.center,
                        child:
                            (selectLable.contains(Const.lableList[i]["l_id"]))
                                ? Icon(
                                    Icons.check,
                                    size: sy(n),
                                    color: TheamPrimary,
                                  )
                                : null,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  usedBlock() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
      child: Wrap(
        runSpacing: sy(2),
        spacing: sy(5),
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  if (selectUsed.contains("1")) {
                    selectUsed.removeAt(selectUsed.indexOf('1'));
                  } else {
                    selectUsed.add('1');
                  }
                });
              },
              child: Container(
                color: Colors.grey[50],
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(10), sy(5)),
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.width*0.29,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          margin:
                              EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                          child: Text(
                            Lang(" Used Product ", "منتج مستعمل  "),
                            style: ts_Regular(sy(n), fc_3),
                            maxLines: 1,
                          )),
                    ),
                    Container(
                      height: sy(15),
                      width: sy(15),
                      decoration: decoration_border(Colors.white,
                          Colors.grey.shade400, 1, sy(2), sy(2), sy(2), sy(2)),
                      alignment: Alignment.center,
                      child: (selectUsed.contains('1'))
                          ? Icon(
                              Icons.check,
                              size: sy(n),
                              color: TheamPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              )),
          GestureDetector(
              onTap: () {
                setState(() {
                  if (selectUsed.contains("0")) {
                    selectUsed.removeAt(selectUsed.indexOf('0'));
                  } else {
                    selectUsed.add('0');
                  }
                });
              },
              child: Container(
                color: Colors.grey[50],
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(10), sy(5)),
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.width*0.29,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          margin:
                              EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
                          child: Text(
                            Lang(" New Product ", "منتج جديد  "),
                            style: ts_Regular(sy(n), fc_3),
                            maxLines: 1,
                          )),
                    ),
                    Container(
                      height: sy(15),
                      width: sy(15),
                      decoration: decoration_border(Colors.white,
                          Colors.grey.shade400, 1, sy(2), sy(2), sy(2), sy(2)),
                      alignment: Alignment.center,
                      child: (selectUsed.contains('0'))
                          ? Icon(
                              Icons.check,
                              size: sy(n),
                              color: TheamPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  bottomButton() {
    return Container(
      width: Width(context),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    )),
                onPressed: () {
                  setState(() {
                    selectSubCategoryString = '';
                    selectSubCategory.clear();

                    selectLableString = '';
                    selectLable.clear();

                    selectedUsedString = '';
                    selectUsed.clear();

                    selectedRange = RangeValues(0, 100000);
                  });

                  //   Navigator.pushReplacement(context, OpenScreen(widget: ProductListScreen(cid: selectCategory, sid: '1', minPrice: selectedRange.start,maxPrice: selectedRange.end,lable: selectLableString,usage: selectedUsedString,)));
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), sy(5)),
                  child: Text(
                    Lang(" Clear ", "مسح  "),
                    style: ts_Regular(sy(n), Colors.white),
                  ),
                )),
          ),
          SizedBox(
            width: sy(5),
          ),
          Expanded(
            child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: TheamPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    )),
                onPressed: () {
                  setState(() {
                    selectSubCategoryString = '';
                    selectLableString = '';
                    selectedUsedString = '';

                    for (int i = 0; i < selectSubCategory.length; i++) {
                      selectSubCategoryString = selectSubCategoryString +
                          selectSubCategory[i].toString() +
                          ",";
                    }

                    for (int i = 0; i < selectLable.length; i++) {
                      selectLableString =
                          selectLableString + selectLable[i].toString() + ",";
                    }

                    for (int i = 0; i < selectUsed.length; i++) {
                      selectedUsedString =
                          selectedUsedString + selectUsed[i].toString() + ",";
                    }

                    if (selectSubCategoryString.length != 0) {
                      selectSubCategoryString = selectSubCategoryString
                          .substring(0, selectSubCategoryString.length - 1);
                    }

                    if (selectLableString.length != 0) {
                      selectLableString = selectLableString.substring(
                          0, selectLableString.length - 1);
                    }

                    if (selectedUsedString.length != 0) {
                      selectedUsedString = selectedUsedString.substring(
                          0, selectedUsedString.length - 1);
                    }
                  });

                  Navigator.pushReplacement(
                      context,
                      OpenScreen(
                          widget: ProductListScreen(
                        cid: selectCategory,
                        sid: selectSubCategoryString,
                        minPrice: selectedRange.start,
                        maxPrice: selectedRange.end,
                        lable: selectLableString,
                        usage: selectedUsedString,
                      )));
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(sy(15), sy(5), sy(15), sy(5)),
                  child: Text(
                    Lang('Apply', 'تطبيق'),
                    style: ts_Regular(sy(n), Colors.white),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
