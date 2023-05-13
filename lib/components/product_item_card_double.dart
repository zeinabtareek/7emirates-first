import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sevenemirates/components/relative_scale.dart';

import '../utils/app_settings.dart';
import '../utils/currency_convert.dart';
import '../utils/style_sheet.dart';
import '../utils/translation_widget.dart';
import '../utils/urls.dart';
import 'image_viewer.dart';

class ProductItemCardDouble extends StatefulWidget {
  int i = 0;
  List getProducts = [];
  ProductItemCardDouble({Key? key, this.i = 0, required this.getProducts})
      : super(key: key);

  @override
  _ProductItemCardDoubleState createState() {
    return _ProductItemCardDoubleState();
  }
}

class _ProductItemCardDoubleState extends State<ProductItemCardDouble>
    with RelativeScale {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initRelativeScaler(context);
    // TODO: implement build
    return Container(
      //   margin: EdgeInsets.fromLTRB(sy(3), sy(3), sy(3), sy(3)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.49,
        color: Colors.grey[50],
        padding: EdgeInsets.fromLTRB(sy(2), sy(2), sy(2), sy(0)),
        child: Material(
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.fromLTRB(sy(3), sy(3), sy(3), sy(3)),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.43,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: CustomeImageView(
                              image: Urls.imageLocation +
                                  widget.getProducts[widget.i]["p_image"],
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.width * 0.43,
                              placeholder: Urls.DummyImageBanner,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (widget.getProducts[widget.i]["p_lable"]
                                      .toString() !=
                                  "null" &&
                              widget.getProducts[widget.i]["p_lable"] != '')
                            Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: decoration_round(
                                      Color(int.parse("0xFF" +
                                              widget.getProducts[widget.i]
                                                      ["p_lable_color"]
                                                  .toString()
                                                  .substring(1)))
                                          .withOpacity(0.8),
                                      0,
                                      0,
                                      0,
                                      0),
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.fromLTRB(
                                      sy(2), sy(3), sy(2), sy(3)),
                                  child: Text(
                                    widget.getProducts[widget.i]
                                        ["p_lable$cur_Lang"],
                                    style: ts_Regular(sy(s), Colors.white),
                                  ),
                                )),
                          if (widget.getProducts[widget.i]["p_status"] != 'A')
                            Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: decoration_round(
                                      Colors.grey[500], 0, 0, 0, 0),
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.fromLTRB(
                                      sy(2), sy(3), sy(2), sy(3)),
                                  child: Text(
                                    Lang('OUT OF STACK', "نفاد المكدس"),
                                    style: ts_Regular(sy(s), Colors.white),
                                  ),
                                )),
                        ],
                      )),
                ),
                SizedBox(
                  height: sy(3),
                ),
                TranslationWidget(
                    message: widget.getProducts[widget.i]["p_title"],
                    style: ts_Regular(sy(n), fc_2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true),
                SizedBox(
                  height: sy(2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      PriceUtils.convert(
                          widget.getProducts[widget.i]["p_sell"] ?? '0'),
                      style: ts_Bold(sy(n), fc_1),
                    ),
                    SizedBox(
                      width: sy(4),
                    ),
                    if (double.parse(
                            widget.getProducts[widget.i]["p_mrp"] ?? '0') >
                        double.parse(
                            widget.getProducts[widget.i]["p_sell"] ?? '0'))
                      getoff(),
                    //    if(double.parse(widget.getProducts[widget.i]["p_mrp"])>double.parse(widget.getProducts[widget.i]["p_sell"]))Text(double.parse(widget.getProducts[widget.i]["p_mrp"]).toStringAsFixed(0)+" "+Const.CURRENCY,style: ts_regular_strike(sy(s), Colors.red[300]),),
                  ],
                ),
                SizedBox(
                  height: sy(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getoff() {
    double mrp = double.parse(widget.getProducts[widget.i]["p_mrp"]);
    double sell = double.parse(widget.getProducts[widget.i]["p_sell"]);
    double offer = ((mrp - sell) / mrp) * 100;
    return Container(
      padding: EdgeInsets.fromLTRB(sy(4), sy(2), sy(4), sy(2)),
      decoration: BoxDecoration(
        color: TheamPrimary.withOpacity(0.7),
        borderRadius: BorderRadius.circular(sy(3)),
      ),
      child: Text(offer.toStringAsFixed(0) + '% ${Lang("OFF", "خصم")}',
          style: ts_Regular(8, Colors.white)),
    );
  }
}
