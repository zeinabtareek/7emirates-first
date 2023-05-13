import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sevenemirates/components/relative_scale.dart';

import '../utils/app_settings.dart';
import '../utils/currency_convert.dart';
import '../utils/style_sheet.dart';
import '../utils/translation_widget.dart';
import '../utils/urls.dart';

class ProductItemMainCardDouble extends StatefulWidget {
  int i = 0;
  List getProducts = [];
  GestureTapCallback? btnClick;
  ProductItemMainCardDouble(
      {Key? key, required this.i, required this.getProducts, this.btnClick})
      : super(key: key);

  @override
  _ProductItemMainCardDoubleState createState() {
    return _ProductItemMainCardDoubleState();
  }
}

class _ProductItemMainCardDoubleState extends State<ProductItemMainCardDouble>
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
      width: (MediaQuery.of(context).size.width * 0.5),
      color: fc_bg,
      child: Container(
        width: (MediaQuery.of(context).size.width),
        color: Colors.grey[50],
        margin: EdgeInsets.fromLTRB(sy(3), sy(2), sy(3), sy(4)),
        child: Material(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.38,
            color: fc_bg,
            padding: EdgeInsets.fromLTRB(sy(3), sy(0), sy(3), sy(0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(sy(5)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.7,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: FadeInImage.assetNetwork(
                            image: Urls.imageLocation +
                                widget.getProducts[widget.i]["p_image"],
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.45,
                            placeholder: Urls.DummyImageBanner,
                            fit: BoxFit.cover,
                          ),
                        ),
                        /*  if (widget.getProducts[widget.i]["p_lable"]
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
                                    sy(10),
                                    sy(10),
                                    sy(10),
                                    sy(10)),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(
                                    sy(2), sy(3), sy(2), sy(3)),
                                margin: EdgeInsets.fromLTRB(
                                    sy(8), sy(5), sy(8), sy(5)),
                                child: Text(
                                  widget.getProducts[widget.i]
                                      ["p_lable$cur_Lang"],
                                  style: ts_Regular(sy(s), Colors.white),
                                ),
                              )),*/
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
                                  Lang('OUT OF STOCK', "غير متوفر بالمخزن"),
                                  style: ts_Regular(sy(s), Colors.white),
                                ),
                              )),
                        Positioned(
                            top: sy(5),
                            left: sy(5),
                            child: GestureDetector(
                              onTap: widget.btnClick,
                              child: Container(
                                decoration: decoration_round(Colors.white,
                                    sy(10), sy(10), sy(10), sy(10)),
                                padding: EdgeInsets.fromLTRB(
                                    sy(3), sy(3), sy(3), sy(3)),
                                child: (widget.getProducts[widget.i]
                                            ["userlike"] ==
                                        0)
                                    ? Icon(
                                        Icons.favorite_border,
                                        color: fc_1,
                                        size: sy(n),
                                      )
                                    : Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: sy(n),
                                      ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: sy(5),
                ),
                TranslationWidget(
                  message: widget.getProducts[widget.i]["p_title"]
                      .toString()
                      .toUpperCase(),
                  style: ts_Bold(sy(n + 2), fc_1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                SizedBox(
                  height: sy(3),
                ),
                Text(
                  widget.getProducts[widget.i]["c_title$cur_Lang"]
                      .toString()
                      .toUpperCase(),
                  style: ts_Bold_Weight(sy(n), fc_2, FontWeight.w600),
                ),
                SizedBox(
                  height: sy(2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      PriceUtils.convert(
                          widget.getProducts[widget.i]["p_sell"]),
                      style: ts_Bold_Weight(sy(n), fc_3, FontWeight.w600),
                    ),
                    SizedBox(
                      width: sy(4),
                    ),
                    if (double.parse(
                            widget.getProducts[widget.i]["p_mrp"] ?? '0') >
                        double.parse(
                            widget.getProducts[widget.i]["p_sell"] ?? '0'))
                      Expanded(
                        child: Text(
                          PriceUtils.convert(
                              widget.getProducts[widget.i]["p_mrp"]),
                          style: ts_regular_strike(sy(s), Colors.red[300]),
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: sy(8),
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
      child: Text(offer.toStringAsFixed(0) + '% OFF',
          style: ts_Regular(8, Colors.white)),
    );
  }
}
