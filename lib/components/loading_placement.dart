import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class LoadingPlacement extends StatelessWidget {
  final double width;
  final double height;
  LoadingPlacement({Key? key,required this.width,required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return animatedBar(context);
  }

  animatedBar(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child:  SizedBox(
            width: (Width(context)<=width)?width/6:width,
            height: (Width(context)<=width)?width/8:height,
            child: LoadingIndicator(
                indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                colors: [TheamPrimary],       /// Optional, The color collections
                strokeWidth: 1,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                backgroundColor:Colors.transparent,      /// Optional, Background of the widget
                pathBackgroundColor: fc_bg   /// Optional, the stroke backgroundColor
            ),
          )
      ),
    ) ;
  }

  imageBar(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Container(
        width: width*0.2,
        child: Image.asset('assets/images/loadingico.gif'),
      ),
    );
  }
}
