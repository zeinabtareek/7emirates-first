import 'package:flutter/material.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/distance_calc.dart';
import 'package:sevenemirates/components/relative_scale.dart';

import '../components/image_viewer.dart';
import '../utils/app_settings.dart';
import '../utils/const.dart';
import '../utils/style_sheet.dart';
import '../utils/translation_widget.dart';
import '../utils/urls.dart';

class ProductCardMain extends StatefulWidget {
  int i = 0;
  List getProducts = [];
  ProductCardMain({Key? key, this.i = 0, required this.getProducts})
      : super(key: key);

  @override
  State<ProductCardMain> createState() => _ProductCardMainState();
}

class _ProductCardMainState extends State<ProductCardMain> with RelativeScale {
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
    return  Container(
      //  height: Width(context) * 0.26,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(sy(2)),
            child:  Container(
                decoration:
                decoration_round(fc_bg, sy(0), sy(0), sy(0), sy(0)),
                //  padding: EdgeInsets.all(sy(1)),

                width: Width(context) * 0.27,
                height: Width(context) * 0.31,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomeImageView(
                        image: Urls.imageLocation +
                            widget.getProducts[widget.i]["p_image"]
                                .toString(),
                        placeholder: Urls.DummyImageBanner,
                        fit: BoxFit.cover,
                        blurBackground: false,
                        height: Width(context) * 0.31,
                        width: Width(context) * 0.27,
                        radius: sy(2),
                      ),),
                    if(widget.getProducts[widget.i]["l_name$cur_Lang"]!=null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: decoration_round(Color(int.parse("0xFF"+widget.getProducts[widget.i]["l_color"].toString().substring(1))).withOpacity(0.8), 0, 0, 0, 0),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(sy(2), sy(2), sy(2), sy(2)),
                          child: Text(widget.getProducts[widget.i]["l_name$cur_Lang"],style: ts_Regular(sy(s), Colors.white),),
                        ))
                  ],
                )),
          ),
          SizedBox(
            width: sy(8),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:  TranslationWidget(
                        message :
                        widget.getProducts[widget.i]["p_title"].toString(),
                        style: ts_Bold(sy(n), fc_3),
                        maxLines: 2,
                      ),
                    ),
                    Spacer(),
                    Text(
                      CustomeDate.ago(widget.getProducts[widget.i]["p_dated"].toString()),
                      style: ts_Regular(sy(s), fc_5),
                    ),
                  ],
                ),

                SizedBox(height: sy(5),),
                TranslationWidget(
                  message :
                  widget.getProducts[widget.i]["p_detail"].toString(),
                  style: ts_Regular(sy(s), fc_4),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sy(3),),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(2)),
                        decoration: decoration_round(Colors.grey.shade100, sy(2), sy(2), sy(2), sy(2)),
                        child: Text(
                          widget.getProducts[widget.i]["c_name$cur_Lang"].toString().toUpperCase(),
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
                          widget.getProducts[widget.i]["sc_title$cur_Lang"].toString().toUpperCase(),
                          style: ts_Regular(sy(s-1), fc_4),
                          maxLines: 1,
                        ),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: sy(5),),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:  Row(
                    children: [

                      Icon(Icons.place,size: sy(n),color: fc_3,),
                      SizedBox(width: sy(3),),
                      TranslationWidget(
                        message :widget.getProducts[widget.i]["p_city"].toString(),
                        style: ts_Regular(sy(s), fc_2),
                      ),
                      SizedBox(width: sy(10),),
                      Icon(Icons.directions_bike,size: sy(n),color: fc_3,),
                      SizedBox(width: sy(3),),
                      Text(DistanceCalc.map(context,  widget.getProducts[widget.i]["p_map"].toString()),
                        style: ts_Regular(sy(s), fc_2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sy(5),),
                Text(Const.CURRENCY +' '+ widget.getProducts[widget.i]["p_sell"].toString(), style: ts_Bold(sy(n), TheamPrimary),),
                SizedBox(
                  height: sy(5),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }


}
