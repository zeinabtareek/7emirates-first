import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:sevenemirates/anim/ease_in_widget.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

class ProgressButtonJump extends StatefulWidget {
  bool? showProgress;
  double? btwidth;
  double btheight;
  double btpadding;
  double btround;
  String? bttext;
  double bttextsize;
  Color btcolor;
  final Function() onTap;
  ProgressButtonJump({Key? key,required this.showProgress,required this.btwidth,this.btheight=35,this.btpadding=0 ,required this.bttext,this.btround=0 ,this.bttextsize=12,this.btcolor=TheamPrimary, required this.onTap}) : super(key: key);

  @override
  _ProgressButtonJumpState createState() {
    return _ProgressButtonJumpState();
  }
}

class _ProgressButtonJumpState extends State<ProgressButtonJump>  with RelativeScale{
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
    // TODO: implement build
    initRelativeScaler(context);
    return  EaseInWidget(
        onTap: widget.onTap,
        child: Material(
            borderRadius: BorderRadius.circular(sy(widget.btround)),
            color:widget.btcolor,
            child: Container(
              width: widget.btwidth,
              height: widget.btheight,
              alignment: Alignment.center,
              padding: EdgeInsets.all(widget.btpadding),
              decoration: decoration_round(Colors.transparent, sy(widget.btround), sy(widget.btround), sy(widget.btround), sy(widget.btround)),
              child: (widget.showProgress==false)?Text(widget.bttext!,style: ts_Regular(sy(widget.bttextsize), Colors.white),):
              SizedBox(
                width:  widget.btwidth!/4,
                height: widget.btheight/3,
                child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                    colors: [Colors.white],       /// Optional, The color collections
                    strokeWidth: 1,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                    backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                    pathBackgroundColor: Colors.transparent /// Optional, the stroke backgroundColor
                ),
              ),
            ),));



  }
}